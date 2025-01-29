(* Hack needed to make symbols available, see constfun's comment here
 * https://github.com/ocamllabs/ocaml-ctypes/issues/541 *)
external _force_link_ : unit -> unit = "pg_query_free_parse_result"
external _force_link_protobuf_ : unit -> unit = "pg_query_free_protobuf_parse_result"

type parse_error =
  { message : string
  ; funcname : string
  ; filename : string
  ; lineno : int
  ; cursorpos : int
  ; context : string option
  }
[@@deriving show]

open Ctypes
open Foreign

(** Represents [PgQueryError] *)
type pg_query_error

let pg_query_error : pg_query_error structure typ = structure "PgQueryError"

(* See pg_query.h for meanings *)
let message = field pg_query_error "message" string

let funcname = field pg_query_error "funcname" string

let filename = field pg_query_error "filename" string

let lineno = field pg_query_error "lineno" int

let cursorpos = field pg_query_error "cursorpos" int

let context = field pg_query_error "context" string_opt

let () = seal pg_query_error

(** Represents [PgQueryParseResult] *)
type pg_query_parse_result

let pg_query_parse_result : pg_query_parse_result structure typ = structure "PgQueryParseResult"

let parse_tree = field pg_query_parse_result "parse_tree" string

let stderr_buffer = field pg_query_parse_result "stderr_buffer" string_opt

let error = field pg_query_parse_result "error" (ptr_opt pg_query_error)

let () = seal pg_query_parse_result

let pg_query_parse = foreign "pg_query_parse" (string @-> returning pg_query_parse_result)

let pg_query_free_parse_result =
  foreign "pg_query_free_parse_result" (pg_query_parse_result @-> returning void)
;;

(** Represents [PgQueryError] *)
module PostgresProtobuf = struct
  type pg_query_protobuf
  let pg_query_protobuf : pg_query_protobuf structure typ = structure "PgQueryProtobuf"
  let len = field pg_query_protobuf "len" uint32_t
  let data = field pg_query_protobuf "data" string
  let () = seal pg_query_protobuf

  type pg_query_protobuf_parse_result
  let pg_query_protobuf_parse_result : pg_query_protobuf_parse_result structure typ =
    structure "PgQueryProtobufParseResult"
  ;;
  let parse_tree = field pg_query_protobuf_parse_result "parse_tree" pg_query_protobuf
  let stderr_buffer = field pg_query_protobuf_parse_result "stderr_buffer" string_opt
  let error = field pg_query_protobuf_parse_result "error" (ptr_opt pg_query_error)
  let () = seal pg_query_protobuf_parse_result

  let pg_query_parse_protobuf =
    foreign "pg_query_parse_protobuf" (string @-> returning pg_query_protobuf_parse_result)
  ;;

  let pg_query_free_protobuf_parse_result =
    foreign "pg_query_free_protobuf_parse_result" (pg_query_protobuf_parse_result @-> returning void)
  ;;

  let parse query =
    let result = pg_query_parse_protobuf query in
    let parse_tree = getf result parse_tree in
    let data = getf parse_tree data in
    match getf result error with
    | Some error_ptr ->
      let error_struct = !@error_ptr in
      let message = getf error_struct message in
      let filename = getf error_struct filename in
      let funcname = getf error_struct funcname in
      let lineno = getf error_struct lineno in
      let cursorpos = getf error_struct cursorpos in
      let context = getf error_struct context in
      Error { message; funcname; filename; lineno; cursorpos; context }
    | None ->
      let () = pg_query_free_protobuf_parse_result result in
      let decoder = Pbrt.Decoder.of_string data in
      let result = Pg_query.decode_pb_parse_result decoder in
      Ok result
  ;;
end
