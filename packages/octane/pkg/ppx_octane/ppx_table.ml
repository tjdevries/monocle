(*
   TODO:
  - Make sure primary key is always first parameter
  - Also explore named parameters in postgres, I think those work
  - How are we going to handle composite keys?
*)

open Core
open Ppxlib
open Ast_builder
module Database = Drivers.Postgres

module Util = struct
  let throw ~loc fmt =
    Format.kasprintf (fun str -> Location.Error.raise @@ Location.Error.make ~loc ~sub:[] str) fmt
  ;;
end

module FieldKind = struct
  type t =
    | PrimaryKey of { autoincrement : bool }
    | ForeignKey of
        { table : string
        ; column : string
        ; on_delete : string
        }
    | Column
  [@@deriving eq]

  let is_fillable = function
    | PrimaryKey _ -> false
    | ForeignKey _ -> true
    | Column -> true
  ;;

  let is_primary_key = function
    | PrimaryKey _ -> true
    | _ -> false
  ;;
end

module TableField = struct
  type t =
    { label_declaration : label_declaration
    ; loc : Location.t
    ; name : string Loc.t
    ; ty : core_type
    ; kind : FieldKind.t
    ; nullable : bool
      (** Is the field nullable? *)
    }

  let make label_declaration =
    let kind =
      List.find_map label_declaration.pld_attributes ~f:(fun attr ->
        match attr.attr_name.txt with
        | "primary_key" -> Some (FieldKind.PrimaryKey { autoincrement = true })
        | "references" ->
          Some (FieldKind.ForeignKey { table = "users"; column = "id"; on_delete = "CASCADE" })
        | _ -> None)
      |> Option.value ~default:FieldKind.Column
    in
    let nullable =
      match label_declaration.pld_type with
      | [%type: [%t? core_type] option] -> true
      | _ -> false
    in
    { label_declaration
    ; loc = label_declaration.pld_loc
    ; name = label_declaration.pld_name
    ; ty = label_declaration.pld_type
    ; kind
    ; nullable
    }
  ;;

  (* Iter helpers *)
  let map (fields : t list) ~f = List.map ~f:(fun t -> f ~loc:t.loc t) fields
  let mapi (fields : t list) ~f = List.mapi ~f:(fun idx t -> f ~loc:t.loc idx t) fields

  let rec coretype_to_create_field ~loc = function
    | [%type: [%t? core_type] option] -> coretype_to_create_field ~loc core_type
    | { ptyp_desc = Ptyp_constr ({ txt; _ }, []); _ } -> begin
      match txt with
      | Lident txt -> Database.coretype_to_sql txt |> Option.value_exn
      | Ldot (Ldot (Lident m, "Fields"), f) ->
        (* Util.throw ~loc "create_field - ldot" *)
        "INTEGER"
      | Ldot (Ldot (Lident m, "Model"), f) ->
        (* Util.throw ~loc "create_field - ldot" *)
        "INTEGER"
      | _ -> Util.throw ~loc "TODO: create_field - unknown type"
    end
    | _ -> Util.throw ~loc "Unknown type: coretype_to_create_field"
  ;;

  (* SQL Helpers *)
  let create_field ~loc t =
    let name = t.name.txt in
    let column_type = coretype_to_create_field ~loc t.ty in
    let column_attributes =
      match t.nullable, t.kind with
      | _, FieldKind.PrimaryKey { autoincrement = true } ->
        "GENERATED ALWAYS AS IDENTITY PRIMARY KEY"
      | false, FieldKind.PrimaryKey _ -> "PRIMARY KEY NOT NULL"
      | true, FieldKind.PrimaryKey _ -> "PRIMARY KEY"
      | _, FieldKind.ForeignKey { table; column; on_delete } ->
        (* [%string ", FOREIGN KEY (%{name}) REFERENCES %{table} (%{column}) ON DELETE %{on_delete}"] *)
        [%string "REFERENCES %{table} (%{column}) ON DELETE %{on_delete}"]
      | false, FieldKind.Column -> "NOT NULL"
      | true, FieldKind.Column -> ""
    in
    Format.sprintf "%s %s %s" name column_type column_attributes
  ;;

  (* AST Helpers *)
  let ename { loc; name; _ } = Default.evar ~loc name.txt

  let params_field ~loc { name; _ } = CaqtiHelper.make_params_field ~loc name.txt
end

let make_fields_from_type payload =
  let checker =
    object
      inherit [label_declaration list] Ast_traverse.fold as super
      method! label_declaration ext acc = super#label_declaration ext (ext :: acc)
    end
  in
  checker#type_declaration payload [] |> List.rev |> List.map ~f:TableField.make
;;

let args () = Deriving.Args.(empty +> arg "name" (estring __))

