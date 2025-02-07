Pretty print the file

  $ pp_query ./lib/table.ml > ./lib/table-generated.ml
  parse: {"version":170000,"stmts":[{"stmt":{"SelectStmt":{"targetList":[{"ResTarget":{"val":{"ColumnRef":{"fields":[{"String":{"sval":"Account"}},{"String":{"sval":"id"}}],"location":7}},"location":7}},{"ResTarget":{"val":{"ColumnRef":{"fields":[{"String":{"sval":"Account"}},{"String":{"sval":"name"}}],"location":19}},"location":19}}],"fromClause":[{"RangeVar":{"relname":"Account","inh":true,"relpersistence":"p","location":37}}],"limitOption":"LIMIT_OPTION_DEFAULT","op":"SETOP_NONE"}}}]}
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
  parse: {"version":170000,"stmts":[{"stmt":{"SelectStmt":{"targetList":[{"ResTarget":{"val":{"ColumnRef":{"fields":[{"String":{"sval":"Account"}},{"String":{"sval":"id"}}],"location":7}},"location":7}},{"ResTarget":{"val":{"ColumnRef":{"fields":[{"String":{"sval":"Account"}},{"String":{"sval":"name"}}],"location":19}},"location":19}}],"fromClause":[{"RangeVar":{"relname":"Account","inh":true,"relpersistence":"p","location":37}}],"whereClause":{"A_Expr":{"kind":"AEXPR_OP","name":[{"String":{"sval":"="}}],"lexpr":{"ColumnRef":{"fields":[{"String":{"sval":"Account"}},{"String":{"sval":"id"}}],"location":51}},"rexpr":{"ParamRef":{"number":1,"location":64}},"location":62}},"limitOption":"LIMIT_OPTION_DEFAULT","op":"SETOP_NONE"}}}]}
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
        (int ->* record)
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
  parse: {"version":170000,"stmts":[{"stmt":{"SelectStmt":{"targetList":[{"ResTarget":{"val":{"ColumnRef":{"fields":[{"String":{"sval":"Account"}},{"String":{"sval":"name"}}],"location":7}},"location":7}},{"ResTarget":{"val":{"ParamRef":{"number":2,"location":21}},"location":21}}],"fromClause":[{"RangeVar":{"relname":"Account","inh":true,"relpersistence":"p","location":29}}],"whereClause":{"A_Expr":{"kind":"AEXPR_OP","name":[{"String":{"sval":"="}}],"lexpr":{"ColumnRef":{"fields":[{"String":{"sval":"Account"}},{"String":{"sval":"id"}}],"location":43}},"rexpr":{"ParamRef":{"number":1,"location":56}},"location":54}},"limitOption":"LIMIT_OPTION_DEFAULT","op":"SETOP_NONE"}}}]}
  json: {"version":170000,"stmts":[{"stmt":{"SelectStmt":{"targetList":[{"ResTarget":{"val":{"ColumnRef":{"fields":[{"String":{"sval":"Account"}},{"String":{"sval":"name"}}],"location":7}},"location":7}},{"ResTarget":{"val":{"ParamRef":{"number":2,"location":21}},"location":21}}],"fromClause":[{"RangeVar":{"relname":"Account","inh":true,"relpersistence":"p","location":29}}],"whereClause":{"A_Expr":{"kind":"AEXPR_OP","name":[{"String":{"sval":"="}}],"lexpr":{"ColumnRef":{"fields":[{"String":{"sval":"Account"}},{"String":{"sval":"id"}}],"location":43}},"rexpr":{"ParamRef":{"number":1,"location":56}},"location":54}},"limitOption":"LIMIT_OPTION_DEFAULT","op":"SETOP_NONE"}}}]}
  Uncaught exception:
    
    (Failure "unknown res_target")
  
  Raised at Stdlib.failwith in file "stdlib.ml", line 29, characters 17-33
  Called from Base__List.map in file "src/list.ml", line 433, characters 15-18
  Called from Oql__Ast.map_res_target in file "packages/octane/pkg/oql/ast.ml", lines 181-188, characters 4-43
  Called from Base__List.map in file "src/list.ml", line 433, characters 15-18
  Called from Base__List.map in file "src/list.ml", line 433, characters 22-45
  Called from Oql__Ast.map_select in file "packages/octane/pkg/oql/ast.ml", line 166, characters 16-85
  Called from Base__List.map in file "src/list.ml", line 433, characters 15-18
  Called from Base__List.map in file "src/list.ml", line 433, characters 15-18
  Called from Oql__Ast.statements in file "packages/octane/pkg/oql/ast.ml", lines 150-153, characters 4-95
  Re-raised at Oql__Ast.statements in file "packages/octane/pkg/oql/ast.ml", line 158, characters 4-11
  Called from Oql__Ast.parse in file "packages/octane/pkg/oql/ast.ml", line 250, characters 14-29
  Called from Ppx_octane__Ppx_query.query_rule.(fun) in file "packages/octane/pkg/ppx_octane/ppx_query.ml", line 59, characters 12-31
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
  parse: {"version":170000,"stmts":[{"stmt":{"SelectStmt":{"targetList":[{"ResTarget":{"val":{"ColumnRef":{"fields":[{"String":{"sval":"Post"}},{"String":{"sval":"id"}}],"location":7}},"location":7}}],"fromClause":[{"RangeVar":{"relname":"Account","inh":true,"relpersistence":"p","location":20}}],"limitOption":"LIMIT_OPTION_DEFAULT","op":"SETOP_NONE"}}}]}
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
  parse: {"version":170000,"stmts":[{"stmt":{"SelectStmt":{"targetList":[{"ResTarget":{"val":{"ColumnRef":{"fields":[{"String":{"sval":"Account"}},{"String":{"sval":"name"}}],"location":8}},"location":8}},{"ResTarget":{"val":{"ColumnRef":{"fields":[{"String":{"sval":"Post"}},{"String":{"sval":"content"}}],"location":22}},"location":22}}],"fromClause":[{"JoinExpr":{"jointype":"JOIN_INNER","larg":{"RangeVar":{"relname":"Post","inh":true,"relpersistence":"p","location":40}},"rarg":{"RangeVar":{"relname":"Account","inh":true,"relpersistence":"p","location":56}},"quals":{"A_Expr":{"kind":"AEXPR_OP","name":[{"String":{"sval":"="}}],"lexpr":{"ColumnRef":{"fields":[{"String":{"sval":"Account"}},{"String":{"sval":"id"}}],"location":67}},"rexpr":{"ColumnRef":{"fields":[{"String":{"sval":"Post"}},{"String":{"sval":"author"}}],"location":80}},"location":78}}}}],"limitOption":"LIMIT_OPTION_DEFAULT","op":"SETOP_NONE"}}}]}
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
  module_param: Account.id
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

