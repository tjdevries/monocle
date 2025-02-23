Pretty print the file

  $ pp_query ./lib/table.ml > ./lib/table-generated.ml
  $ ocamlformat ./lib/table-generated.ml
  module Account = struct
    type t =
      { id : int [@primary_key { autoincrement = true }]
      ; name : string
      ; age : int
      }
    [@@deriving table { name = "accounts" }]
  
    include struct
      [@@@ocaml.warning "-60"]
  
      let _ = fun (_ : t) -> ()
  
      open Caqti_request.Infix
      open Caqti_type.Std
  
      module Fields = struct
        let id = "id"
        let _ = id
        let name = "name"
        let _ = name
        let age = "age"
        let _ = age
  
        type id = int
        type name = string
        type age = int
      end
  
      module Params = struct
        let id = Caqti_type.Std.int
        let _ = id
        let name = Caqti_type.Std.string
        let _ = name
        let age = Caqti_type.Std.int
        let _ = age
  
        type id = int
        type name = string
        type age = int
      end
  
      module Table = struct
        let drop = (unit ->. unit) @@ "DROP TABLE IF EXISTS accounts CASCADE"
        let _ = drop
        let drop db = Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec drop ()) db
        let _ = drop
  
        let create =
          (unit ->. unit)
          @@ "CREATE TABLE accounts (id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, name TEXT NOT NULL, age \
              INTEGER NOT NULL)"
        ;;
  
        let _ = create
        let create db = Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec create ()) db
        let _ = create
      end
  
      let relation = "accounts"
      let _ = relation
  
      let record =
        let record id name age = { id; name; age } in
        product record
        @@ proj
             Params.id
             (fun record -> record.id)
             (proj Params.name (fun record -> record.name) (proj Params.age (fun record -> record.age) proj_end))
      ;;
  
      let _ = record
  
      let insert ~name ~age db =
        let query =
          (t2 Params.name Params.age ->! record) @@ "INSERT INTO accounts (name, age) VALUES (?, ?) RETURNING *"
        in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find query (name, age)) db
      ;;
  
      let _ = insert
  
      let read db id =
        let query = (Params.id ->? record) @@ "SELECT * FROM accounts WHERE accounts.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find_opt query id) db
      ;;
  
      let _ = read
  
      let update db t =
        let query = (record ->. unit) @@ "UPDATE accounts SET name = $2, age = $3 WHERE accounts.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec query t) db
      ;;
  
      let _ = update
  
      let delete db id =
        let query = (Params.id ->. unit) @@ "DELETE FROM accounts WHERE accounts.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec query id) db
      ;;
  
      let _ = delete
    end [@@ocaml.doc "@inline"] [@@merlin.hide]
  end
  
  module AccountNameQuery = struct
    open Caqti_request.Infix
    open Caqti_type.Std
  
    type t =
      { id : Account.Fields.id
      ; name : Account.Fields.name
      }
  
    let record =
      let record id name = { id; name } in
      product record
      @@ proj Account.Params.id (fun record -> record.id) (proj Account.Params.name (fun record -> record.name) proj_end)
    ;;
  
    let query db =
      let open Caqti_request.Infix in
      let open Caqti_type.Std in
      let query =
        (unit ->* record)
        @@ Stdlib.Format.sprintf
             "SELECT %s FROM %s %s"
             (Stdlib.String.concat
                ", "
                [ Stdlib.Format.sprintf "%s.%s" Account.relation "id"
                ; Stdlib.Format.sprintf "%s.%s" Account.relation "name"
                ])
             (Core.String.concat ~sep:", " [ Account.relation ])
             ""
      in
      let params = () in
      Octane.Database.collect db query params
    ;;
  
    let raw = "SELECT Account.id, Account.name FROM Account"
  end [@warning "-32"]
