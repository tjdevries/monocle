module Parse_raw = struct
  let success () =
    Alcotest.(check @@ bool)
      "raw_parse success"
      true
      ((PGQuery.raw_parse "SELECT * FROM users WHERE id = 1").error = None)
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
    Alcotest.(check @@ bool)
      "raw_parse success"
      true
      (match PGQuery.parse "INSERT INTO users (name, email) VALUES (?, ?) RETURNING id" with
       | Ok _ -> true
       | Error _ -> false)
  ;;

  let error () =
    Alcotest.(check @@ bool)
      "raw_parse success"
      true
      (match PGQuery.parse "INSERT INTO users (name, email) VALUES ?, ? RETURNING id" with
       | Error _ -> true
       | Ok _ -> false)
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
