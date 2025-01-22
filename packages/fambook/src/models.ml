module User = struct
  type t =
    { id : int
    ; name : string
    ; email : string
    }

  let create ~id ~name ~email = { id; name; email }
end

module Chat = struct
  open Caqti_request.Infix
  open Caqti_type.Std

  type t =
    { username : string
    ; message : string
    }

  let drop db = Database.exec db ((unit ->. unit) "DROP TABLE IF EXISTS chats") ()

  let create db =
    let query =
      (unit ->. unit)
      @@ "CREATE TABLE IF NOT EXISTS chats (id serial PRIMARY KEY, username TEXT NOT NULL, message TEXT NOT NULL)"
    in
    Database.exec db query ()
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
