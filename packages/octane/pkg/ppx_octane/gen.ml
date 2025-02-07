open Ppxlib
open Oql
open Core

module Expr = Oql.Ast.Expression

module QueryParam = struct
  let make_positional_param_expr ~loc i =
    let ident = Loc.make ~loc (Lident ("p" ^ Int.to_string i)) in
    Ast_builder.Default.pexp_ident ~loc ident
  ;;

  let make_named_param_expr ~loc name i =
    let ident = Loc.make ~loc (Lident name) in
    Ast_builder.Default.pexp_ident ~loc ident
  ;;

  let make_param_caqti_type ~loc (param : Oql.Analysis.param) =
    match param with
    | { ty = Some `text; _ } -> [%expr string]
    | { ty = Some `int; _ } -> [%expr int]
    | { ty = Some (`model (model, `field field)); _ } ->
      CaqtiHelper.make_params_field ~loc ~model field
    | { ty = Some (`model (model, `star)); _ } -> failwith "TODO: model.* is not supported"
    | { ty = None; _ } ->
      Fmt.failwith "TODO: make_param_caqti_type (%a)" Oql.Analysis.pp_param param
  ;;
end

let table_relation ~loc relation =
  let ident = Ldot (Lident relation, "relation") in
  let ident = Loc.make ~loc ident in
  Ast_helper.Exp.ident ~loc ident
;;

let module_param ~loc module_name param_name =
  Format.eprintf "module_param: %s.%s\n" module_name param_name;
  (* module_name.Params.param_name *)
  let ident = Ldot (Lident module_name, "Params") in
  let ident = Ldot (ident, param_name) in
  let ident = Loc.make ~loc ident in
  Ast_helper.Exp.ident ~loc ident
;;

let get_param ~loc correlation field =
  match correlation with
  (* | Ast.Table t -> Ast.Table.name t (* User.Fields.param_id id *) *)
  | _ -> failwith "get_param: correlation"
;;

let make_fun ~loc ~label arg body =
  let arg = Loc.make ~loc arg in
  let pattern = Ast_builder.Default.ppat_var ~loc arg in
  Ast_builder.Default.pexp_fun ~loc label None pattern body
;;

let make_labelled_fun ~loc arg body =
  let arg_loc = Loc.make ~loc arg in
  let pattern = Ast_builder.Default.ppat_var ~loc arg_loc in
  Ast_builder.Default.pexp_fun ~loc (Labelled arg) None pattern body
;;

let make_optional_fun ~loc arg body =
  let arg_loc = Loc.make ~loc arg in
  let pattern = Ast_builder.Default.ppat_var ~loc arg_loc in
  Ast_builder.Default.pexp_fun ~loc (Optional arg) None pattern body
;;

let type_of_expression_to_generated_expression ~loc type_of_expr expr =
  let expr = Ast_builder.Default.evar ~loc expr in
  match type_of_expr with
  (* | Some (ModelField model_field) -> *)
  (*   let model = ModelField.model_name model_field in *)
  (*   let field = ModelField.field_name model_field in *)
  (*   let param_fn = module_param ~loc model field in *)
  (*   [%expr [%e param_fn] [%e expr]] *)
  (* | Some (Column c) -> failwith "Need to implement Column support" *)
  | _ -> expr
;;

type state = { params : Analysis.params }

let rec of_ast ~loc transformed (ast : Ast.statement) =
  (* let params = Analysis.find_params ast in *)
  let state = { params = Analysis.of_ast transformed ast } in
  match ast with
  | Select select ->
    let query_expr = to_select_string ~loc ~state select in
    let paramslist =
      List.fold_right state.params ~init:[] ~f:(fun pos acc ->
        QueryParam.make_positional_param_expr ~loc pos.id :: acc)
    in
    (* TODO: Handle named *)
    (* let paramlist = List.rev_append paramlist params.named in *)
    let params_expr =
      match paramslist with
      | [] -> [%expr ()]
      | [ item ] -> item
      | [ item1; item2 ] -> [%expr [%e item1], [%e item2]]
      | _ -> Fmt.failwith "TODO: more than one positional param"
    in
    let encode =
      match state.params with
      | [] -> [%expr unit]
      | [ param ] -> QueryParam.make_param_caqti_type ~loc param
      | [ p1; p2 ] ->
        let p1 = QueryParam.make_param_caqti_type ~loc p1 in
        let p2 = QueryParam.make_param_caqti_type ~loc p2 in
        [%expr t2 [%e p1] [%e p2]]
      | _ -> Fmt.failwith "TODO: more than one positional param"
    in
    let body =
      [%expr
        let open Caqti_request.Infix in
        let open Caqti_type.Std in
        let query = ([%e encode] ->* record) @@ [%e query_expr] in
        let params = [%e params_expr] in
        (* Fmt.epr "query: %s@." query; *)
        Octane.Database.collect db query params]
    in
    let body =
      List.fold_right state.params ~init:body ~f:(fun pos body ->
        let label =
          match pos.name with
          | Some name -> Labelled name
          | None -> Nolabel
        in
        make_fun ~loc ~label (Fmt.str "p%d" pos.id) body)
    in
    (* let body = *)
    (*   List.fold state.params ~init:body ~f:(fun body pos -> *)
    (*     make_labelled_fun ~loc pos.name body) *)
    (* in *)
    let f = make_fun ~loc ~label:Nolabel "db" body in
    [%stri let query = [%e f]]

