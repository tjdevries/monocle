Pretty print the file

  $ pp_query ./lib/table.ml > ./lib/table-generated.ml
  Uncaught exception:
    
    (Failure "OH NO: 66")
  
  Raised at Stdlib.failwith in file "stdlib.ml", line 29, characters 17-33
  Called from Ppx_octane__Ppx_query.letter_rule.(fun) in file "packages/octane/pkg/ppx_octane/ppx_query.ml", line 66, characters 21-41
  Called from Ppxlib__Ast_pattern_generated.pconst_string.(fun) in file "src/ast_pattern_generated.ml", line 906, characters 41-56
  Called from Ppxlib__Ast_pattern.(^::).(fun) in file "src/ast_pattern.ml", line 110, characters 18-33
  Called from Ppxlib__Ast_pattern.(^::).(fun) in file "src/ast_pattern.ml", line 110, characters 18-33
  Called from Ppxlib__Ast_pattern.map_result.(fun) in file "src/ast_pattern.ml", line 170, characters 53-71
  Called from Ppxlib__Ast_pattern.parse_res in file "src/ast_pattern.ml", line 9, characters 9-36
  Called from Ppxlib__Extension.For_context.convert_inline_res.(fun) in file "src/extension.ml", line 274, characters 8-66
  Called from Ppxlib__Context_free.map_top_down#structure.loop in file "src/context_free.ml", line 758, characters 16-73
  Called from Ppxlib__Context_free.map_top_down#structure.loop.(fun) in file "src/context_free.ml", line 829, characters 20-49
  Called from Ppxlib__Common.With_errors.(>>=) in file "src/common.ml", line 266, characters 21-24
  Called from Ppxlib__Driver.Transform.merge_into_generic_mappers.map_impl in file "src/driver.ml", line 281, characters 6-73
  Called from Ppxlib__Driver.apply_transforms.(fun) in file "src/driver.ml", line 568, characters 19-29
  Called from Stdlib__List.fold_left in file "list.ml", line 123, characters 24-34
  Called from Ppxlib__Driver.apply_transforms in file "src/driver.ml", lines 544-580, characters 4-62
  Called from Ppxlib__Driver.map_structure_gen in file "src/driver.ml", lines 693-697, characters 4-56
  Called from Ppxlib__Driver.process_ast in file "src/driver.ml", lines 1055-1056, characters 10-55
  Called from Ppxlib__Driver.process_file in file "src/driver.ml", lines 1100-1101, characters 15-30
  Called from Ppxlib__Driver.standalone in file "src/driver.ml", line 1532, characters 9-27
  Re-raised at Location.report_exception.loop in file "parsing/location.ml", line 979, characters 14-25
  Called from Ppxlib__Driver.standalone in file "src/driver.ml", line 1535, characters 4-61
  Called from Dune__exe__Pp_query in file "packages/octane/test/bin/pp_query.ml", line 1, characters 9-36
  [2]
  $ ocamlformat ./lib/table-generated.ml
< language: ocaml

  $ pp_query ./lib/where_id.ml | ocamlformat --impl -
  Uncaught exception:
    
    (Failure "OH NO: 66")
  
  Raised at Stdlib.failwith in file "stdlib.ml", line 29, characters 17-33
  Called from Ppx_octane__Ppx_query.letter_rule.(fun) in file "packages/octane/pkg/ppx_octane/ppx_query.ml", line 66, characters 21-41
  Called from Ppxlib__Ast_pattern_generated.pconst_string.(fun) in file "src/ast_pattern_generated.ml", line 906, characters 41-56
  Called from Ppxlib__Ast_pattern.(^::).(fun) in file "src/ast_pattern.ml", line 110, characters 18-33
  Called from Ppxlib__Ast_pattern.(^::).(fun) in file "src/ast_pattern.ml", line 110, characters 18-33
  Called from Ppxlib__Ast_pattern.map_result.(fun) in file "src/ast_pattern.ml", line 170, characters 53-71
  Called from Ppxlib__Ast_pattern.parse_res in file "src/ast_pattern.ml", line 9, characters 9-36
  Called from Ppxlib__Extension.For_context.convert_inline_res.(fun) in file "src/extension.ml", line 274, characters 8-66
  Called from Ppxlib__Context_free.map_top_down#structure.loop in file "src/context_free.ml", line 758, characters 16-73
  Called from Ppxlib__Context_free.map_top_down#structure.loop.(fun) in file "src/context_free.ml", line 829, characters 20-49
  Called from Ppxlib__Common.With_errors.(>>=) in file "src/common.ml", line 266, characters 21-24
  Called from Ppxlib__Driver.Transform.merge_into_generic_mappers.map_impl in file "src/driver.ml", line 281, characters 6-73
  Called from Ppxlib__Driver.apply_transforms.(fun) in file "src/driver.ml", line 568, characters 19-29
  Called from Stdlib__List.fold_left in file "list.ml", line 123, characters 24-34
  Called from Ppxlib__Driver.apply_transforms in file "src/driver.ml", lines 544-580, characters 4-62
  Called from Ppxlib__Driver.map_structure_gen in file "src/driver.ml", lines 693-697, characters 4-56
  Called from Ppxlib__Driver.process_ast in file "src/driver.ml", lines 1055-1056, characters 10-55
  Called from Ppxlib__Driver.process_file in file "src/driver.ml", lines 1100-1101, characters 15-30
  Called from Ppxlib__Driver.standalone in file "src/driver.ml", line 1532, characters 9-27
  Re-raised at Location.report_exception.loop in file "parsing/location.ml", line 979, characters 14-25
  Called from Ppxlib__Driver.standalone in file "src/driver.ml", line 1535, characters 4-61
  Called from Dune__exe__Pp_query in file "packages/octane/test/bin/pp_query.ml", line 1, characters 9-36
