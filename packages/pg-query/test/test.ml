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

module GoodParse = struct
  let success () =
    let open PGQuery.ProtobufGen in
    let (result : PGQuery.ProtobufGen.parse_result) =
      PGQuery.Protobuf.parse "INSERT INTO users (name, email) VALUES (?, ?) RETURNING id"
    in
    Alcotest.(check int) "has one statement" 1 (List.length result.stmts);
    pp_parse_result Format.std_formatter result;
    let stmt = List.hd result.stmts in
    match stmt.stmt with
    | Some (Insert_stmt insert) ->
      let () =
        match insert.cols with
        | [ Res_target field1; Res_target field_2 ] ->
          Alcotest.(check string) "col1 name" "name" field1.name;
          Alcotest.(check string) "col2 name" "email" field_2.name;
          ()
        | _ -> Alcotest.fail "insert has wrong number of columns"
      in

      ()
    | _ -> Alcotest.fail "stmt is not a select"
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
    ; "good_parse", [ "returns no error on correct query", `Quick, GoodParse.success ]
    ]
;;
