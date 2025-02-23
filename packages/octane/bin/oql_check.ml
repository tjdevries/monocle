(** A utility to parse PostgreSQL code *)

open Cmdliner

let read_from_stdin () =
  (* We use 65536 because that is the size of OCaml's IO buffers. *)
  let chunk_size = 65536 in
  let buffer = Buffer.create chunk_size in
  let rec loop () =
    Buffer.add_channel buffer stdin chunk_size;
    loop ()
  in
  try loop () with
  | End_of_file -> Buffer.contents buffer
;;

let get_contents = function
  | "-" -> read_from_stdin ()
  | filename ->
    Format.printf "filename: %s\n" filename;
    let ic = open_in filename in
    let file_length = in_channel_length ic in
    let contents = really_input_string ic file_length in
    close_in ic;
    Format.printf "%s@." contents;
    contents
;;

let do_parse files =
  let f _ filename =
    let result = get_contents filename |> Oql.Run.parse in
    match result with
    | Ok (_, parsed) ->
      List.iter (fun stmt -> Format.printf "%s@." (Oql.Ast.show_statement stmt)) parsed;
      1
    | _ -> failwith "cannot parse"
  in
  let status = files |> List.fold_left f 0 in
  Ok status
;;

let info =
  let doc = "Parses PostgreSQL" in
  let man =
    [ `S Manpage.s_description
    ; `P
        "Given a list of files, parses each of them as PostgreSQL and prints\neither the parsetree or an error message for each."
    ]
  in
  Cmd.info
    "pg_check"
    ~version:"0.9.6"
    ~doc
    ~exits:
      Cmd.
        [ Exit.info 0 ~doc:"if all files were parsed successfully."
        ; Exit.info 1 ~doc:"on parsing errors."
        ; Exit.info 124 ~doc:"on command line parsing errors."
        ; Exit.info 125 ~doc:"on unexpected internal errors."
        ]
    ~man
;;

let files =
  let doc = "A list of files to parse. If no files are provided, reads from stdin." in
  Arg.(value & pos_all non_dir_file [ "-" ] & info [] ~docv:"FILE(S)" ~doc)
;;

let cmd = Cmd.v info files

let () =
  Format.printf "Executing cmd:\n";
  match Cmd.eval_value cmd with
  | Ok (`Ok files) ->
    let _ = do_parse files in
    exit 0
  | Error `Term -> exit 1
  | Error `Parse -> exit 124
  | Error `Exn -> exit 125
  | _ -> exit 1
;;
