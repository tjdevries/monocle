Execute Test Suite:
  $ oql_parse ./examples/
  
  ===== ./examples/select_with_constants.sql =====
  json: {"version":170000,"stmts":[{"stmt":{"SelectStmt":{"targetList":[{"ResTarget":{"val":{"ColumnRef":{"fields":[{"String":{"sval":"field"}}],"location":7}},"location":7}}],"limitOption":"LIMIT_OPTION_DEFAULT","op":"SETOP_NONE"}}}]}
  Uncaught exception:
    
    (Failure "TODO: field")
  
  Raised at Stdlib.failwith in file "stdlib.ml", line 29, characters 17-33
  Called from Base__List.map in file "src/list.ml", line 433, characters 15-18
  Called from Oql__Ast.map_res_target in file "packages/octane/pkg/oql/ast.ml", lines 219-226, characters 4-43
  Called from Base__List.map in file "src/list.ml", line 433, characters 15-18
  Called from Oql__Ast.map_select in file "packages/octane/pkg/oql/ast.ml", line 204, characters 16-85
  Called from Base__List.map in file "src/list.ml", line 433, characters 15-18
  Called from Base__List.map in file "src/list.ml", line 433, characters 15-18
  Called from Oql__Ast.statements in file "packages/octane/pkg/oql/ast.ml", lines 188-191, characters 4-95
  Re-raised at Oql__Ast.statements in file "packages/octane/pkg/oql/ast.ml", line 196, characters 4-11
  Called from Oql__Ast.parse in file "packages/octane/pkg/oql/ast.ml", line 356, characters 14-29
  Called from Dune__exe__Oql_parse.print_parsed_file in file "packages/octane/bin/oql_parse.ml", line 12, characters 8-26
  Called from Base__List0.iter in file "src/list0.ml", line 66, characters 4-7
  Called from Dune__exe__Oql_parse in file "packages/octane/bin/oql_parse.ml", line 19, characters 2-38
  [2]
