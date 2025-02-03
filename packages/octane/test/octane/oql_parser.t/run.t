Execute Test Suite:
  $ oql_parse ./examples/
  
  ===== ./examples/select_with_constants.sql =====
  { version = 130008;
    stmts =
      [{ stmt =
           Some(
             Select_stmt(
               { distinct_clause = [];
                 into_clause = None;
                 target_list =
                   [Res_target(
                      { name = "";
                        indirection = [];
                        val_ =
                          Some(
                            Column_ref(
                              { fields = [String({ str = "field"; })];
                                location = 7;
                              }));
                        location = 7;
                      })
                    ];
                 from_clause = [];
                 where_clause = None;
                 group_clause = [];
                 having_clause = None;
                 window_clause = [];
                 values_lists = [];
                 sort_clause = [];
                 limit_offset = None;
                 limit_count = None;
                 limit_option = Limit_option_default;
                 locking_clause = [];
                 with_clause = None;
                 op = Setop_none;
                 all = false;
                 larg = None;
                 rarg = None;
               }));
         stmt_location = 0;
         stmt_len = 0;
       }
       ];
  }
  Ast.Good
  
  ===== ./examples/simple_select.sql =====
  { version = 130008;
    stmts =
      [{ stmt =
           Some(
             Select_stmt(
               { distinct_clause = [];
                 into_clause = None;
                 target_list =
                   [Res_target(
                      { name = "";
                        indirection = [];
                        val_ =
                          Some(
                            Column_ref(
                              { fields = [String({ str = "name"; })];
                                location = 7;
                              }));
                        location = 7;
                      })
                    ];
                 from_clause =
                   [Range_var(
                      { catalogname = "";
                        schemaname = "";
                        relname = "Users";
                        inh = true;
                        relpersistence = "p";
                        alias = None;
                        location = 17;
                      })
                    ];
                 where_clause = None;
                 group_clause = [];
                 having_clause = None;
                 window_clause = [];
                 values_lists = [];
                 sort_clause = [];
                 limit_offset = None;
                 limit_count = None;
                 limit_option = Limit_option_default;
                 locking_clause = [];
                 with_clause = None;
                 op = Setop_none;
                 all = false;
                 larg = None;
                 rarg = None;
               }));
         stmt_location = 0;
         stmt_len = 0;
       }
       ];
  }
  Ast.Good
  
  ===== ./examples/from.sql =====
  cannot parse file ./examples/from.sql
  ===== ./examples/from_with_positional_param.sql =====
  cannot parse file ./examples/from_with_positional_param.sql
  ===== ./examples/multi_select.sql =====
  cannot parse file ./examples/multi_select.sql
  ===== ./examples/from_with_named_param.sql =====
  cannot parse file ./examples/from_with_named_param.sql
  ===== ./examples/simple_join.sql =====
  cannot parse file ./examples/simple_join.sql
  ===== ./examples/operators.sql =====
  Fatal error: exception Pbrt.Decoder.Failure(Incomplete)
  Raised at Pbrt.Decoder.skip.skip_len in file "src/runtime/pbrt.ml", line 205, characters 8-34
  Called from PGQuery__Pg_query.decode_pb_parse_result in file "packages/pg-query/lib/pg_query.ml", line 31153, characters 32-64
  Called from PGQuery__Ffi.PostgresProtobuf.parse in file "packages/pg-query/lib/ffi.ml", line 100, characters 19-58
  Called from Oql__Run.parse in file "packages/octane/pkg/oql/run.ml", line 5, characters 15-22
  Called from Dune__exe__Oql_parse.print_parsed_file in file "packages/octane/bin/oql_parse.ml", line 12, characters 8-26
  Called from Base__List0.iter in file "src/list0.ml", line 66, characters 4-7
  Called from Dune__exe__Oql_parse in file "packages/octane/bin/oql_parse.ml", line 19, characters 2-38
  [2]
