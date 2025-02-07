open Core
open Yojson.Basic.Util

exception UnexpectedFormat of string
let unexpected_format json = UnexpectedFormat (Fmt.str "Unexpected format: %a" Yojson.Basic.pp json)

let member_object member_name json =
  match member member_name json |> to_assoc with
  | [ obj ] -> obj
  | _ -> raise (unexpected_format json)
;;

let member_object_opt member_name json =
  match member member_name json with
  | `Null -> None
  | _ -> Some (member_object member_name json)
;;

module Access = struct
  let sval json =
    match to_assoc json with
    | [ ("String", `Assoc [ ("sval", `String str) ]) ] -> str
    | _ -> raise (unexpected_format json)
  ;;
end

module Operator = struct
  type binary =
    [ `equal
    | `not_equal
    | `add
    ]
  [@@deriving show { with_path = false }]
end

module Expression = struct
  type constant =
    [ `string of string
    | `int of int
    ]
  and field =
    [ `star
    | `field of string
    ]
  and param = [ `param of int ]
  and column = [ `column of string option * string option * field ]
  and model = [ `model of string * field ]
  and table = [ `table of string ]
  and join_kind =
    [ `inner
    | `left
    | `right
    | `full
    ]
  [@@deriving show { with_path = false }]

  type t =
    [ column
    | model
    | constant
    | param
    | `binary of t * Operator.binary * t
    | `join of join_expression
    ]
  and selectable =
    [ table
    | `join of join_expression
    ]
  and join_expression =
    { left : selectable
    ; right : selectable
    ; kind : join_kind
    ; qualifications : t
    }
  [@@deriving show { with_path = false }]

  (* Should be same as join in type t, exposed for type safety *)
  type join = [ `join of join_expression ] [@@deriving show { with_path = false }]

  module Selectable = struct
    type t = selectable

    let rec relation (x : t) : string =
      match x with
      | `table relation -> relation
      | `join { left; _ } -> relation left
    ;;
  end

  let something (x : t) : join =
    match x with
    | `join _ as x -> x
    | _ -> failwith "TODO"
  ;;

  let of_constant constant : [> constant ] =
    match to_assoc constant with
    | ("sval", `Assoc [ ("sval", `String str) ]) :: _ -> `string str
    | ("ival", `Assoc [ ("ival", `Int i) ]) :: _ -> `int i
    | _ -> Fmt.failwith "TODO: constant (%a)" Yojson.Basic.pp constant
  ;;

  let of_fields fields : t =
    let of_field item : t =
      match to_assoc item with
      | [ ("A_Star", _) ] -> `column (None, None, `star)
      | [ ("A_Const", constant) ] -> of_constant constant
      | _ -> failwith "TODO: field"
    in
    match fields with
    | [] -> failwith "TODO: no fields"
    | [ item ] -> of_field item
    | [ table; field ] ->
      let table = Access.sval table in
      let field = Access.sval field in
      begin
        match table.[0] with
        | 'A' .. 'Z' -> `model (table, `field field)
        | _ -> `column (None, Some table, `field field)
      end
    | items -> Fmt.failwith "TODO: too many fields: %a" Yojson.Basic.pp (List.hd_exn items)
  ;;
end

type t = statement list

and statement = Select of select_statement
and select_statement =
  { targets : Expression.t list
  ; from : Expression.selectable list
  ; op : string
  ; where : Expression.t option
  ; limit_option : string
  }
[@@deriving show { with_path = false }]

(* Example

select * from ... -> Star
select users.id from ... -> ColumnRef (None, "users", Column "id")
select User.* from ... -> ModelRef ("User", Star)
select User.id from ... -> ModelRef ("User", Column "id")

{"version":170000,"stmts":[{"stmt":{"SelectStmt":{"targetList":[{"ResTarget":{"val":{"ColumnRef":{"fields":[{"A_Star":{}}],"location":7}},"location":7}}],"fromClause":[{"RangeVar":{"relname":"users","inh":true,"relpersistence":"p","location":14}}],"limitOption":"LIMIT_OPTION_DEFAULT","op":"SETOP_NONE"}},"stmt_len":19}]} *)

let map_by_key data f = data |> to_assoc |> List.hd_exn |> fun (key, value) -> f key value

let rec statements json =
  match
    json
    |> member "stmts"
    |> to_list
    |> List.map ~f:(fun stmt -> stmt |> member "stmt" |> to_assoc |> List.map ~f:map_statement)
  with
  | result -> result
  | exception e ->
    Fmt.epr "json: %s@." (Yojson.Basic.to_string json);
    raise e

and map_statement (name, data) =
  match name with
  | "SelectStmt" -> map_select data
  | _ -> failwith "cannot parse"

and map_select data =
  let targets = data |> member "targetList" |> to_list |> List.map ~f:map_target_list in
  let from = data |> member "fromClause" |> to_list |> List.map ~f:map_from_clause in
  let where = data |> member_object_opt "whereClause" |> Option.map ~f:map_expression in
  let limit_option = data |> member "limitOption" |> to_string in
  let op = data |> member "op" |> to_string in
  Select { from; targets; limit_option; op; where }

and map_target_list data =
  let key, value = data |> to_assoc |> List.hd_exn in
  match key with
  | "ResTarget" -> map_res_target value
  | _ -> failwith "cannot parse"

and map_res_target data =
  let targets =
    data
    |> member "val"
    |> to_assoc
    |> List.map ~f:(fun (key, value) ->
      match key with
      | "A_Const" -> map_constant value
      | "ColumnRef" -> map_column_ref value
      | _ -> failwith "unknown res_target")
    |> List.hd_exn
  in
  targets

and map_column_ref data = data |> member "fields" |> to_list |> Expression.of_fields

and map_constant data = Expression.of_constant data

and map_from_clause data : Expression.selectable =
  map_by_key data (fun key value ->
    match key with
    | "RangeVar" -> map_range_var value
    | "JoinExpr" -> map_join_expr value
    | key -> Fmt.failwith "TODO: from_clause: %s" key)

and map_range_var data =
  let relation = data |> member "relname" |> to_string in
  `table relation

and map_join_expr value =
  let kind = value |> member "jointype" |> to_string |> join_kind_of_string in
  let left = value |> member "larg" |> map_from_clause in
  let right = value |> member "rarg" |> map_from_clause in
  let qualifications = value |> member_object "quals" |> map_expression in
  `join { left; right; kind; qualifications }

and map_expression (key, data) =
  match key with
  | "A_Expr" ->
    let kind = data |> member "kind" |> to_string in
    begin
      match kind with
      | "AEXPR_OP" -> map_binary_expression data
      | _ -> failwith "TODO: map_expression"
    end
  | "ColumnRef" -> map_column_ref data
  | "ParamRef" -> map_param_ref data
  | _ -> Fmt.failwith "TODO: map_expression: %s" key

and map_param_ref data =
  let position = data |> member "number" |> to_int in
  `param position

and map_binary_expression data =
  let op = data |> member "name" |> to_list |> List.hd_exn |> Access.sval in
  let op =
    match op with
    | "=" -> `equal
    | _ -> Fmt.failwith "TODO(map_binary_expression): %s" op
  in
  let left = data |> member "lexpr" |> to_assoc |> List.hd_exn |> map_expression in
  let right = data |> member "rexpr" |> to_assoc |> List.hd_exn |> map_expression in
  `binary (left, op, right)

and join_kind_of_string = function
  | "JOIN_INNER" -> `inner
  | _ -> failwith "TODO: join_kind_of_string"
;;

let parse result =
  let json = Yojson.Basic.from_string result in
  let stmts = statements json in
  let stmts = Stdlib.List.flatten stmts in
  Ok stmts
;;

(* let of_protobuf (stmts : PG.raw_stmt list) = () *)
