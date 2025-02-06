open Core
open Yojson.Basic.Util

exception UnexpectedFormat of string
let unexpected_format json = UnexpectedFormat (Fmt.str "Unexpected format: %a" Yojson.Basic.pp json)

module Access = struct
  let sval json =
    match to_assoc json with
    | [ ("String", `Assoc [ ("sval", `String str) ]) ] -> str
    | _ -> raise (unexpected_format json)
  ;;
end

type constant =
  [ `string of string
  | `int of int
  ]
and field =
  [ `star
  | `field of string
  ]
and column = [ `column of string option * string option * field ]
and model = [ `model of string * field ]
and binary_op =
  | Equal
  | NotEqual
[@@deriving show { with_path = false }]

module Expression = struct
  type t =
    [ column
    | model
    | constant
    | `binary of t * binary_op * t
    ]
  [@@deriving show { with_path = false }]

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
  { from : select_from list
  ; targets : Expression.t list
  ; limit_option : string
  ; op : string
  }

and join_expression =
  { left : select_from
  ; right : select_from
  ; kind : join_kind
  ; qualifications : qualification list
  }

and join_kind =
  | Inner
  | Left
  | Right
  | Full

and qualification = Expression of Expression.t

and select_from =
  | Relation of string
  | Join of join_expression
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
  let limit_option = data |> member "limitOption" |> to_string in
  let op = data |> member "op" |> to_string in
  Select { from; targets; limit_option; op }

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

and map_from_clause data : select_from =
  map_by_key data (fun key value ->
    match key with
    | "RangeVar" -> map_range_var value
    | "JoinExpr" -> Join (map_join_expr value)
    | _ -> failwith "unknown from_clause")

and map_range_var data =
  let relation = data |> member "relname" |> to_string in
  Relation relation

and map_join_expr value =
  let kind = value |> member "jointype" |> to_string |> join_kind_of_string in
  let left = value |> member "larg" |> map_from_clause in
  let right = value |> member "rarg" |> map_from_clause in
  let qualifications = value |> member "quals" |> to_assoc |> List.map ~f:map_qualification in
  { left; right; kind; qualifications }

and map_qualification (key, value) =
  match key with
  | "A_Expr" -> Expression (map_expression value)
  | _ -> failwith "TODO: map_qualification"

and map_expression data =
  (* {"A_Expr":{"kind":"AEXPR_OP","name":[{"String":{"sval":"="}}],"lexpr":{"ColumnRef":{"fields":[{"String":{"sval":"Account"}},{"String":{"sval":"id"}}],"location":67}},"rexpr":{"ColumnRef":{"fields":[{"String":{"sval":"Post"}},{"String":{"sval":"author"}}],"location":80}},"location":78}} *)
  Fmt.epr "map_expression: %s@." (Yojson.Basic.to_string data);
  Fmt.epr "  %s@." (Yojson.Basic.to_string (member "kind" data));
  let kind = data |> member "kind" |> to_string in
  match kind with
  | "AEXPR_OP" -> map_binary_expression data
  | _ -> failwith "TODO: map_expression"

and map_binary_expression data =
  let open Expression in
  let op = data |> member "name" |> to_list |> List.hd_exn |> Access.sval in
  let op =
    match op with
    | "=" -> Equal
    | _ -> failwith "TODO: map_binary_expression"
  in
  let left = data |> member "lexpr" |> map_expression in
  let right = data |> member "rexpr" |> map_expression in
  `binary (left, op, right)

and join_kind_of_string = function
  | "JOIN_INNER" -> Inner
  | _ -> failwith "TODO: join_kind_of_string"
;;

let parse result =
  let json = Yojson.Basic.from_string result in
  let stmts = statements json in
  let stmts = Stdlib.List.flatten stmts in
  Ok stmts
;;

(* let of_protobuf (stmts : PG.raw_stmt list) = () *)