< language: ocaml

  $ pp_query ./lib/where_positional.ml | ocamlformat --impl -
  Uncaught exception:
    
    (Failure "OH NO: 66")
  
  Raised at Stdlib.failwith in file "stdlib.ml", line 29, characters 17-33
  Called from Ppx_octane__Ppx_query.letter_rule.(fun) in file "packages/octane/pkg/ppx_octane/ppx_query.ml", line 66, characters 21-41
  Called from Ppxlib__Ast_pattern_generated.pconst_string.(fun) in file "src/ast_pattern_generated.ml", line 906, characters 41-56
  Called from Ppxlib__Ast_pattern.(^::).(fun) in file "src/ast_pattern.ml", line 110, characters 18-33
  Called from Ppxlib__Ast_pattern.(^::).(fun) in file "src/ast_pattern.ml", line 110, characters 18-33
  Called from Ppxlib__Ast_pattern.map_result.(fun) in file "src/ast_pattern.ml", line 170, characters 53-71
  Called from Ppxlib__Ast_pattern.parse_res in file "src/ast_pattern.ml", line 9, characters 9-36
  Called from Ppxlib__Extension.For_context.convert_inline_res.(fun) in file "src/extension.ml", line 274, characters 8-66
  Called from Ppxlib__Context_free.map_top_down#structure.loop in file "src/context_free.ml", line 758, characters 16-73
  Called from Ppxlib__Context_free.map_top_down#structure.loop.(fun) in file "src/context_free.ml", line 829, characters 20-49
  Called from Ppxlib__Common.With_errors.(>>=) in file "src/common.ml", line 266, characters 21-24
  Called from Ppxlib__Driver.Transform.merge_into_generic_mappers.map_impl in file "src/driver.ml", line 281, characters 6-73
  Called from Ppxlib__Driver.apply_transforms.(fun) in file "src/driver.ml", line 568, characters 19-29
  Called from Stdlib__List.fold_left in file "list.ml", line 123, characters 24-34
  Called from Ppxlib__Driver.apply_transforms in file "src/driver.ml", lines 544-580, characters 4-62
  Called from Ppxlib__Driver.map_structure_gen in file "src/driver.ml", lines 693-697, characters 4-56
  Called from Ppxlib__Driver.process_ast in file "src/driver.ml", lines 1055-1056, characters 10-55
  Called from Ppxlib__Driver.process_file in file "src/driver.ml", lines 1100-1101, characters 15-30
  Called from Ppxlib__Driver.standalone in file "src/driver.ml", line 1532, characters 9-27
  Re-raised at Location.report_exception.loop in file "parsing/location.ml", line 979, characters 14-25
  Called from Ppxlib__Driver.standalone in file "src/driver.ml", line 1535, characters 4-61
  Called from Dune__exe__Pp_query in file "packages/octane/test/bin/pp_query.ml", line 1, characters 9-36