and of_from_clause ~loc ~state (from : Ast.Expression.selectable) =
  match from with
  | `table relations ->
    let relations = [ relations ] in
    let tables = List.map relations ~f:(table_relation ~loc) |> Ast_builder.Default.elist ~loc in
    [%expr Core.String.concat ~sep:", " [%e tables]]
  | `join join -> of_join_clause ~loc ~state join

and of_join_clause ~loc ~state (stanza : Expr.join_expression) =
  let op = stanza.kind in
  let op =
    match op with
    | `inner -> "INNER JOIN"
    | _ -> failwith "Join stanza op"
  in
  let left = table_relation ~loc (Expr.Selectable.relation stanza.left) in
  let op = Ast_builder.Default.estring ~loc op in
  let right = table_relation ~loc (Expr.Selectable.relation stanza.right) in
  let qualifications = of_expression ~loc ~state stanza.qualifications in
  [%expr Stdlib.Format.sprintf "%s %s %s ON %s" [%e left] [%e op] [%e right] [%e qualifications]]

and to_select_string ~loc ~state (select : Ast.select_statement) =
  match select.from with
  | [ relation ] ->
    let select_clause = of_expressions ~loc ~state select.targets in
    let from_clause = of_from_clause ~loc ~state relation in
    let where_clause =
      match select.where with
      | Some where ->
        let where = of_expression ~loc ~state where in
        [%expr Stdlib.Format.sprintf "WHERE %s" [%e where]]
      | None -> [%expr ""]
    in
    [%expr
      Stdlib.Format.sprintf
        "SELECT %s FROM %s %s"
        [%e select_clause]
        [%e from_clause]
        [%e where_clause]]
  | [] -> failwith "no relations: must be arch user"
  | _ -> failwith "too many relations: must be on windows 95"

and of_expressions ~loc ~state (expressions : Ast.Expression.t list) =
  let exprs = List.map ~f:(of_expression ~loc ~state) expressions in
  let exprs = Ast_builder.Default.elist ~loc exprs in
  [%expr Stdlib.String.concat ", " [%e exprs]]

and of_expression ~loc ~state (target : Ast.Expression.t) =
  match target with
  | `column (None, None, `star) -> [%expr "*"]
  | `column (None, Some table, field) ->
    let field =
      match field with
      | `star -> "*"
      | `field field -> field
    in
    let string = Fmt.str "%s.%s" table field in
    let string = Ast_builder.Default.estring ~loc string in
    string
  | `model (model, field) ->
    let field =
      match field with
      | `star -> "*"
      | `field field -> field
    in
    let relation = table_relation ~loc model in
    let field = Ast_builder.Default.estring ~loc field in
    [%expr Stdlib.Format.sprintf "%s.%s" [%e relation] [%e field]]
  | `binary (left, op, right) -> of_binary_expression ~loc ~state left op right
  | `param num ->
    let num = Ast_builder.Default.eint ~loc num in
    [%expr Stdlib.Format.sprintf "($%d)" [%e num]]
  | `typed_param (ty, num) ->
    let num = Ast_builder.Default.eint ~loc num in
    let ty = Ast_builder.Default.estring ~loc @@ Ast.PGTypes.show ty in
    [%expr Stdlib.Format.sprintf "($%d::%s)" [%e num] [%e ty]]
  | _ -> Fmt.failwith "unsupported expression: %a" Expr.pp target

and of_binary_expression ~loc ~state left op right =
  let left = of_expression ~loc ~state left in
  let op = of_bitop ~loc op in
  let right = of_expression ~loc ~state right in
  [%expr Stdlib.Format.sprintf "(%s %s %s)" [%e left] [%e op] [%e right]]

and of_position_param ~loc ~state pos =
  Ast_builder.Default.estring ~loc ("$" ^ Stdlib.string_of_int pos)

and of_bitop ~loc op =
  match op with
  | `add -> Ast_builder.Default.estring ~loc "+"
  | `equal -> Ast_builder.Default.estring ~loc "="
  | `not_equal -> Ast_builder.Default.estring ~loc "<>"
  | `op_and -> Ast_builder.Default.estring ~loc "AND"
  | `op_or -> Ast_builder.Default.estring ~loc "OR"

(* and of_model_field ~loc m = *)
(*   let open Ast in *)
(*   (* let loc = ModelField.location m in *) *)
(*   let ident = Ldot (Lident (ModelField.model_name m), "relation") in *)
(*   let ident = Loc.make ~loc ident in *)
(*   let table = Ast_helper.Exp.ident ~loc ident in *)
(*   let field = Ldot (Lident (ModelField.model_name m), "Fields") in *)
(*   let field = Ldot (field, ModelField.field_name m) in *)
(*   let field = Loc.make ~loc field in *)
(*   let field = Ast_helper.Exp.ident ~loc field in *)
(*   [%expr Stdlib.Format.sprintf "%s.%s" [%e table] [%e field]] *)

and of_column ~loc col =
  match col with
  (* | Table (Module ident), Field (_, _, Unquoted field) -> *)
  (*   (* TODO: This is not how we want table refs to work *) *)
  (*   let table = table_relation ~loc (Table ident) in *)
  (*   let field = Ast_builder.Default.estring ~loc field in *)
  (*   (* Ast_builder.Default.estring ~loc (Fmt.str "%s.%s" table field) *) *)
  (*   [%expr Stdlib.Format.sprintf "%s.%s" [%e table] [%e field]] *)
  | _ -> failwith "column_ref"
;;
