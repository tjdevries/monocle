open Ctypes

type parse_error = {
  message : string;
  funcname : string;
  filename : string;
  lineno : int;
  cursorpos : int;
  context : string option;
}
[@@deriving show]

type parse_result = {
  parse_tree : string;
  stderr_buffer : string option;
  error : parse_error option;
}
[@@deriving show]

let raw_parse query =
  let result = Ffi.(pg_query_parse query) in
  let parse_tree = Ffi.(getf result parse_tree) in
  let stderr_buffer = Ffi.(getf result stderr_buffer) in
  let error =
    match Ffi.(getf result error) with
    | None -> None
    | Some error_ptr ->
        let error_struct = !@error_ptr in
        let message = Ffi.(getf error_struct message) in
        let filename = Ffi.(getf error_struct filename) in
        let funcname = Ffi.(getf error_struct funcname) in
        let lineno = Ffi.(getf error_struct lineno) in
        let cursorpos = Ffi.(getf error_struct cursorpos) in
        let context = Ffi.(getf error_struct context) in
        Some { message; funcname; filename; lineno; cursorpos; context }
  in
  let () = Ffi.(pg_query_free_parse_result result) in
  { parse_tree; stderr_buffer; error }

let parse query =
  let result = raw_parse query in
  match result.error with
  | None -> Ok result.parse_tree
  | Some { message; _ } -> Error message