let get_field_constructor ~loc ename pld_type =
  let match_lident name optional =
    match name, optional with
    | "int", true -> [%expr Caqti_type.Std.(option int)]
    | "int", false -> [%expr Caqti_type.Std.int]
    | "string", true -> [%expr Caqti_type.Std.(option string)]
    | "string", false -> [%expr Caqti_type.Std.string]
    | lident, _ -> Util.throw ~loc "TODO: field_params - unknown builtin type: %s" lident
  in
  let rec coretype_to_expr ty optional =
    match ty.ptyp_desc with
    | Ptyp_constr ({ txt = Lident "option"; _ }, [ core_type ]) -> coretype_to_expr core_type true
    | Ptyp_constr ({ txt; _ }, []) -> begin
      match txt with
      | Lident ident -> match_lident ident optional
      | Ldot (Ldot (Lident m, "Fields"), f) -> Gen.module_param ~loc m f
      | Ldot _ -> Util.throw ~loc "TODO: unknown ldot"
      | Lapply (_, _) -> Util.throw ~loc "TODO: Lapply"
    end
    | _ -> Util.throw ~loc "TODO: field_params"
  in
  coretype_to_expr pld_type false
;;

let generate_fields_module ~loc (fields : TableField.t list) =
  let field_names =
    List.map fields ~f:(fun { loc; name; _ } ->
      let pat = Default.ppat_var ~loc name in
      let str = Default.estring ~loc name.txt in
      [%stri let [%p pat] = [%e str]])
  in
  let field_types =
    List.map fields ~f:(fun { loc; name; label_declaration; _ } ->
      (* let attrs = [ Attr.make_deriving_attr ~loc [ "deserialize"; "serialize" ] ] in *)
      let attrs = [] in
      let type_decl = Ast_helper.Type.mk name ~manifest:label_declaration.pld_type ~attrs in
      Ast_helper.Str.type_ Recursive [ type_decl ])
  in
  Ast_helper.Mod.structure (field_names @ field_types)
;;

let generate_params_module ~loc (fields : TableField.t list) =
  let field_params =
    TableField.map fields ~f:(fun ~loc field ->
      let ename = TableField.ename field in
      let param_name = Default.ppat_var ~loc field.name in
      let constructor = get_field_constructor ~loc ename field.ty in
      [%stri let [%p param_name] = [%e constructor]])
  in
  let field_types =
    TableField.map fields ~f:(fun ~loc field ->
      let type_declaration =
        Ast_helper.Type.mk field.name ~kind:Ptype_abstract ~manifest:field.ty
      in
      Default.pstr_type ~loc Recursive [ type_declaration ])
  in
  Ast_helper.Mod.structure (field_params @ field_types)
;;

(* let generate_model_module ~loc (fields : TableField.t list) = *)
(*   let field_params = *)
(*     TableField.map fields ~f:(fun ~loc field -> *)
(*       let ename = TableField.ename field in *)
(*       let param_name = Default.ppat_var ~loc field.name in *)
(*       let constructor = get_field_constructor ~loc ename field.ty in *)
(*       [%stri let [%p param_name] = [%e constructor]]) *)
(*   in *)
(*   let octane_thingy = Loc.make ~loc (Ldot (Ldot (Lident "Octane", "Model"), "t")) in *)
(*   let model_type = Ast_helper.Typ.constr ~loc octane_thingy [ [%type: Params.id]; [%type: t] ] in *)
(*   Ast_helper.Mod.structure [ [%stri type nonrec t = [%t model_type]] ] *)
(* ;; *)

let generate_create_function ~loc name (fields : TableField.t list) =
  let fields = List.filter fields ~f:(fun field -> FieldKind.is_fillable field.kind) in
  let params =
    TableField.map fields ~f:(fun ~loc field -> TableField.ename field) |> Default.pexp_tuple ~loc
  in
  let columns =
    TableField.map fields ~f:(fun ~loc field -> field.name.txt) |> String.concat ~sep:", "
  in
  let placeholders = List.map fields ~f:(fun _ -> "?") |> String.concat ~sep:", " in
  let query =
    [%string "INSERT INTO %{name} (%{columns}) VALUES (%{placeholders}) RETURNING *"]
    |> Default.estring ~loc
  in
  let left =
    match fields with
    | [] -> [%expr unit]
    | [ field ] -> Default.pexp_apply ~loc (TableField.params_field ~loc field) []
    | _ ->
      let length = List.length fields in
      let init = CaqtiHelper.get_caqti_t ~loc length in
      Default.pexp_apply ~loc init
      @@ List.map fields ~f:(fun field -> Nolabel, TableField.params_field ~loc field)
  in
  (* let right = [%expr int] in *)
  let caqti_query = [%expr ([%e left] ->! record) @@ [%e query]] in
  let body =
    [%expr
      let query = [%e caqti_query] in
      Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find query [%e params]) db]
  in
  let body = Gen.make_positional_fun ~loc "db" body in
  List.fold_right fields ~init:body ~f:(fun { name; nullable; _ } acc ->
    match nullable with
    | true -> Gen.make_optional_fun ~loc name.txt acc
    | false -> Gen.make_labelled_fun ~loc name.txt acc)
;;

