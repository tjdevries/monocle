module Parse_raw = struct
  let success () =
    let result = PGQuery.raw_parse "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id" in
    match result with
    | { error = None; _ } -> ()
    | { error = Some err; _ } ->
      Alcotest.failf "unexpected parse error: %s" (PGQuery.show_parse_error err)
  ;;

  let error () =
    Alcotest.(check @@ bool)
      "raw_parse success"
      true
      ((PGQuery.raw_parse "SELECT * FROM users WHHERE id = 1").error <> None)
  ;;
end

module Parse = struct
  let success () =
    match PGQuery.parse "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id" with
    | Ok _ -> ()
    | Error msg -> Alcotest.failf "parse error: %a" PGQuery.pp_parse_error msg
  ;;

  let error () =
    match PGQuery.parse "INSERT INTO users (name, email) VALUES ?, ? RETURNING id" with
    | Error _ -> ()
    | Ok _ -> Alcotest.failf "unexpected parse success"
  ;;
end

let () =
  Alcotest.run
    "pg_query"
    [ ( "parse_raw"
      , [ "returns no error on correct query", `Quick, Parse_raw.success
        ; "returns an error on incorrect query", `Quick, Parse_raw.error
        ] )
    ; ( "parse"
      , [ "returns no error on correct query", `Quick, Parse.success
        ; "returns an error on incorrect query", `Quick, Parse.error
        ] )
    ]
;;