< language: ocaml

  $ pp_query ./lib/where_id.ml | ocamlformat --impl -
  module Account = struct
    type t = { id : int } [@@deriving table { name = "users" }]
  
    include struct
      [@@@ocaml.warning "-60"]
  
      let _ = fun (_ : t) -> ()
  
      open Caqti_request.Infix
      open Caqti_type.Std
  
      module Fields = struct
        let id = "id"
        let _ = id
  
        type id = int
      end
  
      module Params = struct
        let id = Caqti_type.Std.int
        let _ = id
  
        type id = int
      end
  
      module Table = struct
        let drop = (unit ->. unit) @@ "DROP TABLE IF EXISTS users CASCADE"
        let _ = drop
        let drop db = Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec drop ()) db
        let _ = drop
        let create = (unit ->. unit) @@ "CREATE TABLE users (id INTEGER NOT NULL)"
        let _ = create
        let create db = Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec create ()) db
        let _ = create
      end
  
      let relation = "users"
      let _ = relation
  
      let record =
        let record id = { id } in
        product record @@ proj Params.id (fun record -> record.id) proj_end
      ;;
  
      let _ = record
  
      let insert ~id db =
        let query = (Params.id ->! record) @@ "INSERT INTO users (id) VALUES (?) RETURNING *" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find query id) db
      ;;
  
      let _ = insert
      let () = ()
      let () = ()
      let () = ()
    end [@@ocaml.doc "@inline"] [@@merlin.hide]
  end
  
  module AccountByID = struct
    open Caqti_request.Infix
    open Caqti_type.Std
  
    type t =
      { id : Account.Fields.id
      ; name : Account.Fields.name
      }
  
    let record =
      let record id name = { id; name } in
      product record
      @@ proj Account.Params.id (fun record -> record.id) (proj Account.Params.name (fun record -> record.name) proj_end)
    ;;
  
    let query db p1 =
      let open Caqti_request.Infix in
      let open Caqti_type.Std in
      let query =
        (Account.Params.id ->* record)
        @@ Stdlib.Format.sprintf
             "SELECT %s FROM %s %s"
             (Stdlib.String.concat
                ", "
                [ Stdlib.Format.sprintf "%s.%s" Account.relation "id"
                ; Stdlib.Format.sprintf "%s.%s" Account.relation "name"
                ])
             (Core.String.concat ~sep:", " [ Account.relation ])
             (Stdlib.Format.sprintf
                "WHERE %s"
                (Stdlib.Format.sprintf
                   "(%s %s %s)"
                   (Stdlib.Format.sprintf "%s.%s" Account.relation "id")
                   "="
                   (Stdlib.Format.sprintf "($%d)" 1)))
      in
      let params = p1 in
      Octane.Database.collect db query params
    ;;
  
    let raw = "SELECT Account.id, Account.name FROM Account WHERE Account.id = $1"
  end [@warning "-32"]
< language: ocaml

  $ pp_query ./lib/where_positional.ml | ocamlformat --impl -
  module Account = struct
    type t =
      { id : int
      ; name : string
      }
    [@@deriving table { name = "users" }]
  
    include struct
      [@@@ocaml.warning "-60"]
  
      let _ = fun (_ : t) -> ()
  
      open Caqti_request.Infix
      open Caqti_type.Std
  
      module Fields = struct
        let id = "id"
        let _ = id
        let name = "name"
        let _ = name
  
        type id = int
        type name = string
      end
  
      module Params = struct
        let id = Caqti_type.Std.int
        let _ = id
        let name = Caqti_type.Std.string
        let _ = name
  
        type id = int
        type name = string
      end
  
      module Table = struct
        let drop = (unit ->. unit) @@ "DROP TABLE IF EXISTS users CASCADE"
        let _ = drop
        let drop db = Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec drop ()) db
        let _ = drop
        let create = (unit ->. unit) @@ "CREATE TABLE users (id INTEGER NOT NULL, name TEXT NOT NULL)"
        let _ = create
        let create db = Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec create ()) db
        let _ = create
      end
  
      let relation = "users"
      let _ = relation
  
      let record =
        let record id name = { id; name } in
        product record @@ proj Params.id (fun record -> record.id) (proj Params.name (fun record -> record.name) proj_end)
      ;;
  
      let _ = record
  
      let insert ~id ~name db =
        let query = (t2 Params.id Params.name ->! record) @@ "INSERT INTO users (id, name) VALUES (?, ?) RETURNING *" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find query (id, name)) db
      ;;
  
      let _ = insert
      let () = ()
      let () = ()
      let () = ()
    end [@@ocaml.doc "@inline"] [@@merlin.hide]
  end
  
  module AccountByID = struct
    open Caqti_request.Infix
    open Caqti_type.Std
  
    type t = { name : Account.Fields.name }
  
    let record =
      let record name = { name } in
      product record @@ proj Account.Params.name (fun record -> record.name) proj_end
    ;;
  
    let query db p1 =
      let open Caqti_request.Infix in
      let open Caqti_type.Std in
      let query =
        (int ->* record)
        @@ Stdlib.Format.sprintf
             "SELECT %s FROM %s %s"
             (Stdlib.String.concat ", " [ Stdlib.Format.sprintf "%s.%s" Account.relation "name" ])
             (Core.String.concat ~sep:", " [ Account.relation ])
             (Stdlib.Format.sprintf
                "WHERE %s"
                (Stdlib.Format.sprintf
                   "(%s %s %s)"
                   (Stdlib.Format.sprintf "%s.%s" Account.relation "id")
                   "="
                   (Stdlib.Format.sprintf "($%d::%s)" 1 "int")))
      in
      let params = p1 in
      Octane.Database.collect db query params
    ;;
  
    let raw = "SELECT Account.name FROM Account WHERE Account.id = $1::int"
  end [@warning "-32"]
