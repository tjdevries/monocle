module PG = PGQuery.ProtobufGen

type t = Good

and statement = Select of select_statement

and select_statement =
  { distinct_clause : bool
  ; into_clause : string option
  ; target_list : result_column list
  ; from_clause : from_clause
  ; where_clause : where_clause option
  ; group_clause : group_clause list
  ; having_clause : having_clause option
  ; window_clause : window_clause list
  ; values_lists : string list list
  ; sort_clause : sort_clause list
  ; limit_offset : limit_offset option
  ; limit_count : int option
  ; limit_option : limit_option
  ; locking_clause : locking_clause list
  ; with_clause : with_clause option
  ; op : setop
  ; all : bool
  ; larg : expression option
  ; rarg : expression option
  }
[@@deriving show]

let of_protobuf (stmts : PG.raw_stmt list) = ()
