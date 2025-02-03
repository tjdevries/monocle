open Core

let parse s =
  let open PGQuery.Protobuf in
  let result = parse s in
  result
  |> Result.map ~f:(fun result ->
    let () = Fmt.epr "%a@." PGQuery.ProtobufGen.pp_parse_result result in
    Ast.Good)
;;
