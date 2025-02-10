open Core
open Ppxlib

module Util = struct
  let throw ~loc fmt =
    Format.kasprintf (fun str -> Location.Error.raise @@ Location.Error.make ~loc ~sub:[] str) fmt
  ;;
end

let shift_start start offset colshift =
  Lexing.
    { pos_fname = start.pos_fname
    ; pos_lnum = start.pos_lnum + offset.pos_lnum - 1
    ; pos_cnum = start.pos_cnum + offset.pos_cnum + colshift
    ; pos_bol = start.pos_bol + offset.pos_bol
    }
;;

let shift_end start offset colshift =
  Lexing.
    { pos_fname = start.pos_fname
    ; pos_lnum = start.pos_lnum + offset.pos_lnum - 1
    ; pos_cnum = start.pos_cnum + offset.pos_cnum + colshift
    ; pos_bol = start.pos_bol + offset.pos_bol
    }
;;

let add_location start offset colshift =
  Location.
    { loc_start = shift_start start.loc_start offset.loc_start colshift
    ; loc_end = shift_end start.loc_start offset.loc_end colshift
    ; loc_ghost = false
    }
;;

type kind =
  | Many
  | One
  | Opt

let query_rule extender_name (kind : kind) =
  let context = Extension.Context.structure_item in
  let extracter () =
    let open Ast_pattern in
    (* let%query module [pattern] *)
    let qmod = ppat_unpack (some __) in
    (* let%query [pattern] *)
    let qident = ppat_construct (lident __) drop in
    (* THIS IS THE STRING I WANT TO FIND THE LOCATION OF *)
    let binding = value_binding ~pat:(alt qmod qident) ~expr:(estring __') in
    pstr (pstr_value nonrecursive (binding ^:: nil) ^:: nil)
  in
  let my_extender =
    Extension.V3.declare extender_name context (extracter ())
    @@ fun ~ctxt pat query ->
    let loc = Expansion_context.Extension.extension_point_loc ctxt in
    let query = Loc.txt query in
    let transformed, ast =
      match Oql.Run.parse query with
      | Ok ast -> ast
      | Error msg -> Util.throw ~loc "Failed to parse query: %s" msg
    in
    let items =
      match ast with
      | [ Oql.Ast.Select { targets; from; _ } ] ->
        let fields =
          List.filter_map
            ~f:(function
              | `column col -> assert false
              | `model (model, `field field) ->
                let open Ast_builder.Default in
                (* TODO: get the right location? *)
                (* let m = ModelField.model_name model_field in *)
                (* let f_start, f_end, f = model_field.field in *)
                (* let f_loc = Location.{ loc_start = f_start; loc_end = f_end; loc_ghost = false } in *)
                (* let f_loc = add_location query_loc f_loc 1 in *)
                let ident = Ldot (Lident model, "Fields") in
                let ident = Ldot (ident, field) in
                let type_ : core_type = ptyp_constr ~loc (Loc.make ~loc ident) [] in
                Some (label_declaration ~loc ~name:(Loc.make ~loc field) ~mutable_:Immutable ~type_)
              | `model (model, `star) ->
                let open Ast_builder.Default in
                let ident = Ldot (Lident model, "t") in
                let type_ : core_type = ptyp_constr ~loc (Loc.make ~loc ident) [] in
                Some
                  (label_declaration
                     ~loc
                     ~name:(Loc.make ~loc (String.lowercase model))
                     ~mutable_:Immutable
                     ~type_)
              | `binary _ -> failwith "TODO: binary"
              | `join _ -> failwith "TODO: join"
              | `param _ -> failwith "TODO: param"
              | `typed_param _ -> failwith "TODO: typed_param"
              | #Oql.Ast.Expression.constant -> None)
            targets
        in
        (* TODO: This gets models that are referenced but NOT selected *)
        (* let invalid_model = Oql.Analysis.get_invalid_model ast in *)
        let invalid_model = None in
        let items =
          match invalid_model with
          | None ->
            let type_decl =
              Ast_builder.Default.type_declaration
                ~loc
                ~name:(Loc.make ~loc "t")
                ~params:[]
                ~cstrs:[]
                ~kind:(Ptype_record fields)
                ~private_:Public
                ~manifest:None
            in
            (* let attributes = Attr.make_deriving_attr ~loc [ "serialize"; "deserialize" ] in *)
            (* let type_decl = { type_decl with ptype_attributes = [ attributes ] } in *)
            let type_decl = Ast_builder.Default.pstr_type ~loc Recursive [ type_decl ] in
            let ast = List.hd_exn ast in
            let query_fn = Gen.of_ast ~loc transformed ast in
            let record =
              CaqtiHelper.Record.derive
                ~loc
                (List.filter_map targets ~f:(function
                   | `model (model, `field field) ->
                     Some (CaqtiHelper.Record.record_field ~loc ~model field)
                   | `model (model, `star) ->
                     Some
                       (CaqtiHelper.Record.record_field
                          ~loc
                          ~model
                          ~kind:Model
                          (String.lowercase model))
                   | _ -> None))
            in
            (* [%p arg1] *)
            (* let arg1 = Ast_builder.Default.ppat_var ~loc (Loc.make ~loc "db") in *)
            [ [%stri open Caqti_request.Infix]
            ; [%stri open Caqti_type.Std]
            ; type_decl
            ; record
            ; query_fn
            ]
          | Some _ ->
            (* let loc = Oql.Ast.Model.location invalid_model in *)
            (* let loc = add_location query_loc (Oql.Ast.ModelField.location invalid_model) 2 in *)
            (* (* let _ = Ast_builder.Default.plb in *) *)
            (* let ty = *)
            (*   Ast_builder.Default.ptyp_extension ~loc *)
            (*   @@ Location.error_extensionf *)
            (*        ~loc *)
            (*        "Invalid Model: Module '%a' is not selected in query" *)
            (*        Oql.Ast.Model.pp *)
            (*        invalid_model.model *)
            (* in *)
            (* [ [%stri type t = [%t ty]] ] *)
            []
        in
        items
      | _ -> failwith "TODO: items "
    in
    let query = Ast_builder.Default.estring ~loc query in
    let ignore_warning = Attr.make_ignore_warning ~loc in
    let x =
      { pmod_desc = Pmod_structure (items @ [ [%stri let raw = [%e query]] ])
      ; pmod_loc = loc
      ; pmod_attributes = [ ignore_warning ]
      }
    in
    let binding =
      Ast_builder.Default.module_binding ~loc ~name:(Loc.make ~loc (Some pat)) ~expr:x
    in
    { pstr_desc = Pstr_module binding; pstr_loc = loc }
  in
  Context_free.Rule.extension my_extender
;;

(*
   query.many
query.one
query.opt
query.find
query.insert
*)

Driver.register_transformation
  ~rules:
    [ query_rule "query" Many
    ; query_rule "query.many" Many
    ; query_rule "query.one" One
    ; query_rule "query.opt" Opt
    ]
  "ppx_octane_ocaml"
