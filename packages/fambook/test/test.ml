let ( let> ) x f =
  match x with
  | Ok x -> f x
  | Error err -> Alcotest.failf "Unexpected error: %s" (Caqti_error.show err)
;;

module Models = Fambook.Models
module Account = Models.Account
module Chat = Models.Chat

let url = Uri.of_string "postgresql://tjdevries:password@localhost:5432/fambook_dev"

let insert_user_teej db = Models.Account.insert db ~name:"tjdevries" ~email:"tjdevries@example.com"
let insert_user_prime db = Models.Account.insert db ~name:"prime" ~email:"prime@example.com"

let recreate_database db =
  let> () = Models.Account.Table.drop db in
  let> () = Models.Chat.Table.drop db in
  let> () = Models.Account.Table.create db in
  let> () = Models.Chat.Table.create db in
  Ok ()
;;

let insert_one_account db () =
  let> () = recreate_database db in
  let> account = insert_user_teej db in
  Alcotest.(check string) "account name" "tjdevries" account.name;
  Alcotest.(check string) "account email" "tjdevries@example.com" account.email;
  ()
;;

let insert_two_accounts db () =
  let> () = recreate_database db in
  let> account = insert_user_teej db in
  Alcotest.(check string) "account name" "tjdevries" account.name;
  Alcotest.(check string) "account email" "tjdevries@example.com" account.email;
  let> account = insert_user_prime db in
  Alcotest.(check string) "account name" "prime" account.name;
  Alcotest.(check string) "account email" "prime@example.com" account.email;
  ()
;;

let insert_one_chat db () =
  let> () = recreate_database db in
  let> user = Models.Account.insert db ~name:"tjdevries" ~email:"tjdevries@example.com" in
  let> chat = Models.Chat.insert db ~user_id:user.id ~message:"Hello world" in
  Alcotest.(check int) "chat user id" user.id chat.user_id;
  Alcotest.(check string) "chat message" "Hello world" chat.message;
  ()
;;

let fails_to_insert_chat_with_invalid_user db () =
  let> () = recreate_database db in
  match Models.Chat.insert db ~user_id:420 ~message:"Hello world" with
  | Ok _ -> Alcotest.fail "unexpected success"
  | Error _ -> ()
;;

let%query (module ChatsForUserByID) =
  "SELECT Chat.id, Account.name, Chat.message
    FROM Chat INNER JOIN Account ON Account.id = Chat.user_id
    WHERE Account.id = $1::int"
;;

let%query (module ChatsForUserByName) =
  "SELECT Chat.id, Account.name, Chat.message
    FROM Chat INNER JOIN Account ON Account.id = Chat.user_id
    WHERE Account.name = $1 AND Account.name = $1"
;;

let can_retreive_with_custom_query db () =
  let> () = recreate_database db in
  let> prime = insert_user_prime db in
  let> _ = Chat.insert db ~user_id:prime.id ~message:"<not included>" in
  let> _ = Chat.insert db ~user_id:prime.id ~message:"<not included>" in
  let> _ = Chat.insert db ~user_id:prime.id ~message:"<not included>" in
  let> user = insert_user_teej db in
  let> _ = Chat.insert db ~user_id:user.id ~message:"Hello world" in
  let> _ = Chat.insert db ~user_id:user.id ~message:"Second Message" in
  let> chats = ChatsForUserByID.query db user.id in
  let chats = Array.of_list chats in
  Alcotest.(check int) "id: chats length" 2 (Array.length chats);
  Alcotest.(check string) "id: chats.0.message" "Hello world" chats.(0).message;
  Alcotest.(check string) "id: chats.1.message" "Second Message" chats.(1).message;
  let> chats = ChatsForUserByName.query db user.name in
  let chats = Array.of_list chats in
  Alcotest.(check int) "name: chats length" 2 (Array.length chats);
  Alcotest.(check string) "name: chats.0.message" "Hello world" chats.(0).message;
  Alcotest.(check string) "name: chats.1.message" "Second Message" chats.(1).message;
  ()
;;

let%query (module ChatsForUserByNameParams) =
  "SELECT Chat.id, Account.name, Chat.message
    FROM Chat INNER JOIN Account ON Account.id = Chat.user_id
    WHERE Account.name = $amazing AND Account.name = $redundant"
;;

let can_retrieve_with_named_params db () =
  let> () = recreate_database db in
  let> user = insert_user_teej db in
  let> _ = Chat.insert db ~user_id:user.id ~message:"Hello world" in
  let> _ = Chat.insert db ~user_id:user.id ~message:"Second Message" in
  let> chats = ChatsForUserByNameParams.query db ~amazing:user.name ~redundant:user.name in
  let chats = Array.of_list chats in
  Alcotest.(check int) "id: chats length" 2 (Array.length chats);
  Alcotest.(check string) "id: chats.0.message" "Hello world" chats.(0).message;
  Alcotest.(check string) "id: chats.1.message" "Second Message" chats.(1).message;
  ()
;;

let main env sw =
  let> db = Octane.Database.connect ~sw ~env url in
  Alcotest.run
    "fambook"
    [ ( "accounts"
      , [ "can insert", `Quick, insert_one_account db
        ; "can insert two accounts", `Quick, insert_two_accounts db
        ] )
    ; ( "chats"
      , [ "can insert", `Quick, insert_one_chat db
        ; "fails to insert with invalid user", `Quick, fails_to_insert_chat_with_invalid_user db
        ] )
    ; ( "custom query"
      , [ "can retrieve with custom query", `Quick, can_retreive_with_custom_query db
        ; "can retrieve with named params", `Quick, can_retrieve_with_named_params db
        ] )
    ; Test_transform.cases
    ]
;;

let () = Eio_main.run @@ fun env -> Eio.Switch.run @@ fun sw -> main env sw