< language: ocaml

  $ pp_query ./lib/invalid_model.ml | ocamlformat --impl -
  module ShouldError = struct
    open Caqti_request.Infix
    open Caqti_type.Std
  
    type t = { id : Post.Fields.id }
  
    let record =
      let record id = { id } in
      product record @@ proj Post.Params.id (fun record -> record.id) proj_end
    ;;
  
    let query db =
      let open Caqti_request.Infix in
      let open Caqti_type.Std in
      let query =
        (unit ->* record)
        @@ Stdlib.Format.sprintf
             "SELECT %s FROM %s %s"
             (Stdlib.String.concat ", " [ Stdlib.Format.sprintf "%s.%s" Post.relation "id" ])
             (Core.String.concat ~sep:", " [ Account.relation ])
             ""
      in
      let params = () in
      Octane.Database.collect db query params
    ;;
  
    let raw = "SELECT Post.id from Account"
  end [@warning "-32"]
< language: ocaml

  $ pp_query ./lib/simple_join.ml | ocamlformat --impl -
  module AuthorAndContent = struct
    open Caqti_request.Infix
    open Caqti_type.Std
  
    type t =
      { name : Account.Fields.name
      ; content : Post.Fields.content
      }
  
    let record =
      let record name content = { name; content } in
      product record
      @@ proj
           Account.Params.name
           (fun record -> record.name)
           (proj Post.Params.content (fun record -> record.content) proj_end)
    ;;
  
    let query db =
      let open Caqti_request.Infix in
      let open Caqti_type.Std in
      let query =
        (unit ->* record)
        @@ Stdlib.Format.sprintf
             "SELECT %s FROM %s %s"
             (Stdlib.String.concat
                ", "
                [ Stdlib.Format.sprintf "%s.%s" Account.relation "name"
                ; Stdlib.Format.sprintf "%s.%s" Post.relation "content"
                ])
             (Stdlib.Format.sprintf
                "%s %s %s ON %s"
                Post.relation
                "INNER JOIN"
                Account.relation
                (Stdlib.Format.sprintf
                   "(%s %s %s)"
                   (Stdlib.Format.sprintf "%s.%s" Account.relation "id")
                   "="
                   (Stdlib.Format.sprintf "%s.%s" Post.relation "author")))
             ""
      in
      let params = () in
      Octane.Database.collect db query params
    ;;
  
    let raw = " SELECT Account.name, Post.content FROM Post INNER JOIN Account ON Account.id = Post.author "
  end [@warning "-32"]
< language: ocaml

  $ pp_query ./lib/missing_name.ml | ocamlformat --impl -
  module Account = struct
    type t =
      { id : int [@primary_key { autoincrement = true }]
      ; name : string
      ; middle_name : string option
      }
    [@@deriving table { named = "users" }]
  
    include struct
      let _ = fun (_ : t) -> ()
  
      [%%ocaml.error "Ppxlib.Deriving: generator 'table' doesn't accept argument 'named'.\nHint: Did you mean name?"]
    end [@@ocaml.doc "@inline"] [@@merlin.hide]
  end
