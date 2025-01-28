Pretty print the file

  $ pp_query ./lib/table.ml > ./lib/table-generated.ml
  $ ocamlformat ./lib/table-generated.ml
  module User = struct
    type t =
      { id : int [@primary_key { autoincrement = true }]
      ; name : string
      ; age : int
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
        let age = "age"
        let _ = age
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
  
      module Model = struct
        type nonrec t = (Params.id, t) Octane.Model.t
      end
  
      module Table = struct
        let drop = (unit ->. unit) @@ "DROP TABLE IF EXISTS users"
        let _ = drop
        let drop db = Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec drop ()) db
        let _ = drop
  
        let create =
          (unit ->. unit)
          @@ "CREATE TABLE users (id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, name TEXT NOT NULL, age INTEGER \
              NOT NULL)"
        ;;
  
        let _ = create
        let create db = Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec create ()) db
        let _ = create
      end
  
      let relation = "users"
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
        let query = (t2 Params.name Params.age ->! record) @@ "INSERT INTO users (name, age) VALUES (?, ?) RETURNING *" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find query (name, age)) db
      ;;
  
      let _ = insert
  
      let read db id =
        let query = (Params.id ->? record) @@ "SELECT * FROM users WHERE users.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find_opt query id) db
      ;;
  
      let _ = read
  
      let update db t =
        let query = (record ->. unit) @@ "UPDATE users SET name = $2, age = $3 WHERE users.id = $1" in
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
  
  module UserNameQuery = struct
    type t =
      { id : User.Fields.id
      ; name : User.Fields.name
      }
    [@@deriving serialize, deserialize]
  
    include struct
      let _ = fun (_ : t) -> ()
  
      let serialize_t =
        let ( let* ) = Stdlib.Result.bind in
        let _ = ( let* ) in
        let open Serde.Ser in
        fun t ->
          fun ctx ->
          record ctx "t" 2 (fun ctx ->
            let* () = field ctx "id" ((s User.Fields.serialize_id) t.id) in
            let* () = field ctx "name" ((s User.Fields.serialize_name) t.name) in
            Ok ())
      ;;
  
      let _ = serialize_t
  
      open! Serde
  
      let deserialize_t =
        let ( let* ) = Stdlib.Result.bind in
        let _ = ( let* ) in
        let open Serde.De in
        fun ctx ->
          record ctx "t" 2 (fun ctx ->
            let field_visitor =
              let visit_string _ctx str =
                match str with
                | "name" -> Ok `name
                | "id" -> Ok `id
                | _ -> Ok `invalid_tag
              in
              let visit_int _ctx str =
                match str with
                | 0 -> Ok `name
                | 1 -> Ok `id
                | _ -> Ok `invalid_tag
              in
              Visitor.make ~visit_string ~visit_int ()
            in
            let id = ref None in
            let name = ref None in
            let rec read_fields () =
              let* tag = next_field ctx field_visitor in
              match tag with
              | Some `name ->
                let* v = field ctx "name" (d User.Fields.deserialize_name) in
                name := Some v;
                read_fields ()
              | Some `id ->
                let* v = field ctx "id" (d User.Fields.deserialize_id) in
                id := Some v;
                read_fields ()
              | Some `invalid_tag ->
                let* () = ignore_any ctx in
                read_fields ()
              | None -> Ok ()
            in
            let* () = read_fields () in
            let* id = Stdlib.Option.to_result ~none:(`Msg "missing field \"id\" (\"id\")") !id in
            let* name = Stdlib.Option.to_result ~none:(`Msg "missing field \"name\" (\"name\")") !name in
            Ok { name; id })
      ;;
  
      let _ = deserialize_t
    end [@@ocaml.doc "@inline"] [@@merlin.hide]
  
    module Query = struct
      type query = t list [@@deriving deserialize, serialize]
  
      include struct
        let _ = fun (_ : query) -> ()
  
        open! Serde
  
        let deserialize_query =
          let ( let* ) = Stdlib.Result.bind in
          let _ = ( let* ) in
          let open Serde.De in
          fun ctx -> (d (list (d deserialize_t))) ctx
        ;;
  
        let _ = deserialize_query
  
        let serialize_query =
          let ( let* ) = Stdlib.Result.bind in
          let _ = ( let* ) in
          let open Serde.Ser in
          fun t -> fun ctx -> (s (list (s serialize_t))) t ctx
        ;;
  
        let _ = serialize_query
      end [@@ocaml.doc "@inline"] [@@merlin.hide]
    end
  
    let deserialize = Query.deserialize_query
  
    let query db =
      let query =
        Stdlib.Format.sprintf
          "SELECT %s FROM %s"
          (Stdlib.String.concat
             ", "
             [ Stdlib.Format.sprintf "%s.%s" User.relation User.Fields.id
             ; Stdlib.Format.sprintf "%s.%s" User.relation User.Fields.name
             ])
          (String.concat ~sep:", " [ User.relation ])
      in
      let open DBCaml.Params.Values in
      let params = [] in
      DBCaml.query db ~query ~params ~deserializer:deserialize
    ;;
  
    let raw = "select User.id, User.name from User"
  end [@warning "-32"]
< language: ocaml

  $ pp_query ./lib/where_id.ml | ocamlformat --impl -
  module_param: User.id
  module User = struct
    type t = { id : int } [@@deriving table { name = "users" }]
  
    include struct
      [@@@ocaml.warning "-60"]
  
      let _ = fun (_ : t) -> ()
  
      open Caqti_request.Infix
      open Caqti_type.Std
  
      module Fields = struct
        let id = "id"
        let _ = id
      end
  
      module Params = struct
        let id = Caqti_type.Std.int
        let _ = id
  
        type id = int
      end
  
      module Model = struct
        type nonrec t = (Params.id, t) Octane.Model.t
      end
  
      module Table = struct
        let drop = (unit ->. unit) @@ "DROP TABLE IF EXISTS users"
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
  
  module UserByID = struct
    type t =
      { id : User.Fields.id
      ; name : User.Fields.name
      }
    [@@deriving serialize, deserialize]
  
    include struct
      let _ = fun (_ : t) -> ()
  
      let serialize_t =
        let ( let* ) = Stdlib.Result.bind in
        let _ = ( let* ) in
        let open Serde.Ser in
        fun t ->
          fun ctx ->
          record ctx "t" 2 (fun ctx ->
            let* () = field ctx "id" ((s User.Fields.serialize_id) t.id) in
            let* () = field ctx "name" ((s User.Fields.serialize_name) t.name) in
            Ok ())
      ;;
  
      let _ = serialize_t
  
      open! Serde
  
      let deserialize_t =
        let ( let* ) = Stdlib.Result.bind in
        let _ = ( let* ) in
        let open Serde.De in
        fun ctx ->
          record ctx "t" 2 (fun ctx ->
            let field_visitor =
              let visit_string _ctx str =
                match str with
                | "name" -> Ok `name
                | "id" -> Ok `id
                | _ -> Ok `invalid_tag
              in
              let visit_int _ctx str =
                match str with
                | 0 -> Ok `name
                | 1 -> Ok `id
                | _ -> Ok `invalid_tag
              in
              Visitor.make ~visit_string ~visit_int ()
            in
            let id = ref None in
            let name = ref None in
            let rec read_fields () =
              let* tag = next_field ctx field_visitor in
              match tag with
              | Some `name ->
                let* v = field ctx "name" (d User.Fields.deserialize_name) in
                name := Some v;
                read_fields ()
              | Some `id ->
                let* v = field ctx "id" (d User.Fields.deserialize_id) in
                id := Some v;
                read_fields ()
              | Some `invalid_tag ->
                let* () = ignore_any ctx in
                read_fields ()
              | None -> Ok ()
            in
            let* () = read_fields () in
            let* id = Stdlib.Option.to_result ~none:(`Msg "missing field \"id\" (\"id\")") !id in
            let* name = Stdlib.Option.to_result ~none:(`Msg "missing field \"name\" (\"name\")") !name in
            Ok { name; id })
      ;;
  
      let _ = deserialize_t
    end [@@ocaml.doc "@inline"] [@@merlin.hide]
  
    module Query = struct
      type query = t list [@@deriving deserialize, serialize]
  
      include struct
        let _ = fun (_ : query) -> ()
  
        open! Serde
  
        let deserialize_query =
          let ( let* ) = Stdlib.Result.bind in
          let _ = ( let* ) in
          let open Serde.De in
          fun ctx -> (d (list (d deserialize_t))) ctx
        ;;
  
        let _ = deserialize_query
  
        let serialize_query =
          let ( let* ) = Stdlib.Result.bind in
          let _ = ( let* ) in
          let open Serde.Ser in
          fun t -> fun ctx -> (s (list (s serialize_t))) t ctx
        ;;
  
        let _ = serialize_query
      end [@@ocaml.doc "@inline"] [@@merlin.hide]
    end
  
    let deserialize = Query.deserialize_query
  
    let query db ~id =
      let query =
        Stdlib.Format.sprintf
          "SELECT %s FROM %s WHERE %s"
          (Stdlib.String.concat
             ", "
             [ Stdlib.Format.sprintf "%s.%s" User.relation User.Fields.id
             ; Stdlib.Format.sprintf "%s.%s" User.relation User.Fields.name
             ])
          (String.concat ~sep:", " [ User.relation ])
          (Stdlib.Format.sprintf "(%s = %s)" (Stdlib.Format.sprintf "%s.%s" User.relation User.Fields.id) "$1")
      in
      let open DBCaml.Params.Values in
      let params = [ User.Params.id id ] in
      DBCaml.query db ~query ~params ~deserializer:deserialize
    ;;
  
    let raw = "SELECT User.id, User.name FROM User WHERE User.id = $id"
  end [@warning "-32"]
