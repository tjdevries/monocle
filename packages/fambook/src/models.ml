open Drive

module User = struct
  type t =
    { id : int [@primary_key { autoincrement = true }]
    ; name : string
    ; email : string
    }
  [@@deriving table { name = "users" }]
end

module Chat = struct
  type t =
    { id : int [@primary_key { autoincrement = true }]
    ; username : string
    ; message : string
    }
  [@@deriving table { name = "chats" }]

  open Caqti_request.Infix
  open Caqti_type.Std

  type example = (unit, unit) Octane.Model.t

  let user_chats db ~username ~f =
    let query = (string ->* record) @@ "SELECT chats.* FROM chats WHERE chats.username = $1" in
    Octane.Database.iter db query username ~f
  ;;

  let user_messages db ~username =
    let query = (string ->* record) @@ "SELECT chats.* FROM chats WHERE username = $1" in
    Octane.Database.collect db query username
  ;;
end