< language: ocaml

  $ pp_query ./lib/error__multiple_types.ml | ocamlformat --impl -
  File "./lib/error__multiple_types.ml", lines 2-8, characters 2-60:
  2 | ..type t =
  3 |     { id : int [@primary_key { autoincrement = true }]
  4 |     ; name : string
  5 |     ; middle_name : string option
  6 |     }
  7 | 
  8 |   and x = { id : int } [@@deriving table { name = "users" }]
  Error: ppx_table requires exactly one type declaration
< language: ocaml

  $ pp_query ./lib/optional_field.ml | ocamlformat --impl -
  module OptionalField = struct
    type t =
      { id : int [@primary_key { autoincrement = true }]
      ; optional : string option
      }
    [@@deriving table { name = "optional_field" }]
  
    include struct
      [@@@ocaml.warning "-60"]
  
      let _ = fun (_ : t) -> ()
  
      open Caqti_request.Infix
      open Caqti_type.Std
  
      module Fields = struct
        let id = "id"
        let _ = id
        let optional = "optional"
        let _ = optional
  
        type id = int
        type optional = string option
      end
  
      module Params = struct
        let id = Caqti_type.Std.int
        let _ = id
  
        let optional =
          let open Caqti_type.Std in
          option string
        ;;
  
        let _ = optional
  
        type id = int
        type optional = string option
      end
  
      module Table = struct
        let drop = (unit ->. unit) @@ "DROP TABLE IF EXISTS optional_field CASCADE"
        let _ = drop
        let drop db = Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec drop ()) db
        let _ = drop
  
        let create =
          (unit ->. unit)
          @@ "CREATE TABLE optional_field (id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, optional TEXT )"
        ;;
  
        let _ = create
        let create db = Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec create ()) db
        let _ = create
      end
  
      let relation = "optional_field"
      let _ = relation
  
      let record =
        let record id optional = { id; optional } in
        product record
        @@ proj Params.id (fun record -> record.id) (proj Params.optional (fun record -> record.optional) proj_end)
      ;;
  
      let _ = record
  
      let insert ?optional db =
        let query = (Params.optional ->! record) @@ "INSERT INTO optional_field (optional) VALUES (?) RETURNING *" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find query optional) db
      ;;
  
      let _ = insert
  
      let read db id =
        let query = (Params.id ->? record) @@ "SELECT * FROM optional_field WHERE optional_field.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find_opt query id) db
      ;;
  
      let _ = read
  
      let update db t =
        let query = (record ->. unit) @@ "UPDATE optional_field SET optional = $2 WHERE optional_field.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec query t) db
      ;;
  
      let _ = update
  
      let delete db id =
        let query = (Params.id ->. unit) @@ "DELETE FROM optional_field WHERE optional_field.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec query id) db
      ;;
  
      let _ = delete
    end [@@ocaml.doc "@inline"] [@@merlin.hide]
  end
