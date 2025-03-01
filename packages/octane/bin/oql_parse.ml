open Bos.OS
open Oql
open Core

let print_parsed_file fpath =
  Fmt.pr "@.===== %s =====@." (Fpath.to_string fpath);
  let contents =
    match File.read fpath with
    | Ok str -> str
    | _ -> Fmt.failwith "cannot read file %a" Fpath.pp fpath
  in
  match Run.parse contents with
  | Ok (_, parsed) -> Fmt.pr "%a@." Ast.pp parsed
  | Error _ -> Fmt.pr "cannot parse file %a" Fpath.pp fpath
;;

let _ =
  let files = Stdlib.Sys.argv.(1) |> Fpath.v |> Dir.contents |> Rresult.R.get_ok in
  List.iter ~f:print_parsed_file files
;;
