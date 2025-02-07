let parse s =
  let transformed = Ast.transform s in
  let result = PGQuery.parse transformed.transformed in
  match result with
  | Ok result ->
    (* Fmt.epr "parse: %s@." result; *)
    Ast.parse transformed result
  | Error msg -> Fmt.failwith "%a" PGQuery.pp_parse_error msg
;;
