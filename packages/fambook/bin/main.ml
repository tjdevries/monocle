open Drive
module SSR = Fambook.App.SSR

let ( let* ) = Result.bind
let ( let= ) x f =
  match x with
  | Ok res -> f res
  | _ -> assert false
;;

(* let items%route = "GET /items/user_id:UserID" *)
module UserChats : Route.T = struct
  type t = { user_id : string }

  let href t = Format.sprintf "/chats/%s" t.user_id

  let parse (request : Request.t) =
    match String.split_on_char '/' request.target with
    | [ ""; "chats"; user_id ] -> Some { user_id }
    | _ -> None
  ;;

  let handle ~(ctx : Route.context) (request : Request.t) t =
    match request.meth with
    | `GET ->
      let open Fambook.Models.Chat in
      let= messages = user_messages ctx.db ~username:t.user_id in
      let chats = List.map (fun { message; _ } -> message) messages in
      let page = SSR.Chats.page { user = t.user_id; chats } in
      Response.of_string @@ JSX.render page
    | `POST ->
      let open Fambook.Models.Chat in
      let= message = Piaf.Body.to_string request.body in
      let query = Uri.query_of_encoded message in
      let message =
        List.find_map
          (fun (k, v) ->
            match k, v with
            | "message", [ message ] -> Some message
            | _ -> None)
          query
        |> Option.value ~default:"MISSING"
      in
      Logs.info (fun f -> f "Got message: %s" message);
      let= () = insert ctx.db ~username:t.user_id ~message in
      let= messages = user_messages ctx.db ~username:t.user_id in
      let chats = List.map (fun { message; _ } -> message) messages in
      let page = SSR.Chats.render_chats { user = t.user_id; chats } in
      Response.of_string ~content_type:"text/html" ~fragment:true @@ JSX.render page
    | _ -> Response.of_string "NOPE"
  ;;
end

let routes : (module Route.T) list = [ (module UserChats) ]

let inner pool =
  let open Fambook.Models in
  let* _ = Chat.drop pool in
  let* _ = Chat.create pool in
  let* _ = Chat.insert pool ~username:"tjdevries" ~message:"Hello world" in
  let* _ = Chat.insert pool ~username:"tjdevries" ~message:"Second Chat" in
  let* _ = Chat.insert pool ~username:"tjdevries" ~message:"Third Chat" in
  let* _ = Chat.insert pool ~username:"tjdevries" ~message:"Wow, beginbot is cool" in
  let* _ =
    Chat.user_chats pool ~username:"tjdevries" ~f:(fun (_, user, chat) ->
      Format.printf "%s: %s@." user chat;
      Ok ())
  in
  Ok ()
;;

let () =
  let url = Uri.of_string "postgresql://tjdevries:password@localhost:5432/fambook_dev" in
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let= db = Database.connect ~sw ~env url in
  let result =
    match true with
    | true -> inner db
    | false -> Ok ()
  in
  let () =
    match result with
    | Ok () -> ()
    | Error err -> Printf.printf "Error: %s\n" (Caqti_error.show err)
  in
  Eio.Switch.run (fun sw ->
    let port = 8082 in
    Drive.run ~sw ~env ~port ~db routes)
;;
