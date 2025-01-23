open Drive

module User = struct
  type t =
    { id : int
    ; name : string
    ; email : string
    }

  let create ~id ~name ~email = { id; name; email }
end

(*
   this is what i want to do:

module Chat = struct
  type t = { username : string; message: string }
  [@@deriving table]

  (* ... generated ... *)
  let drop pool = ...
  let create pool = ...

  module Labels = struct
    let insert pool ~username ~messages = ...
  end

  module Record = struct
    let insert pool (record : t) = ...
  end
end
*)

module Chat = struct
  open Caqti_request.Infix
  open Caqti_type.Std

  type t =
    { username : string
    ; message : string
    }

  let drop pool = Database.exec pool ((unit ->. unit) "DROP TABLE IF EXISTS chats") ()

  let create pool =
    let query =
      (unit ->. unit)
      @@ "CREATE TABLE IF NOT EXISTS chats (id serial PRIMARY KEY, username TEXT NOT NULL, message TEXT NOT NULL)"
    in
    Database.exec pool query ()
  ;;

  let insert db ~username ~message =
    let query =
      (t2 string string ->. unit) @@ "INSERT INTO chats (username, message) VALUES ($1, $2)"
    in
    Database.exec db query (username, message)
  ;;

  let user_chats db ~username ~f =
    let query =
      (string ->* t3 int string string)
      @@ "SELECT id, username, message FROM chats WHERE username = $1"
    in
    Database.iter db query username ~f
  ;;
end
