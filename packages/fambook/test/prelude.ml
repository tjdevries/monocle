let ( let> ) x f =
  match x with
  | Ok x -> f x
  | Error err -> Alcotest.failf "Unexpected error: %s" (Caqti_error.show err)
;;

module Models = Fambook.Models
module Account = Models.Account
module Photo = Models.Photo

let recreate_database db =
  let> () = Models.Account.Table.drop db in
  let> () = Models.Photo.Table.drop db in
  let> () = Models.Account.Table.create db in
  let> () = Models.Photo.Table.create db in
  Ok ()
;;
