open Prelude

module Models = Fambook.Models
module Account = Models.Account
module Photo = Models.Photo

let%query (module AccountStar) = "SELECT Account.* FROM Account"

let returns_empty db () =
  let> () = recreate_database db in
  let> result = AccountStar.query db in
  Alcotest.(check int) "Empty list" 0 (List.length result)
;;

let returns_single_account db () =
  let> () = recreate_database db in
  let> account = Account.insert db ~name:"user1" ~email:"user1@example.com" in
  let> result = AccountStar.query db in
  Alcotest.(check int) "single item in list" 1 (List.length result)
;;

let%query (module PhotoAccountJoin) =
  "SELECT Photo.*, Account.* /* Look! We load the whole model into `.account` field */
    FROM Photo INNER JOIN Account ON Account.id = Photo.user_id"
;;

let returns_single_photo db () =
  let> () = recreate_database db in
  let> user = Account.insert db ~name:"user1" ~email:"user1@example.com" in
  let> photo = Photo.insert db ~user_id:user.id ~url:"phot-url" ~comment:"Hello world" in
  let> result = PhotoAccountJoin.query db in
  Alcotest.(check int) "single item in list" 1 (List.length result);
  let item = List.hd result in
  Alcotest.(check string) "gets user name" "user1" item.account.name
;;

let returns_multiple_photos db () =
  let> () = recreate_database db in
  let> user = Account.insert db ~name:"user1" ~email:"user1@example.com" in
  let> photo = Photo.insert db ~user_id:user.id ~url:"photo1" ~comment:"Hello world" in
  let> photo = Photo.insert db ~user_id:user.id ~url:"photo2" ~comment:"Hello world" in
  let> photo = Photo.insert db ~user_id:user.id ~url:"photo3" ~comment:"Hello world" in
  let> result = PhotoAccountJoin.query db in
  Alcotest.(check int) "three items in list" 3 (List.length result);
  let item = List.hd result in
  Alcotest.(check string) "gets user name" "user1" item.account.name;
  Alcotest.(check string) "gets photo url" "photo1" item.photo.url
;;

let cases db =
  ( "model"
  , [ "returns empty when no results", `Quick, returns_empty db
    ; "returns single account", `Quick, returns_single_account db
    ; "returns single photo", `Quick, returns_single_photo db
    ; "returns multiple photos", `Quick, returns_multiple_photos db
    ] )
;;
