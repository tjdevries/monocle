open Ppxlib
open Oql
open Core

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
  let open Ast in
  match type_of_expr with
  (* | Some (ModelField model_field) -> *)
  (*   let model = ModelField.model_name model_field in *)
  (*   let field = ModelField.field_name model_field in *)
  (*   let param_fn = module_param ~loc model field in *)
  (*   [%expr [%e param_fn] [%e expr]] *)
  (* | Some (Column c) -> failwith "Need to implement Column support" *)
  | _ -> expr
;;

type params =
  { positional : int list
  ; named : string list
  }

type state = { params : params }

let rec of_ast ~loc (ast : Ast.statement) =
  (* let params = Analysis.find_params ast in *)
  let params = { positional = []; named = [] } in
  let state = { params } in
  match ast with
  | Select select ->
    let query_expr = to_select_string ~loc ~state select in
    let paramlist =
      List.fold_left params.positional ~init:[] ~f:(fun acc pos -> Fmt.str "p%d" pos :: acc)
    in
    let paramlist = List.rev_append paramlist params.named in
    let paramslist =
      List.map paramlist ~f:(fun param ->
        (* let type_constraint = Analysis.get_type_of_named_param ast (NamedParam param) in *)
        (* type_of_expression_to_generated_expression ~loc type_constraint param) *)
        failwith "TODO: get_type_of_named_param")
    in
    let params_expr = Ast_builder.Default.elist ~loc paramslist in
    (* let idk = Ast_builder.Default.pexp_open *)
    (* let params_expr = Ast_builder.Default.pexp_open ~loc idk params_expr in *)
    (* let f = Ast_helper.Exp.fun_ in *)
    (* let arg_label *)
    let body =
      [%expr
        let open Caqti_request.Infix in
        let open Caqti_type.Std in
        let query = (unit ->* record) @@ [%e query_expr] in
        let params = () in
        (* Fmt.epr "query: %s@." query; *)
        Octane.Database.collect db query params]
    in
    let body =
      List.fold_right params.positional ~init:body ~f:(fun pos body ->
        make_fun ~loc (Fmt.str "p%d" pos) body)
    in
    let body =
      List.fold params.named ~init:body ~f:(fun body pos -> make_labelled_fun ~loc pos body)
    in
    let f = make_fun ~loc "db" body in
    [%stri let query = [%e f]]

and of_from_clause ~loc ~state (from : Ast.select_from) =
  match from with
  | Relation relations ->
    let relations = [ relations ] in
    let tables = List.map relations ~f:(table_relation ~loc) |> Ast_builder.Default.elist ~loc in
    [%expr Core.String.concat ~sep:", " [%e tables]]
  | _ -> failwith "TODO: from_clause"

(* and of_join_stanza ~loc ~state (stanza : Ast.join_stanza) = *)
(*   let op, table, join_constraint = stanza in *)
(*   let op = *)
(*     match op with *)
(*     | Inner -> "INNER JOIN" *)
(*     | _ -> failwith "Join stanza op" *)
(*   in *)
(*   let op = Ast_builder.Default.estring ~loc op in *)
(*   let table = table_relation ~loc table in *)
(*   match join_constraint with *)
(*   | On expr -> *)
(*     let on = of_expression ~loc ~state expr in *)
(*     [%expr Stdlib.Format.sprintf "%s %s ON %s" [%e op] [%e table] [%e on]] *)
(*   | Using fields -> failwith "using fields" *)

and to_select_string ~loc ~state (select : Ast.select_statement) =
  match select.from with
  | [ relation ] ->
    let from_clause = of_from_clause ~loc ~state relation in
    (* let expressions = Ast.get_select_expressions select.select in *)
    let select_clause = of_targets ~loc ~state select.targets in
    let e =
      (* match select.where with *)
      (* | Some w -> *)
      (*   let where_clause = of_expression ~loc ~state w in *)
      (*   [%expr *)
      (*     Stdlib.Format.sprintf *)
      (*       "SELECT %s FROM %s WHERE %s" *)
      (*       [%e select_clause] *)
      (*       [%e from_clause] *)
      (*       [%e where_clause]] *)
      (* | None -> *)
      [%expr Stdlib.Format.sprintf "SELECT %s FROM %s" [%e select_clause] [%e from_clause]]
    in
    e
  | [] -> failwith "no relations: must be arch user"
  | _ -> failwith "too many relations: must be on windows 95"