< language: ocaml

  $ pp_query ./lib/foreign.ml | ocamlformat --impl -
  module Account = struct
    type t =
      { id : int [@primary_key { autoincrement = true }]
      ; name : string
      }
    [@@deriving table { name = "users" }]
  
    include struct
      [@@@ocaml.warning "-60"]
  
      let _ = fun (_ : t) -> ()
  
      open Caqti_request.Infix
      open Caqti_type.Std
  
      module Fields = struct
        let id = "id"
        let _ = id
        let name = "name"
        let _ = name
  
        type id = int
        type name = string
      end
  
      module Params = struct
        let id = Caqti_type.Std.int
        let _ = id
        let name = Caqti_type.Std.string
        let _ = name
  
        type id = int
        type name = string
      end
  
      module Table = struct
        let drop = (unit ->. unit) @@ "DROP TABLE IF EXISTS users CASCADE"
        let _ = drop
        let drop db = Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec drop ()) db
        let _ = drop
  
        let create =
          (unit ->. unit)
          @@ "CREATE TABLE users (id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, name TEXT NOT NULL)"
        ;;
  
        let _ = create
        let create db = Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec create ()) db
        let _ = create
      end
  
      let relation = "users"
      let _ = relation
  
      let record =
        let record id name = { id; name } in
        product record @@ proj Params.id (fun record -> record.id) (proj Params.name (fun record -> record.name) proj_end)
      ;;
  
      let _ = record
  
      let insert ~name db =
        let query = (Params.name ->! record) @@ "INSERT INTO users (name) VALUES (?) RETURNING *" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find query name) db
      ;;
  
      let _ = insert
  
      let read db id =
        let query = (Params.id ->? record) @@ "SELECT * FROM users WHERE users.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find_opt query id) db
      ;;
  
      let _ = read
  
      let update db t =
        let query = (record ->. unit) @@ "UPDATE users SET name = $2 WHERE users.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec query t) db
      ;;
  
      let _ = update
  
      let delete db id =
        let query = (Params.id ->. unit) @@ "DELETE FROM users WHERE users.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec query id) db
      ;;
  
      let _ = delete
    end [@@ocaml.doc "@inline"] [@@merlin.hide]
  end
  
  module Post = struct
    type t =
      { id : int [@primary_key { autoincrement = true }]
      ; user_id : Account.Fields.id [@foreign { on_cascade = `delete }]
      ; content : string
      }
    [@@deriving table { name = "posts" }]
  
    include struct
      [@@@ocaml.warning "-60"]
  
      let _ = fun (_ : t) -> ()
  
      open Caqti_request.Infix
      open Caqti_type.Std
  
      module Fields = struct
        let id = "id"
        let _ = id
        let user_id = "user_id"
        let _ = user_id
        let content = "content"
        let _ = content
  
        type id = int
        type user_id = Account.Fields.id
        type content = string
      end
  
      module Params = struct
        let id = Caqti_type.Std.int
        let _ = id
        let user_id = Account.Params.id
        let _ = user_id
        let content = Caqti_type.Std.string
        let _ = content
  
        type id = int
        type user_id = Account.Fields.id
        type content = string
      end
  
      module Table = struct
        let drop = (unit ->. unit) @@ "DROP TABLE IF EXISTS posts CASCADE"
        let _ = drop
        let drop db = Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec drop ()) db
        let _ = drop
  
        let create =
          (unit ->. unit)
          @@ "CREATE TABLE posts (id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, user_id INTEGER NOT NULL, content \
              TEXT NOT NULL)"
        ;;
  
        let _ = create
        let create db = Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec create ()) db
        let _ = create
      end
  
      let relation = "posts"
      let _ = relation
  
      let record =
        let record id user_id content = { id; user_id; content } in
        product record
        @@ proj
             Params.id
             (fun record -> record.id)
             (proj
                Params.user_id
                (fun record -> record.user_id)
                (proj Params.content (fun record -> record.content) proj_end))
      ;;
  
      let _ = record
  
      let insert ~user_id ~content db =
        let query =
          (t2 Params.user_id Params.content ->! record)
          @@ "INSERT INTO posts (user_id, content) VALUES (?, ?) RETURNING *"
        in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find query (user_id, content)) db
      ;;
  
      let _ = insert
  
      let read db id =
        let query = (Params.id ->? record) @@ "SELECT * FROM posts WHERE posts.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find_opt query id) db
      ;;
  
      let _ = read
  
      let update db t =
        let query = (record ->. unit) @@ "UPDATE posts SET user_id = $2, content = $3 WHERE posts.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec query t) db
      ;;
  
      let _ = update
  
      let delete db id =
        let query = (Params.id ->. unit) @@ "DELETE FROM posts WHERE posts.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec query id) db
      ;;
  
      let _ = delete
    end [@@ocaml.doc "@inline"] [@@merlin.hide]
  end
< language: ocaml

  $ pp_query ./lib/anded_join.ml | ocamlformat --impl -
  module ChatsForUserByName = struct
    open Caqti_request.Infix
    open Caqti_type.Std
  
    type t =
      { id : Chat.Fields.id
      ; name : Account.Fields.name
      ; message : Chat.Fields.message
      }
  
    let record =
      let record id name message = { id; name; message } in
      product record
      @@ proj
           Chat.Params.id
           (fun record -> record.id)
           (proj
              Account.Params.name
              (fun record -> record.name)
              (proj Chat.Params.message (fun record -> record.message) proj_end))
    ;;
  
    let query db p1 p2 =
      let open Caqti_request.Infix in
      let open Caqti_type.Std in
      let query =
        (t2 Account.Params.name Account.Params.id ->* record)
        @@ Stdlib.Format.sprintf
             "SELECT %s FROM %s %s"
             (Stdlib.String.concat
                ", "
                [ Stdlib.Format.sprintf "%s.%s" Chat.relation "id"
                ; Stdlib.Format.sprintf "%s.%s" Account.relation "name"
                ; Stdlib.Format.sprintf "%s.%s" Chat.relation "message"
                ])
             (Stdlib.Format.sprintf
                "%s %s %s ON %s"
                Chat.relation
                "INNER JOIN"
                Account.relation
                (Stdlib.Format.sprintf
                   "(%s %s %s)"
                   (Stdlib.Format.sprintf "%s.%s" Account.relation "id")
                   "="
                   (Stdlib.Format.sprintf "%s.%s" Chat.relation "user_id")))
             (Stdlib.Format.sprintf
                "WHERE %s"
                (Stdlib.Format.sprintf
                   "(%s %s %s)"
                   (Stdlib.Format.sprintf
                      "(%s %s %s)"
                      (Stdlib.Format.sprintf "%s.%s" Account.relation "name")
                      "="
                      (Stdlib.Format.sprintf "($%d)" 1))
                   "AND"
                   (Stdlib.Format.sprintf
                      "(%s %s %s)"
                      (Stdlib.Format.sprintf "%s.%s" Account.relation "id")
                      "="
                      (Stdlib.Format.sprintf "($%d)" 2))))
      in
      let params = p1, p2 in
      Octane.Database.collect db query params
    ;;
  
    let raw =
      "SELECT Chat.id, Account.name, Chat.message\n\
      \    FROM Chat INNER JOIN Account ON Account.id = Chat.user_id\n\
      \    WHERE Account.name = $1 AND Account.id = $2"
    ;;
  end [@warning "-32"]
< language: ocaml


  $ pp_query ./lib/model_star.ml > ./lib/model_star_generated.ml
  $ cat ./lib/model_star_generated.ml
  module AccountNameQuery =
    ((struct
        open Caqti_request.Infix
        open Caqti_type.Std
        type t = {
          account: Account.t }
        let record =
          let record account = { account } in
          (product record) @@
            (proj Account.record (fun record -> record.account) proj_end)
        let query db =
          let open Caqti_request.Infix in
            let open Caqti_type.Std in
              let query =
                (unit ->* record) @@
                  (Stdlib.Format.sprintf "SELECT %s FROM %s %s"
                     (Stdlib.String.concat ", "
                        [Stdlib.Format.sprintf "%s.%s" Account.relation "*"])
                     (Core.String.concat ~sep:", " [Account.relation]) "") in
              let params = () in Octane.Database.collect db query params
        let raw = "SELECT Account.* FROM Account"
      end)[@warning "-32"])
  $ pp_query ./lib/model_star.ml | ocamlformat --impl -
  module AccountNameQuery = struct
    open Caqti_request.Infix
    open Caqti_type.Std
  
    type t = { account : Account.t }
  
    let record =
      let record account = { account } in
      product record @@ proj Account.record (fun record -> record.account) proj_end
    ;;
  
    let query db =
      let open Caqti_request.Infix in
      let open Caqti_type.Std in
      let query =
        (unit ->* record)
        @@ Stdlib.Format.sprintf
             "SELECT %s FROM %s %s"
             (Stdlib.String.concat ", " [ Stdlib.Format.sprintf "%s.%s" Account.relation "*" ])
             (Core.String.concat ~sep:", " [ Account.relation ])
             ""
      in
      let params = () in
      Octane.Database.collect db query params
    ;;
  
    let raw = "SELECT Account.* FROM Account"
  end [@warning "-32"]
< language: ocaml

  $ pp_query ./lib/as.ml | ocamlformat --impl -
  module Account = struct
    type t =
      { id : int [@primary_key { autoincrement = true }]
      ; name : string
      ; age : int
      }
    [@@deriving table { name = "accounts" }]
  
    include struct
      [@@@ocaml.warning "-60"]
  
      let _ = fun (_ : t) -> ()
  
      open Caqti_request.Infix
      open Caqti_type.Std
  
      module Fields = struct
        let id = "id"
        let _ = id
        let name = "name"
        let _ = name
        let age = "age"
        let _ = age
  
        type id = int
        type name = string
        type age = int
      end
  
      module Params = struct
        let id = Caqti_type.Std.int
        let _ = id
        let name = Caqti_type.Std.string
        let _ = name
        let age = Caqti_type.Std.int
        let _ = age
  
        type id = int
        type name = string
        type age = int
      end
  
      module Table = struct
        let drop = (unit ->. unit) @@ "DROP TABLE IF EXISTS accounts CASCADE"
        let _ = drop
        let drop db = Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec drop ()) db
        let _ = drop
  
        let create =
          (unit ->. unit)
          @@ "CREATE TABLE accounts (id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, name TEXT NOT NULL, age \
              INTEGER NOT NULL)"
        ;;
  
        let _ = create
        let create db = Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec create ()) db
        let _ = create
      end
  
      let relation = "accounts"
      let _ = relation
  
      let record =
        let record id name age = { id; name; age } in
        product record
        @@ proj
             Params.id
             (fun record -> record.id)
             (proj Params.name (fun record -> record.name) (proj Params.age (fun record -> record.age) proj_end))
      ;;
  
      let _ = record
  
      let insert ~name ~age db =
        let query =
          (t2 Params.name Params.age ->! record) @@ "INSERT INTO accounts (name, age) VALUES (?, ?) RETURNING *"
        in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find query (name, age)) db
      ;;
  
      let _ = insert
  
      let read db id =
        let query = (Params.id ->? record) @@ "SELECT * FROM accounts WHERE accounts.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find_opt query id) db
      ;;
  
      let _ = read
  
      let update db t =
        let query = (record ->. unit) @@ "UPDATE accounts SET name = $2, age = $3 WHERE accounts.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec query t) db
      ;;
  
      let _ = update
  
      let delete db id =
        let query = (Params.id ->. unit) @@ "DELETE FROM accounts WHERE accounts.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec query id) db
      ;;
  
      let _ = delete
    end [@@ocaml.doc "@inline"] [@@merlin.hide]
  end
  
  module AccountNameQuery = struct
    open Caqti_request.Infix
    open Caqti_type.Std
  
    type t =
      { account_id : Account.Fields.id
      ; name : Account.Fields.name
      }
  
    let record =
      let record account_id name = { account_id; name } in
      product record
      @@ proj
           Account.Params.id
           (fun record -> record.account_id)
           (proj Account.Params.name (fun record -> record.name) proj_end)
    ;;
  
    let query db =
      let open Caqti_request.Infix in
      let open Caqti_type.Std in
      let query =
        (unit ->* record)
        @@ Stdlib.Format.sprintf
             "SELECT %s FROM %s %s"
             (Stdlib.String.concat
                ", "
                [ Stdlib.Format.sprintf "%s.%s" Account.relation "id" ^ " AS account_id"
                ; Stdlib.Format.sprintf "%s.%s" Account.relation "name"
                ])
             (Core.String.concat ~sep:", " [ Account.relation ])
             ""
      in
      let params = () in
      Octane.Database.collect db query params
    ;;
  
    let raw = "SELECT Account.id as account_id, Account.name FROM Account"
  end [@warning "-32"]
  
  module AccountNameQuery = struct
    open Caqti_request.Infix
    open Caqti_type.Std
  
    type t =
      { my_account : Account.t
      ; name : Account.Fields.name
      }
  
    let record =
      let record my_account name = { my_account; name } in
      product record
      @@ proj
           Account.record
           (fun record -> record.my_account)
           (proj Account.Params.name (fun record -> record.name) proj_end)
    ;;
  
    let query db =
      let open Caqti_request.Infix in
      let open Caqti_type.Std in
      let query =
        (unit ->* record)
        @@ Stdlib.Format.sprintf
             "SELECT %s FROM %s %s"
             (Stdlib.String.concat
                ", "
                [ Stdlib.Format.sprintf "%s.%s" Account.relation "*" ^ " AS my_account"
                ; Stdlib.Format.sprintf "%s.%s" Account.relation "name"
                ])
             (Core.String.concat ~sep:", " [ Account.relation ])
             ""
      in
      let params = () in
      Octane.Database.collect db query params
    ;;
  
    let raw = "SELECT Account.* as my_account, Account.name FROM Account"
  end [@warning "-32"]
< language: ocaml

