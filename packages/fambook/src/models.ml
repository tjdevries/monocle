open Drive

type 'a unfetched = [ `unfetched of 'a ]
type 'a fetched = [ `fetched of 'a ]
type ('id, 'model) fetch =
  [ 'id unfetched
  | 'model fetched
  ]

module User = struct
  type t =
    { id : int [@primary_key { autoincrement = true }]
    ; name : string
    ; email : string
    }
  [@@deriving table { name = "users" }]

  module Params = struct
    include Params

    let t user = user.id
  end

  module Model = struct
    type user = t
    type t = (int, user) fetch

    let fetch db (model : t) : user fetched =
      match model with
      | `unfetched id -> failwith "TODO"
      | `fetched _ as model -> model
    ;;

    let unwrap (model : user fetched) =
      match model with
      | `fetched model -> model
    ;;

    let id model =
      match model with
      | `unfetched id -> id
      | `fetched { id; _ } -> id
    ;;

    let name (model : user fetched) =
      match model with
      | `fetched { name; _ } -> name
    ;;

    let example db =
      let model = `unfetched 1 in
      let model = fetch db model in
      name model
    ;;

    let example db =
      let model = `unfetched 1 in
      let model = fetch db model in
      let model = unwrap model in
      model.name
    ;;
  end
end

module Message = struct
  open Caqti_request.Infix
  open Caqti_type.Std

  type t =
    { id : int [@primary_key { autoincrement = true }]
    ; user : User.Model.t
    ; message : string
    }
  [@@deriving table { name = "messages" }]
end

(* CLASSIC ORM FAILURE PATH!!!!!
   let get_all_chats db = Db.iter (fun chat ->
   print(chat.user.name);
   ())
   ...)
*)

module Chat = struct
  open Caqti_request.Infix
  open Caqti_type.Std

  type t =
    { id : int [@primary_key { autoincrement = true }]
    ; username : string
    ; message : string
    }
  [@@deriving table { name = "chats" }]

  let user_chats db ~username ~f =
    let query = (string ->* record) @@ "SELECT chats.* FROM chats WHERE chats.username = $1" in
    Database.iter db query username ~f
  ;;

  let user_messages db ~username =
    let query = (string ->* record) @@ "SELECT chats.* FROM chats WHERE username = $1" in
    Database.collect db query username
  ;;
end
