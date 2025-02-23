open! Core

type params = param list
and param =
  { id : int
  ; name : string option
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

let of_ast (transformed : Ast.transformed) (ast : Ast.statement) =
  let _ = transformed in
  let ast = typecheck ast in
  let find_param acc id = List.find acc ~f:(fun param -> param.id = id) in
  let get_name id =
    List.nth transformed.found (id - 1)
    |> Option.map ~f:(String.substr_replace_all ~pattern:"$" ~with_:"")
  in
  let open Ast in
  let rec search expr acc =
    match expr with
    | `param pos -> begin
      match find_param acc pos with
      | Some _ -> acc
      | None -> { id = pos; name = get_name pos; ty = None } :: acc
    end
    | `typed_param (ty, pos) ->
      let param = { id = pos; name = get_name pos; ty = Some ty } in
      begin
        match find_param acc pos with
        | Some { ty = Some _; _ } ->
          (* TODO: Probably should error if the types don't match *)
          acc
        | Some { ty = None; _ } -> param :: acc
        | None -> param :: acc
      end
    | `binary (left, _, right) -> acc |> search left |> search right
    | _ -> acc
  in
  let acc = [] in
  match ast with
  | Select { targets; where; _ } ->
    let acc =
      List.fold_left ~init:acc ~f:(fun acc target -> search target.expression acc) targets
    in
    let acc = Option.fold ~init:acc ~f:(fun acc where -> search where acc) where in
    List.sort acc ~compare:(fun left right -> Int.compare left.id right.id)
;;
