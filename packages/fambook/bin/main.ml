let ( let* ) = Result.bind

let unwrap x f =
  match x with
  | Ok res -> f res
  | _ -> assert false
;;

let ( let= ) = unwrap

module SSR = Fambook.App.SSR

(* let page = SSR.Simple.page *)

open Drive

(* let items%route = "GET /items/user_id:UserID" *)
module UserChats : Route.T = struct
  type t = { user_id : string }

  let href t = Format.sprintf "/chats/%s" t.user_id

  let parse (request : Request.t) =
    match String.split_on_char '/' request.target with
    | [ ""; "chats"; user_id ] -> Some { user_id }
    | _ -> None
  ;;

  let handle ~ctx:_ _ _ = Response.of_string @@ JSX.render SSR.Simple.page
end

let routes : (module Route.T) list = [ (module UserChats) ]

let inner pool =
  let open Fambook.Models in
  let* _ = Chat.insert pool ~username:"tjdevries" ~message:"Hello world" in
  let* _ = Chat.insert pool ~username:"tjdevries" ~message:"Second Chat" in
  let* _ = Chat.insert pool ~username:"tjdevries" ~message:"Third Chat" in
  let* _ =
    Chat.user_chats pool ~username:"tjdevries" ~f:(fun (_, user, chat) ->
      Format.printf "%s: %s@." user chat;
      Ok ())
  in
  Ok ()
;;

open Fambook.Models

let () =
  Eio_main.run
  @@ fun env ->
  let url = "postgresql://tjdevries:password@localhost:5432/fambook_dev" |> Uri.of_string in
  Eio.Switch.run
  @@ fun sw ->
  let= pool = Database.connect ~sw ~env url in
  let _ = Chat.drop pool in
  let _ = Chat.create pool in
  let result = inner pool in
  let () =
    match result with
    | Ok () -> ()
    | Error err -> Printf.printf "Error: %s\n" (Caqti_error.show err)
  in
  Eio.Switch.run (fun sw ->
    let port = 8082 in
    Drive.run ~sw ~env ~port routes)
;;