and of_targets ~loc ~state (expressions : Ast.Expression.t list) =
  let exprs = List.map ~f:(of_target ~loc ~state) expressions in
  let exprs = Ast_builder.Default.elist ~loc exprs in
  [%expr Stdlib.String.concat ", " [%e exprs]]

and of_target ~loc ~state (target : Ast.Expression.t) =
  match target with
  | Column (None, None, Star) -> [%expr "*"]
  | Column (None, Some table, field) ->
    let field =
      match field with
      | Star -> "*"
      | Field field -> field
    in
    let string = Fmt.str "%s.%s" table field in
    let string = Ast_builder.Default.estring ~loc string in
    string
  | Model (model, field) ->
    let field =
      match field with
      | Star -> "*"
      | Field field -> field
    in
    let relation = table_relation ~loc model in
    let field = Ast_builder.Default.estring ~loc field in
    [%expr Stdlib.Format.sprintf "%s.%s" [%e relation] [%e field]]
  (* let string = Fmt.str "%s.%s" model field in *)
  (* let string = Ast_builder.Default.estring ~loc string in *)
  (* string *)
  (* | Ast.NumericLiteral _ -> failwith "Number" *)
  (* | Ast.StringLiteral _ -> failwith "String" *)
  (* | Ast.BitString _ -> failwith "BitString" *)
  (* | Ast.TypeCast _ -> failwith "TypeCast" *)
  (* | Ast.PositionalParam pos -> make_positional_param_expr ~loc pos *)
  (* | Ast.NamedParam name -> [%expr "KEKW"] *)
  (* | Ast.Column col -> of_column ~loc col *)
  (* | Ast.Index (_, _) -> failwith "Index" *)
  (* | Ast.BinaryExpression (left, op, right) -> of_binary_expression ~loc ~state left op right *)
  (* | Ast.UnaryExpression (_, _) -> failwith "UnaryExpression" *)
  (* | Ast.FunctionCall (_, _) -> failwith "FunctionCall" *)
  (* | Ast.Null -> failwith "Null" *)
  (* | Ast.ModelField m -> of_model_field ~loc m *)
  (* | Ast.ColumnReference (column_ref, field) -> *)
  (*   of_column_reference ~loc (column_ref, field) *)
  | _ -> Fmt.failwith "unsupported target: %a" Oql.Ast.Expression.pp target

(* and of_binary_expression ~loc ~state left op right = *)
(*   let open Oql.Ast in *)
(*   (* User.id = $id *) *)
(*   (* let left = of_expression ~loc left in *) *)
(*   (* left = User.id, Equal, right = $id *) *)
(*   (* let right = of_expression ~loc right in *) *)
(*   (* let op = of_bitop ~loc op in *) *)
(*   (* [%expr Stdlib.Format.sprintf "(%s %s %s)" [%e left] [%e op] [%e right]] *) *)
(*   match left, right with *)
(*   (*   let _ = get_param ~loc correlation field in *) *)
(*   | ModelField model_field, NamedParam param -> *)
(*     let left = of_model_field ~loc model_field in *)
(*     let right = of_named_param ~loc ~state param in *)
(*     [%expr Stdlib.Format.sprintf "(%s = %s)" [%e left] [%e right]] *)
(*   | ModelField model_field, PositionalParam pos -> [%expr "TODO"] *)
(*   | ModelField left, ModelField right -> *)
(*     let left = of_model_field ~loc left in *)
(*     let right = of_model_field ~loc right in *)
(*     [%expr Stdlib.Format.sprintf "(%s = %s)" [%e left] [%e right]] *)
(*   | _ -> failwith "binary expression: not supported" *)

and of_named_param ~loc ~state (name : string) =
  let named_position, _ = List.findi_exn state.params.named ~f:(fun _ n -> String.(n = name)) in
  let position = List.length state.params.positional + named_position + 1 in
  of_position_param ~loc ~state position

and of_position_param ~loc ~state pos =
  (* make_positional_param_expr ~loc pos *)
  Ast_builder.Default.estring ~loc ("$" ^ Stdlib.string_of_int pos)

(* and of_bitop ~loc op = *)
(*   match op with *)
(*   | Ast.Add -> Ast_builder.Default.estring ~loc "+" *)
(*   | Ast.Eq -> Ast_builder.Default.estring ~loc "=" *)
(*   | _ -> failwith "bitop" *)

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