let generate_read_function ~loc name (fields : TableField.t list) =
  let primary_key = List.find fields ~f:(fun field -> FieldKind.is_primary_key field.kind) in
  match primary_key with
  | Some primary_key ->
    let primary_key_name = primary_key.name.txt in
    let query =
      [%string "SELECT * FROM %{name} WHERE %{name}.%{primary_key_name} = $1"]
      |> Default.estring ~loc
    in
    let param = TableField.params_field ~loc primary_key in
    let body =
      [%expr
        let query = ([%e param] ->? record) @@ [%e query] in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find_opt query id) db]
    in
    Some [%stri let read db id = [%e body]]
  | None -> None
;;

let generate_delete_function ~loc name (fields : TableField.t list) =
  let primary_key = List.find fields ~f:(fun field -> FieldKind.is_primary_key field.kind) in
  match primary_key with
  | Some primary_key ->
    let primary_key_name = primary_key.name.txt in
    let query =
      [%string "DELETE FROM %{name} WHERE %{name}.%{primary_key_name} = $1"] |> Default.estring ~loc
    in
    let param = TableField.params_field ~loc primary_key in
    let body =
      [%expr
        let query = ([%e param] ->. unit) @@ [%e query] in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec query id) db]
    in
    Some [%stri let delete db id = [%e body]]
  | None -> None
;;

let generate_update_function ~loc name (fields : TableField.t list) =
  let primary_key = List.find fields ~f:(fun field -> FieldKind.is_primary_key field.kind) in
  match primary_key with
  | Some primary_key ->
    let primary_key_name = primary_key.name.txt in
    let fields = List.filter fields ~f:(fun field -> FieldKind.is_fillable field.kind) in
    let columns =
      TableField.mapi fields ~f:(fun ~loc idx field -> Fmt.str "%s = $%d" field.name.txt (idx + 2))
      |> String.concat ~sep:", "
    in
    let query =
      [%string "UPDATE %{name} SET %{columns} WHERE %{name}.%{primary_key_name} = $1"]
      |> Default.estring ~loc
    in
    let body =
      [%expr
        let query = (record ->. unit) @@ [%e query] in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec query t) db]
    in
    Some [%stri let update db t = [%e body]]
  | None -> None
;;

let generate_serializers ~ctxt type_declarations =
  let deser = Serde_derive.De.generate_impl ~ctxt (Nonrecursive, type_declarations) in
  let ser = Serde_derive.Ser.generate_impl ~ctxt (Nonrecursive, type_declarations) in
  deser @ ser
;;

let generate_caqti_product ~loc (fields : TableField.t list) =
  CaqtiHelper.Record.derive
    ~loc
    (List.map fields ~f:(fun { name; _ } -> CaqtiHelper.Record.record_field ~loc name.txt))
;;

let generate_table_module ~loc name (fields : TableField.t list) =
  let drop_query = Default.estring ~loc (Database.drop_table ~name) in
  let create_query =
    let columns = TableField.map fields ~f:TableField.create_field |> String.concat ~sep:", " in
    Default.estring ~loc (Database.create_table ~name ~columns)
  in
  Ast_helper.Mod.structure
    [ [%stri let drop = (unit ->. unit) @@ [%e drop_query]]
    ; [%stri
        let drop db =
          Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec drop ()) db
        ;;]
    ; [%stri let create = (unit ->. unit) @@ [%e create_query]]
    ; [%stri
        let create db =
          Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec create ()) db
        ;;]
    ]
;;

let generate_impl ~ctxt (_, (type_declarations : type_declaration list)) name =
  let loc = Expansion_context.Deriver.derived_item_loc ctxt in
  (* Name has to be passed, it's check in ppxlib *)
  let name = Option.value_exn name in
  (* We only support one type declaration per table *)
  let ty =
    match type_declarations with
    | [ ty ] -> ty
    | _ -> Util.throw ~loc "ppx_table requires exactly one type declaration"
  in
  let fields = make_fields_from_type ty in
  let ename = Default.estring ~loc name in
  (* let serializers = generate_serializers ~ctxt type_declarations in *)
  let serializers = [] in
  let caqti_product = generate_caqti_product ~loc fields in
  let field_module = generate_fields_module ~loc fields in
  let params_module = generate_params_module ~loc fields in
  let table_module = generate_table_module ~loc name fields in
  let create_body = generate_create_function ~loc name fields in
  let read_item = generate_read_function ~loc name fields in
  let update_item = generate_update_function ~loc name fields in
  let delete_item = generate_delete_function ~loc name fields in
  serializers
  @ [ [%stri open Caqti_request.Infix]
    ; [%stri open Caqti_type.Std]
    ; [%stri module Fields = [%m field_module]]
    ; [%stri module Params = [%m params_module]]
    ; [%stri module Table = [%m table_module]]
    ; [%stri let relation = [%e ename]]
    ; caqti_product
    ; [%stri let insert = [%e create_body]]
    ; Option.value ~default:[%stri let () = ()] read_item
    ; Option.value ~default:[%stri let () = ()] update_item
    ; Option.value ~default:[%stri let () = ()] delete_item
      (* ; [%stri let () = Octane.TableRegistry.register { name = [%e ename]; fields = [] }] *)
    ]
;;

let generator () = Deriving.Generator.V2.make (args ()) generate_impl
let my_deriver = Deriving.add "table" ~str_type_decl:(generator ())
