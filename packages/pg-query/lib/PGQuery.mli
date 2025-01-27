(** A thin wrapper around {{: https://github.com/lfittl/libpg_query} libpg_query}. *)

type parse_error = {
  message : string;  (** The error message *)
  funcname : string;
      (** The name of the parsing function where the error occurred *)
  filename : string;
      (** The filename of the parsing code where the error occurred *)
  lineno : int;  (** The line number of [filename] where the error occurred *)
  cursorpos : int;  (** The position in the query where the error occurred *)
  context : string option;  (** Optional additional context *)
}
(** Represents a syntax error in parsing some SQL.

[message] and [cursorpos] are probably the most useful fields. Note that [filename], [funcname] and [lineno] refer to
the location in the {i parsing code} that the error occured, not to the input SQL. *)

type parse_result = {
  parse_tree : string;  (** The parse tree of the query, as JSON *)
  stderr_buffer : string option;  (** A field of unknown purpose *)
  error : parse_error option;
      (** [Some parse_error] for queries where parsing failed and [None] for successful ones *)
}
(** Represents the overall result of a parse *)

val raw_parse : string -> parse_result
(** Parses a string containing SQL and return a [parse_result] corresponding to the libpg_query struct *)

val parse : string -> (string, string) result
(** Parses a string containing SQL and returns either [Ok parse_tree] or [Error error_message] *)

val show_parse_error : parse_error -> string
(** Derived function to display a parse error *)

val show_parse_result : parse_result -> string
(** Derived function to display a parse_result *)
