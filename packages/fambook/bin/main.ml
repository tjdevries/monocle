let ( let* ) = Result.bind

let () =
  Eio_main.run
  @@ fun env ->
  let url =
    Printf.sprintf
      "postgresql://%s%s%s%s"
      (match Sys.getenv_opt "PGUSER" with
       | Some user -> user ^ "@"
       | None -> "tjdevries:password@")
      (match Sys.getenv_opt "PGHOST" with
       | Some host -> host
       | None -> "localhost")
      (match Sys.getenv_opt "PGPORT" with
       | Some port -> ":" ^ port
       | None -> ":5432")
      (match Sys.getenv_opt "PGDATABASE" with
       | Some database -> "/" ^ database
       | None -> "/fambook_dev")
    |> Uri.of_string
  in
  (* Note: Caqti_eio_unix is required for the postgresql driver, while the pure ocaml pgx can be used with Caqti_eio*)
  let open Fambook.Models in
  let result =
    Caqti_eio_unix.with_connection
      ~stdenv:(env :> Caqti_eio.stdenv)
      url
      (fun db ->
        let* _ = Chat.drop db in
        let* _ = Chat.create db in
        let* _ = Chat.insert db ~username:"tjdevries" ~message:"Hello world" in
        let* _ = Chat.insert db ~username:"tjdevries" ~message:"Second Chat" in
        let* _ =
          Chat.user_chats db ~username:"tjdevries" ~f:(fun (_, user, chat) ->
            Format.printf "%s: %s@." user chat;
            Ok ())
        in
        Ok ())
  in
  match result with
  | Ok () -> ()
  | Error err -> Printf.printf "Error: %s\n" (Caqti_error.show err)
;;
