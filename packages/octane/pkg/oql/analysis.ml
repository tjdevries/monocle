open! Core

type params =
  { named : string list
  ; positional : param list
  }
and param =
  { id : int
  ; ty : Ast.PGTypes.t option
  }
[@@deriving show, eq]

let typecheck (statement : Ast.statement) =
  let find_type (expr : Ast.Expression.t) =
    match expr with
    | `model (model, field) -> `model (model, field)
    | _ -> Fmt.failwith "TODO: find_type %a" Ast.Expression.pp expr
  in
  let rec update_expression (expr : Ast.Expression.t) =
    match expr with
    | `binary (`param id, _, right) ->
      let right = find_type right in
      `binary (`typed_param (right, id), `equal, right)
    | `binary (left, _, `param id) ->
      let ty = find_type left in
      `binary (left, `equal, `typed_param (ty, id))
    | `binary (left, op, right) ->
      let left = update_expression left in
      let right = update_expression right in
      `binary (left, op, right)
    | _ -> expr
  in
  match statement with
  | Select select ->
    let where = Option.map select.where ~f:update_expression in
    Ast.Select { select with where }
;;

let of_ast (ast : Ast.statement) =
  let ast = typecheck ast in
  let find_param acc id = List.find acc.positional ~f:(fun param -> param.id = id) in
  let open Ast in
  let rec search expr acc =
    match expr with
    | `param pos ->
      if Option.is_some @@ find_param acc pos
      then acc
      else { acc with positional = { id = pos; ty = None } :: acc.positional }
    | `typed_param (ty, pos) ->
      let param = { id = pos; ty = Some ty } in
      begin
        match find_param acc pos with
        | Some { ty = Some _; _ } ->
          (* TODO: Probably should error if the types don't match *)
          acc
        | Some { ty = None; _ } -> { acc with positional = param :: acc.positional }
        | None -> { acc with positional = param :: acc.positional }
      end
    | `binary (left, _, right) -> acc |> search left |> search right
    | _ -> acc
  in
  let acc = { named = []; positional = [] } in
  match ast with
  | Select { targets; where; _ } ->
    let acc = List.fold_left ~init:acc ~f:(fun acc expr -> search expr acc) targets in
    let acc = Option.fold ~init:acc ~f:(fun acc where -> search where acc) where in
    { acc with
      positional =
        List.sort acc.positional ~compare:(fun left right -> Int.compare left.id right.id)
    }
;;

(* let get_type_of_expression expr = *)
(*   let open Ast in *)
(*   match expr with *)
(*   | ModelField _ as expr -> Some expr *)
(*   (* | ColumnReference (Table (Module m), f) as e -> Some e *) *)
(*   | _ -> None *)
(* ;; *)

(* let get_type_of_named_param ast param = *)
(*   let open Ast in *)
(*   let rec search expr = *)
(*     match expr with *)
(*     | BinaryExpression (left, _op, right) when Ast.equal_expression right param -> *)
(*       get_type_of_expression left *)
(*     | BinaryExpression (left, _op, _right) when Ast.equal_expression left param -> *)
(*       failwith "param matches left" *)
(*     | BinaryExpression (_left, _op, _right) -> None *)
(*     | UnaryExpression (_, expr) -> search expr *)
(*     | FunctionCall (_, _) -> failwith "function call" *)
(*     | _ -> None *)
(*   in *)
(*   match ast with *)
(*   | Select { where = Some where; _ } -> search where *)
(*   | _ -> None *)
(* ;; *)

(* let print_params str = *)
(*   let ast = Run.parse str in *)
(*   let ast = Result.ok_or_failwith ast in *)
(*   let params = find_params ast in *)
(*   Fmt.pr "%a\n" pp_params params *)
(* ;; *)

(* let%expect_test "positional params" = *)
(*   print_params "SELECT User.id FROM User WHERE User.id = $id"; *)
(*   [%expect {| { Analysis.named = ["id"]; positional = [] } |}] *)
(* ;; *)
(**)
(* let%expect_test "multiple positional params" = *)
(*   print_params "SELECT User.id, $1, $2 FROM User"; *)
(*   [%expect {| { Analysis.named = []; positional = [1; 2] } |}] *)
(* ;; *)
(**)
(* let%expect_test "named params" = *)
(*   print_params "SELECT User.id FROM User WHERE User.id = $1"; *)
(*   [%expect {| { Analysis.named = []; positional = [1] } |}] *)
(* ;; *)
(**)
(* let%expect_test "duplicate named params" = *)
(*   print_params "SELECT User.id FROM User WHERE $1 = $1"; *)
(*   [%expect {| { Analysis.named = []; positional = [1] } |}] *)
(* ;; *)