< language: ocaml

  $ pp_query ./lib/invalid_model.ml | ocamlformat --impl -
  Uncaught exception:
    
    Pbrt.Decoder.Failure(Incomplete)
  
  Raised at Pbrt.Decoder.nested in file "src/runtime/pbrt.ml" (inlined), line 179, characters 37-63
  Called from PGQuery__Pg_query.decode_pb_parse_result in file "packages/pg-query/lib/pg_query.ml", line 31149, characters 37-60
  Called from PGQuery__Ffi.PostgresProtobuf.parse in file "packages/pg-query/lib/ffi.ml", line 100, characters 19-58
  Called from Oql__Run.parse in file "packages/octane/pkg/oql/run.ml", line 5, characters 15-22
  Called from Ppx_octane__Ppx_query.letter_rule.(fun) in file "packages/octane/pkg/ppx_octane/ppx_query.ml", line 64, characters 12-31
  Called from Ppxlib__Ast_pattern_generated.pconst_string.(fun) in file "src/ast_pattern_generated.ml", line 906, characters 41-56
  Called from Ppxlib__Ast_pattern.(^::).(fun) in file "src/ast_pattern.ml", line 110, characters 18-33
  Called from Ppxlib__Ast_pattern.(^::).(fun) in file "src/ast_pattern.ml", line 110, characters 18-33
  Called from Ppxlib__Ast_pattern.map_result.(fun) in file "src/ast_pattern.ml", line 170, characters 53-71
  Called from Ppxlib__Ast_pattern.parse_res in file "src/ast_pattern.ml", line 9, characters 9-36
  Called from Ppxlib__Extension.For_context.convert_inline_res.(fun) in file "src/extension.ml", line 274, characters 8-66
  Called from Ppxlib__Context_free.map_top_down#structure.loop in file "src/context_free.ml", line 758, characters 16-73
  Called from Ppxlib__Driver.Transform.merge_into_generic_mappers.map_impl in file "src/driver.ml", line 281, characters 6-73
  Called from Ppxlib__Driver.apply_transforms.(fun) in file "src/driver.ml", line 568, characters 19-29
  Called from Stdlib__List.fold_left in file "list.ml", line 123, characters 24-34
  Called from Ppxlib__Driver.apply_transforms in file "src/driver.ml", lines 544-580, characters 4-62
  Called from Ppxlib__Driver.map_structure_gen in file "src/driver.ml", lines 693-697, characters 4-56
  Called from Ppxlib__Driver.process_ast in file "src/driver.ml", lines 1055-1056, characters 10-55
  Called from Ppxlib__Driver.process_file in file "src/driver.ml", lines 1100-1101, characters 15-30
  Called from Ppxlib__Driver.standalone in file "src/driver.ml", line 1532, characters 9-27
  Re-raised at Location.report_exception.loop in file "parsing/location.ml", line 979, characters 14-25
  Called from Ppxlib__Driver.standalone in file "src/driver.ml", line 1535, characters 4-61
  Called from Dune__exe__Pp_query in file "packages/octane/test/bin/pp_query.ml", line 1, characters 9-36
< language: ocaml

  $ pp_query ./lib/simple_join.ml | ocamlformat --impl -
  Uncaught exception:
    
    (Failure "OH NO: 66")
  
  Raised at Stdlib.failwith in file "stdlib.ml", line 29, characters 17-33
  Called from Ppx_octane__Ppx_query.letter_rule.(fun) in file "packages/octane/pkg/ppx_octane/ppx_query.ml", line 66, characters 21-41
  Called from Ppxlib__Ast_pattern_generated.pconst_string.(fun) in file "src/ast_pattern_generated.ml", line 906, characters 41-56
  Called from Ppxlib__Ast_pattern.(^::).(fun) in file "src/ast_pattern.ml", line 110, characters 18-33
  Called from Ppxlib__Ast_pattern.(^::).(fun) in file "src/ast_pattern.ml", line 110, characters 18-33
  Called from Ppxlib__Ast_pattern.map_result.(fun) in file "src/ast_pattern.ml", line 170, characters 53-71
  Called from Ppxlib__Ast_pattern.parse_res in file "src/ast_pattern.ml", line 9, characters 9-36
  Called from Ppxlib__Extension.For_context.convert_inline_res.(fun) in file "src/extension.ml", line 274, characters 8-66
  Called from Ppxlib__Context_free.map_top_down#structure.loop in file "src/context_free.ml", line 758, characters 16-73
  Called from Ppxlib__Driver.Transform.merge_into_generic_mappers.map_impl in file "src/driver.ml", line 281, characters 6-73
  Called from Ppxlib__Driver.apply_transforms.(fun) in file "src/driver.ml", line 568, characters 19-29
  Called from Stdlib__List.fold_left in file "list.ml", line 123, characters 24-34
  Called from Ppxlib__Driver.apply_transforms in file "src/driver.ml", lines 544-580, characters 4-62
  Called from Ppxlib__Driver.map_structure_gen in file "src/driver.ml", lines 693-697, characters 4-56
  Called from Ppxlib__Driver.process_ast in file "src/driver.ml", lines 1055-1056, characters 10-55
  Called from Ppxlib__Driver.process_file in file "src/driver.ml", lines 1100-1101, characters 15-30
  Called from Ppxlib__Driver.standalone in file "src/driver.ml", line 1532, characters 9-27
  Re-raised at Location.report_exception.loop in file "parsing/location.ml", line 979, characters 14-25
  Called from Ppxlib__Driver.standalone in file "src/driver.ml", line 1535, characters 4-61
  Called from Dune__exe__Pp_query in file "packages/octane/test/bin/pp_query.ml", line 1, characters 9-36
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
  module_param: User.id
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
      ; user_id : User.Fields.id
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
        type user_id = User.Fields.id
        type content = string
      end
  
      module Params = struct
        let id = Caqti_type.Std.int
        let _ = id
        let user_id = User.Params.id
        let _ = user_id
        let content = Caqti_type.Std.string
        let _ = content
  
        type id = int
        type user_id = User.Fields.id
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

