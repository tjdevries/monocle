let () =
  let env = function
    | "cool" -> Caqti_query.L "Cool"
    | "world" -> Caqti_query.L "World"
    | _ -> failwith "OH NO"
  in
  let q =
    "asdfasdf * FROM users WHERE $(cool)" |> Caqti_query.of_string_exn |> Caqti_query.expand env
  in
  let _ = Caqti_query.L "Hello" in
  ()
;;
