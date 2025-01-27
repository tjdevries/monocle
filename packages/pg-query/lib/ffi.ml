(* Hack needed to make symbols available, see constfun's comment here
 * https://github.com/ocamllabs/ocaml-ctypes/issues/541 *)
external _force_link_ : unit -> unit = "pg_query_free_parse_result"

open Ctypes
open Foreign

type pg_query_error
(** Represents [PgQueryError] *)

let pg_query_error : pg_query_error structure typ = structure "PgQueryError"

(* See pg_query.h for meanings *)
let message = field pg_query_error "message" string

let funcname = field pg_query_error "funcname" string

let filename = field pg_query_error "filename" string

let lineno = field pg_query_error "lineno" int

let cursorpos = field pg_query_error "cursorpos" int

let context = field pg_query_error "context" string_opt

let () = seal pg_query_error

type pg_query_parse_result
(** Represents [PgQueryParseResult] *)

let pg_query_parse_result : pg_query_parse_result structure typ =
  structure "PgQueryParseResult"

let parse_tree = field pg_query_parse_result "parse_tree" string

let stderr_buffer = field pg_query_parse_result "stderr_buffer" string_opt

let error = field pg_query_parse_result "error" (ptr_opt pg_query_error)

let () = seal pg_query_parse_result

let pg_query_parse =
  foreign "pg_query_parse" (string @-> returning pg_query_parse_result)

let pg_query_free_parse_result =
  foreign "pg_query_free_parse_result" (pg_query_parse_result @-> returning void)
