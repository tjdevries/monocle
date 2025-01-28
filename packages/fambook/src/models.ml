open Drive

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
    type nonrec t = (int, t) Octane.Model.t

    let name model = (Octane.Model.unwrap model).name

    let example db =
      let model = `id 1 in
      let model = Octane.Model.fetch db model in
      name model
    ;;

    let example db =
      let open Octane.Model in
      let model = `id 1 in
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

  type example = (unit, unit) Octane.Model.t

  type t =
    { id : int [@primary_key { autoincrement = true }]
    ; username : string
    ; message : string
    }
  [@@deriving table { name = "chats" }]

  let user_chats db ~username ~f =
    let query = (string ->* record) @@ "SELECT chats.* FROM chats WHERE chats.username = $1" in
    Octane.Database.iter db query username ~f
  ;;

  let user_messages db ~username =
    let query = (string ->* record) @@ "SELECT chats.* FROM chats WHERE username = $1" in
    Octane.Database.collect db query username
  ;;
end
