open Core

let parse s =
  let result = PGQuery.parse s in
  match result with
  | Ok result ->
    Fmt.epr "parse: %s@." result;
    Ast.parse result
  | Error msg -> Fmt.failwith "%a" PGQuery.pp_parse_error msg
;;
