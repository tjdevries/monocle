open Ppxlib
open Oql
open Core

module Expr = Oql.Ast.Expression

let make_positional_param_expr ~loc i =
  let ident = Loc.make ~loc (Lident ("p" ^ Int.to_string i)) in
  Ast_builder.Default.pexp_ident ~loc ident
;;

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

let make_fun ~loc arg body =
  let arg = Loc.make ~loc arg in
  let pattern = Ast_builder.Default.ppat_var ~loc arg in
  Ast_builder.Default.pexp_fun ~loc Nolabel None pattern body
;;

let make_labelled_fun ~loc arg body =
  let arg_loc = Loc.make ~loc arg in
  let pattern = Ast_builder.Default.ppat_var ~loc arg_loc in
  Ast_builder.Default.pexp_fun ~loc (Labelled arg) None pattern body
;;

let make_positional_fun ~loc arg body =
  let arg_loc = Loc.make ~loc arg in
  let pattern = Ast_builder.Default.ppat_var ~loc arg_loc in
  Ast_builder.Default.pexp_fun ~loc Nolabel None pattern body
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

let rec of_ast ~loc (ast : Ast.statement) =
  (* let params = Analysis.find_params ast in *)
  let state = { params = Analysis.of_ast ast } in
  match ast with
  | Select select ->
    let query_expr = to_select_string ~loc ~state select in
    let paramslist =
      List.fold_left state.params.positional ~init:[] ~f:(fun acc pos ->
        make_positional_param_expr ~loc pos :: acc)
    in
    (* TODO: Handle named *)
    (* let paramlist = List.rev_append paramlist params.named in *)
    let params_expr =
      match paramslist with
      | [] -> [%expr ()]
      | [ item ] -> item
      | _ -> Fmt.failwith "TODO: more than one positional param"
    in
    (* let idk = Ast_builder.Default.pexp_open *)
    (* let params_expr = Ast_builder.Default.pexp_open ~loc idk params_expr in *)
    (* let f = Ast_helper.Exp.fun_ in *)
    (* let arg_label *)
    let encode =
      match state.params.positional with
      | [] -> [%expr unit]
      | [ param ] -> [%expr int]
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
      List.fold_right state.params.positional ~init:body ~f:(fun pos body ->
        make_fun ~loc (Fmt.str "p%d" pos) body)
    in
    let body =
      List.fold state.params.named ~init:body ~f:(fun body pos -> make_labelled_fun ~loc pos body)
    in
    let f = make_fun ~loc "db" body in
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
  | _ -> Fmt.failwith "unsupported expression: %a" Expr.pp target

and of_binary_expression ~loc ~state left op right =
  let left = of_expression ~loc ~state left in
  let op = of_bitop ~loc op in
  let right = of_expression ~loc ~state right in
  [%expr Stdlib.Format.sprintf "(%s %s %s)" [%e left] [%e op] [%e right]]
(*   let _ = get_param ~loc correlation field in *)
(* match left, right with *)
(* | ModelField model_field, NamedParam param -> *)
(*   let left = of_model_field ~loc model_field in *)
(*   let right = of_named_param ~loc ~state param in *)
(*   [%expr Stdlib.Format.sprintf "(%s = %s)" [%e left] [%e right]] *)
(* | ModelField model_field, PositionalParam pos -> [%expr "TODO"] *)
(* | ModelField left, ModelField right -> *)
(*   let left = of_model_field ~loc left in *)
(*   let right = of_model_field ~loc right in *)
(*   [%expr Stdlib.Format.sprintf "(%s = %s)" [%e left] [%e right]] *)
(* | _ -> failwith "binary expression: not supported" *)

and of_named_param ~loc ~state (name : string) =
  let named_position, _ = List.findi_exn state.params.named ~f:(fun _ n -> String.(n = name)) in
  let position = List.length state.params.positional + named_position + 1 in
  of_position_param ~loc ~state position

and of_position_param ~loc ~state pos =
  (* make_positional_param_expr ~loc pos *)
  Ast_builder.Default.estring ~loc ("$" ^ Stdlib.string_of_int pos)

and of_bitop ~loc op =
  match op with
  | `add -> Ast_builder.Default.estring ~loc "+"
  | `equal -> Ast_builder.Default.estring ~loc "="
  | _ -> failwith "bitop"

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
