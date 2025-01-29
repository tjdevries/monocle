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
  let insert () =
    let open PGQuery.ProtobufGen in
    let (result : PGQuery.ProtobufGen.parse_result) =
      PGQuery.Protobuf.parse "INSERT INTO users (name, email) VALUES (?, ?) RETURNING id"
      |> Result.get_ok
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

  let select () =
    let open PGQuery.ProtobufGen in
    Fmt.epr "SELECT...@.";
    let (result : PGQuery.ProtobufGen.parse_result) =
      PGQuery.Protobuf.parse
        {|SELECT Something.id, Something.name FROM Something WHERE Something.id = 5;|}
      |> Result.get_ok
    in
    Alcotest.(check int) "has one statement" 1 (List.length result.stmts);
    Fmt.epr "%a@." PGQuery.ProtobufGen.pp_parse_result result;
    let stmt = List.hd result.stmts in
    match stmt.stmt with
    | Some (Select_stmt select) ->
      let () =
        match select.from_clause with
        | [ Range_var { relname = "Something"; _ } ] -> ()
        | _ -> Alcotest.fail "No 'Something' table"
      in
      (* let () = *)
      (*   match select.where with *)
      (*   | Some (Where_clause (Binary_expression (left, Eq, right))) -> *)
      (*     Alcotest.(check string) "left" "id" left.name; *)
      (*     Alcotest.(check string) "right" "1" right.value; *)
      (*     () *)
      (*   | _ -> Alcotest.fail "select has wrong number of columns" *)
      (* in *)
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
    ; ( "good_parse"
      , [ "returns no error on correct query", `Quick, GoodParse.insert
        ; "can do select statement", `Quick, GoodParse.select
        ] )
    ]
;;