< language: ocaml

  $ pp_query ./lib/where_positional.ml | ocamlformat --impl -
  module User = struct
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
      end
  
      module Params = struct
        let id = Caqti_type.Std.int
        let _ = id
        let name = Caqti_type.Std.string
        let _ = name
  
        type id = int
        type name = string
      end
  
      module Model = struct
        type nonrec t = (Params.id, t) Octane.Model.t
      end
  
      module Table = struct
        let drop = (unit ->. unit) @@ "DROP TABLE IF EXISTS users"
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
  
  module UserByID = struct
    type t = { name : User.Fields.name } [@@deriving serialize, deserialize]
  
    include struct
      let _ = fun (_ : t) -> ()
  
      let serialize_t =
        let ( let* ) = Stdlib.Result.bind in
        let _ = ( let* ) in
        let open Serde.Ser in
        fun t ->
          fun ctx ->
          record ctx "t" 1 (fun ctx ->
            let* () = field ctx "name" ((s User.Fields.serialize_name) t.name) in
            Ok ())
      ;;
  
      let _ = serialize_t
  
      open! Serde
  
      let deserialize_t =
        let ( let* ) = Stdlib.Result.bind in
        let _ = ( let* ) in
        let open Serde.De in
        fun ctx ->
          record ctx "t" 1 (fun ctx ->
            let field_visitor =
              let visit_string _ctx str =
                match str with
                | "name" -> Ok `name
                | _ -> Ok `invalid_tag
              in
              let visit_int _ctx str =
                match str with
                | 0 -> Ok `name
                | _ -> Ok `invalid_tag
              in
              Visitor.make ~visit_string ~visit_int ()
            in
            let name = ref None in
            let rec read_fields () =
              let* tag = next_field ctx field_visitor in
              match tag with
              | Some `name ->
                let* v = field ctx "name" (d User.Fields.deserialize_name) in
                name := Some v;
                read_fields ()
              | Some `invalid_tag ->
                let* () = ignore_any ctx in
                read_fields ()
              | None -> Ok ()
            in
            let* () = read_fields () in
            let* name = Stdlib.Option.to_result ~none:(`Msg "missing field \"name\" (\"name\")") !name in
            Ok { name })
      ;;
  
      let _ = deserialize_t
    end [@@ocaml.doc "@inline"] [@@merlin.hide]
  
    module Query = struct
      type query = t list [@@deriving deserialize, serialize]
  
      include struct
        let _ = fun (_ : query) -> ()
  
        open! Serde
  
        let deserialize_query =
          let ( let* ) = Stdlib.Result.bind in
          let _ = ( let* ) in
          let open Serde.De in
          fun ctx -> (d (list (d deserialize_t))) ctx
        ;;
  
        let _ = deserialize_query
  
        let serialize_query =
          let ( let* ) = Stdlib.Result.bind in
          let _ = ( let* ) in
          let open Serde.Ser in
          fun t -> fun ctx -> (s (list (s serialize_t))) t ctx
        ;;
  
        let _ = serialize_query
      end [@@ocaml.doc "@inline"] [@@merlin.hide]
    end
  
    let deserialize = Query.deserialize_query
  
    let query db p1 p2 =
      let query =
        Stdlib.Format.sprintf
          "SELECT %s FROM %s WHERE %s"
          (Stdlib.String.concat ", " [ Stdlib.Format.sprintf "%s.%s" User.relation User.Fields.name; p2 ])
          (String.concat ~sep:", " [ User.relation ])
          "TODO"
      in
      let open DBCaml.Params.Values in
      let params = [ p1; p2 ] in
      DBCaml.query db ~query ~params ~deserializer:deserialize
    ;;
  
    let raw = "SELECT User.name, $2 FROM User WHERE User.id = $1"
  end [@warning "-32"]
< language: ocaml

  $ pp_query ./lib/invalid_model.ml | ocamlformat --impl -
  module ShouldError = struct
    type t = [%ocaml.error "Invalid Model: Module 'Post' is not selected in query"]
  
    let raw = "SELECT Post.id from User"
  end [@warning "-32"]
< language: ocaml

  $ pp_query ./lib/simple_join.ml | ocamlformat --impl -
  module AuthorAndContent = struct
    type t =
      { name : User.Fields.name
      ; content : Post.Fields.content
      }
    [@@deriving serialize, deserialize]
  
    include struct
      let _ = fun (_ : t) -> ()
  
      let serialize_t =
        let ( let* ) = Stdlib.Result.bind in
        let _ = ( let* ) in
        let open Serde.Ser in
        fun t ->
          fun ctx ->
          record ctx "t" 2 (fun ctx ->
            let* () = field ctx "name" ((s User.Fields.serialize_name) t.name) in
            let* () = field ctx "content" ((s Post.Fields.serialize_content) t.content) in
            Ok ())
      ;;
  
      let _ = serialize_t
  
      open! Serde
  
      let deserialize_t =
        let ( let* ) = Stdlib.Result.bind in
        let _ = ( let* ) in
        let open Serde.De in
        fun ctx ->
          record ctx "t" 2 (fun ctx ->
            let field_visitor =
              let visit_string _ctx str =
                match str with
                | "content" -> Ok `content
                | "name" -> Ok `name
                | _ -> Ok `invalid_tag
              in
              let visit_int _ctx str =
                match str with
                | 0 -> Ok `content
                | 1 -> Ok `name
                | _ -> Ok `invalid_tag
              in
              Visitor.make ~visit_string ~visit_int ()
            in
            let name = ref None in
            let content = ref None in
            let rec read_fields () =
              let* tag = next_field ctx field_visitor in
              match tag with
              | Some `content ->
                let* v = field ctx "content" (d Post.Fields.deserialize_content) in
                content := Some v;
                read_fields ()
              | Some `name ->
                let* v = field ctx "name" (d User.Fields.deserialize_name) in
                name := Some v;
                read_fields ()
              | Some `invalid_tag ->
                let* () = ignore_any ctx in
                read_fields ()
              | None -> Ok ()
            in
            let* () = read_fields () in
            let* name = Stdlib.Option.to_result ~none:(`Msg "missing field \"name\" (\"name\")") !name in
            let* content = Stdlib.Option.to_result ~none:(`Msg "missing field \"content\" (\"content\")") !content in
            Ok { content; name })
      ;;
  
      let _ = deserialize_t
    end [@@ocaml.doc "@inline"] [@@merlin.hide]
  
    module Query = struct
      type query = t list [@@deriving deserialize, serialize]
  
      include struct
        let _ = fun (_ : query) -> ()
  
        open! Serde
  
        let deserialize_query =
          let ( let* ) = Stdlib.Result.bind in
          let _ = ( let* ) in
          let open Serde.De in
          fun ctx -> (d (list (d deserialize_t))) ctx
        ;;
  
        let _ = deserialize_query
  
        let serialize_query =
          let ( let* ) = Stdlib.Result.bind in
          let _ = ( let* ) in
          let open Serde.Ser in
          fun t -> fun ctx -> (s (list (s serialize_t))) t ctx
        ;;
  
        let _ = serialize_query
      end [@@ocaml.doc "@inline"] [@@merlin.hide]
    end
  
    let deserialize = Query.deserialize_query
  
    let query db =
      let query =
        Stdlib.Format.sprintf
          "SELECT %s FROM %s"
          (Stdlib.String.concat
             ", "
             [ Stdlib.Format.sprintf "%s.%s" User.relation User.Fields.name
             ; Stdlib.Format.sprintf "%s.%s" Post.relation Post.Fields.content
             ])
          (Stdlib.Format.sprintf
             "%s %s"
             Post.relation
             (String.concat
                ~sep:"\n"
                [ Stdlib.Format.sprintf
                    "%s %s ON %s"
                    "INNER JOIN"
                    User.relation
                    (Stdlib.Format.sprintf
                       "(%s = %s)"
                       (Stdlib.Format.sprintf "%s.%s" User.relation User.Fields.id)
                       (Stdlib.Format.sprintf "%s.%s" Post.relation Post.Fields.author))
                ]))
      in
      let open DBCaml.Params.Values in
      let params = [] in
      DBCaml.query db ~query ~params ~deserializer:deserialize
    ;;
  
    let raw = " SELECT User.name, Post.content FROM Post INNER JOIN User ON User.id = Post.author "
  end [@warning "-32"]
  
  module AuthorAndContent = struct
    type t =
      { name : User.Fields.name
      ; content : Post.Fields.content
      }
    [@@deriving serialize, deserialize]
  
    include struct
      let _ = fun (_ : t) -> ()
  
      let serialize_t =
        let ( let* ) = Stdlib.Result.bind in
        let _ = ( let* ) in
        let open Serde.Ser in
        fun t ->
          fun ctx ->
          record ctx "t" 2 (fun ctx ->
            let* () = field ctx "name" ((s User.Fields.serialize_name) t.name) in
            let* () = field ctx "content" ((s Post.Fields.serialize_content) t.content) in
            Ok ())
      ;;
  
      let _ = serialize_t
  
      open! Serde
  
      let deserialize_t =
        let ( let* ) = Stdlib.Result.bind in
        let _ = ( let* ) in
        let open Serde.De in
        fun ctx ->
          record ctx "t" 2 (fun ctx ->
            let field_visitor =
              let visit_string _ctx str =
                match str with
                | "content" -> Ok `content
                | "name" -> Ok `name
                | _ -> Ok `invalid_tag
              in
              let visit_int _ctx str =
                match str with
                | 0 -> Ok `content
                | 1 -> Ok `name
                | _ -> Ok `invalid_tag
              in
              Visitor.make ~visit_string ~visit_int ()
            in
            let name = ref None in
            let content = ref None in
            let rec read_fields () =
              let* tag = next_field ctx field_visitor in
              match tag with
              | Some `content ->
                let* v = field ctx "content" (d Post.Fields.deserialize_content) in
                content := Some v;
                read_fields ()
              | Some `name ->
                let* v = field ctx "name" (d User.Fields.deserialize_name) in
                name := Some v;
                read_fields ()
              | Some `invalid_tag ->
                let* () = ignore_any ctx in
                read_fields ()
              | None -> Ok ()
            in
            let* () = read_fields () in
            let* name = Stdlib.Option.to_result ~none:(`Msg "missing field \"name\" (\"name\")") !name in
            let* content = Stdlib.Option.to_result ~none:(`Msg "missing field \"content\" (\"content\")") !content in
            Ok { content; name })
      ;;
  
      let _ = deserialize_t
    end [@@ocaml.doc "@inline"] [@@merlin.hide]
  
    module Query = struct
      type query = t list [@@deriving deserialize, serialize]
  
      include struct
        let _ = fun (_ : query) -> ()
  
        open! Serde
  
        let deserialize_query =
          let ( let* ) = Stdlib.Result.bind in
          let _ = ( let* ) in
          let open Serde.De in
          fun ctx -> (d (list (d deserialize_t))) ctx
        ;;
  
        let _ = deserialize_query
  
        let serialize_query =
          let ( let* ) = Stdlib.Result.bind in
          let _ = ( let* ) in
          let open Serde.Ser in
          fun t -> fun ctx -> (s (list (s serialize_t))) t ctx
        ;;
  
        let _ = serialize_query
      end [@@ocaml.doc "@inline"] [@@merlin.hide]
    end
  
    let deserialize = Query.deserialize_query
  
    let query db =
      let query =
        Stdlib.Format.sprintf
          "SELECT %s FROM %s"
          (Stdlib.String.concat
             ", "
             [ Stdlib.Format.sprintf "%s.%s" User.relation User.Fields.name
             ; Stdlib.Format.sprintf "%s.%s" Post.relation Post.Fields.content
             ])
          (Stdlib.Format.sprintf
             "%s %s"
             Post.relation
             (String.concat
                ~sep:"\n"
                [ Stdlib.Format.sprintf
                    "%s %s ON %s"
                    "INNER JOIN"
                    User.relation
                    (Stdlib.Format.sprintf
                       "(%s = %s)"
                       (Stdlib.Format.sprintf "%s.%s" User.relation User.Fields.id)
                       (Stdlib.Format.sprintf "%s.%s" Post.relation Post.Fields.authorasdf))
                ]))
      in
      let open DBCaml.Params.Values in
      let params = [] in
      DBCaml.query db ~query ~params ~deserializer:deserialize
    ;;
  
    let raw = " SELECT User.name, Post.content FROM Post INNER JOIN User ON User.id = Post.authorasdf "
  end [@warning "-32"]
< language: ocaml

  $ pp_query ./lib/missing_name.ml | ocamlformat --impl -
  module User = struct
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
  
      module Model = struct
        type nonrec t = (Params.id, t) Octane.Model.t
      end
  
      module Table = struct
        let drop = (unit ->. unit) @@ "DROP TABLE IF EXISTS optional_field"
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
  module_param: User.t
  module_param: User.t
  module User = struct
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
      end
  
      module Params = struct
        let id = Caqti_type.Std.int
        let _ = id
        let name = Caqti_type.Std.string
        let _ = name
  
        type id = int
        type name = string
      end
  
      module Model = struct
        type nonrec t = (Params.id, t) Octane.Model.t
      end
  
      module Table = struct
        let drop = (unit ->. unit) @@ "DROP TABLE IF EXISTS users"
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
      ; user : User.Model.t
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
        let user = "user"
        let _ = user
        let content = "content"
        let _ = content
      end
  
      module Params = struct
        let id = Caqti_type.Std.int
        let _ = id
        let user = User.Params.t user
        let _ = user
        let content = Caqti_type.Std.string
        let _ = content
  
        type id = int
        type user = User.Model.t
        type content = string
      end
  
      module Model = struct
        type nonrec t = (Params.id, t) Octane.Model.t
      end
  
      module Table = struct
        let drop = (unit ->. unit) @@ "DROP TABLE IF EXISTS posts"
        let _ = drop
        let drop db = Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec drop ()) db
        let _ = drop
  
        let create =
          (unit ->. unit)
          @@ "CREATE TABLE posts (id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, user INTEGER NOT NULL, content \
              TEXT NOT NULL)"
        ;;
  
        let _ = create
        let create db = Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec create ()) db
        let _ = create
      end
  
      let relation = "posts"
      let _ = relation
  
      let record =
        let record id user content = { id; user; content } in
        product record
        @@ proj
             Params.id
             (fun record -> record.id)
             (proj Params.user (fun record -> record.user) (proj Params.content (fun record -> record.content) proj_end))
      ;;
  
      let _ = record
  
      let insert ~user ~content db =
        let query =
          (t2 Params.user Params.content ->! record) @@ "INSERT INTO posts (user, content) VALUES (?, ?) RETURNING *"
        in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find query (user, content)) db
      ;;
  
      let _ = insert
  
      let read db id =
        let query = (Params.id ->? record) @@ "SELECT * FROM posts WHERE posts.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.find_opt query id) db
      ;;
  
      let _ = read
  
      let update db t =
        let query = (record ->. unit) @@ "UPDATE posts SET user = $2, content = $3 WHERE posts.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec query t) db
      ;;
  
      let _ = update
  
      let delete db id =
        let query = (Params.id ->. unit) @@ "DELETE FROM posts WHERE posts.id = $1" in
        Caqti_eio.Pool.use (fun (module DB : Caqti_eio.CONNECTION) -> DB.exec query id) db
      ;;
  
      let _ = delete
    end [@@ocaml.doc "@inline"] [@@merlin.hide]
  
    let user_name db t =
      let user = User.Model.fetch db t.user in
      user.name
    ;;
  end
< language: ocaml

