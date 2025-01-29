open Drive

(*
   user: User.Model.t
user: User.t [@model]
user: User.Model.t [@foreign { on_cascade = "delete" }]

chat.user : User.Model.t
| `id of id
| `model of (id, User.Model.t)

Constraints:
- I don't want to be able to accidentally load another model
- If something is already loaded, don't load it again
- Ideally, I want to know in the type system whether it's loaded or not
- User must not have to type crazy type signatures to get this to work


states of a model:
  - `id only have the id
  - `model only have this model
  - `assoc have this model and foreign models

   Load chats:
- Get all the chats for a user, but don't load the user - we already have the user
- Get all the chats within last day, load the user for each chat

Possible solution, is all of the modesl ONLY have the id. ALWAYS.
- When writing queries, you can write a query to actually load the model.
  - We give you the tools to make that really easy.
*)

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
    ; user_id : User.Fields.id [@foreign { on_cascade = `delete }]
    ; message : string
    }
  [@@deriving table { name = "chats" }]

  open Caqti_request.Infix
  open Caqti_type.Std

  module Model = struct
    type t =
      { id : int
      ; user : User.t
      ; message : string
      }

    let model =
      let model id user message = { id; message; user } in
      product model
      @@ proj Params.id (fun record -> record.id)
      @@ proj User.record (fun record -> record.user)
      @@ proj Params.message (fun record -> record.message)
      @@ proj_end
    ;;

    let read db id : (t option, 'a) result =
      let query =
        (Params.id ->? model)
        @@ "SELECT chats.id, users.*, chats.message
             FROM chats INNER JOIN users ON chats.user_id = users.id
             WHERE chats.id = $1"
      in
      Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find_opt query id) db
    ;;
  end

  let user_chats db ~user_id ~f =
    let query =
      (User.Params.id ->* record) @@ "SELECT chats.* FROM chats WHERE chats.user_id = $1"
    in
    Octane.Database.iter db query user_id ~f
  ;;
end

(* let%query (module UserMessages) = *)
(*   "SELECT Chat.*, User.* FROM Chat INNER JOIN User ON Chat.user_id = User.id" *)
(* ;; *)
