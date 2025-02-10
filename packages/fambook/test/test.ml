open Prelude

module Models = Fambook.Models
module Account = Models.Account
module Photo = Models.Photo

let url = Uri.of_string "postgresql://tjdevries:password@localhost:5432/fambook_dev"

let insert_user_teej db = Models.Account.insert db ~name:"tjdevries" ~email:"tjdevries@example.com"
let insert_user_prime db = Models.Account.insert db ~name:"prime" ~email:"prime@example.com"

let insert_photo db ?(comment = "Hello world") (user : Account.t) url =
  Models.Photo.insert db ~user_id:user.id ~url ~comment
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
  let> photo = insert_photo db user "https://picsum.photos/200/300" in
  Alcotest.(check int) "chat user id" user.id photo.user_id;
  Alcotest.(check string) "chat message" "Hello world" photo.comment;
  ()
;;

let fails_to_insert_chat_with_invalid_user db () =
  let> () = recreate_database db in
  match
    insert_photo
      db
      ~comment:"Hello world"
      { id = 420; name = "tjdevries"; email = "tjdevries@example.com" }
      "https://picsum.photos/200/300"
  with
  | Ok _ -> Alcotest.fail "unexpected success"
  | Error _ -> ()
;;

let%query (module PhotosForUserByID) =
  "SELECT Photo.id, Account.name, Photo.comment
    FROM Photo INNER JOIN Account ON Account.id = Photo.user_id
    WHERE Account.id = $1::int"
;;

let%query (module PhotosForUserByName) =
  "SELECT Photo.id, Account.name, Photo.comment
    FROM Photo INNER JOIN Account ON Account.id = Photo.user_id
    WHERE Account.name = $1 AND Account.name = $1"
;;

let can_retreive_with_custom_query db () =
  let> () = recreate_database db in
  let> prime = insert_user_prime db in
  let> _ = insert_photo db prime "https://picsum.photos/200/300" in
  let> _ = insert_photo db prime "https://picsum.photos/200/300" in
  let> _ = insert_photo db prime "https://picsum.photos/200/300" in
  let> user = insert_user_teej db in
  let> _ = insert_photo db user "https://picsum.photos/200/300" ~comment:"Hello world" in
  let> _ = insert_photo db user "https://picsum.photos/200/300" ~comment:"Second Message" in
  let> photos = PhotosForUserByID.query db user.id in
  let photos = Array.of_list photos in
  Alcotest.(check int) "id: photos length" 2 (Array.length photos);
  Alcotest.(check string) "id: photos.0.comment" "Hello world" photos.(0).comment;
  Alcotest.(check string) "id: photos.1.comment" "Second Message" photos.(1).comment;
  let> photos = PhotosForUserByName.query db user.name in
  let photos = Array.of_list photos in
  Alcotest.(check int) "name: photos length" 2 (Array.length photos);
  Alcotest.(check string) "name: photos.0.comment" "Hello world" photos.(0).comment;
  Alcotest.(check string) "name: photos.1.comment" "Second Message" photos.(1).comment;
  ()
;;

let%query (module PhotosForUserByNameParams) =
  "SELECT Photo.id, Account.name, Photo.comment
    FROM Photo INNER JOIN Account ON Account.id = Photo.user_id
    WHERE Account.name = $amazing AND Account.name = $redundant"
;;

let can_retrieve_with_named_params db () =
  let> () = recreate_database db in
  let> user = insert_user_teej db in
  let> _ = insert_photo db user "https://picsum.photos/200/300" ~comment:"Hello world" in
  let> _ = insert_photo db user "https://picsum.photos/200/300" ~comment:"Second Message" in
  let> photos = PhotosForUserByNameParams.query db ~amazing:user.name ~redundant:user.name in
  let photos = Array.of_list photos in
  Alcotest.(check int) "id: photos length" 2 (Array.length photos);
  Alcotest.(check string) "id: photos.0.comment" "Hello world" photos.(0).comment;
  Alcotest.(check string) "id: photos.1.comment" "Second Message" photos.(1).comment;
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
    ; Test_model.cases db
    ]
;;

let () = Eio_main.run @@ fun env -> Eio.Switch.run @@ fun sw -> main env sw
