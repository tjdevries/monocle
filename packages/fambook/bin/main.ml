open Drive
module SSR = Fambook.App.SSR

let ( let* ) = Result.bind
let ( let= ) x f =
  match x with
  | Ok res -> f res
  | _ -> assert false
;;

let ( let@ ) x f =
  match x with
  | Some result -> f result
  | None -> failwith "Nope"
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

  let handle ~(ctx : Route.context) (request : Request.t) (t : t) =
    match request.meth with
    | `GET ->
      let open Fambook.Models.Chat in
      (* let= messages = user_messages ctx.db ~username:t.user_id in *)
      let messages = [] in
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
      (* let= _ = insert ctx.db ~username:t.user_id ~message in *)
      (* let= messages = user_messages ctx.db ~username:t.user_id in *)
      (* let chats = List.map (fun { message; _ } -> message) messages in *)
      let chats = [] in
      let page = SSR.Chats.render_chats { user = "hello"; chats } in
      Response.of_string ~content_type:"text/html" ~fragment:true @@ JSX.render page
    | _ -> Response.of_string "NOPE"
  ;;
end

let routes : (module Route.T) list = [ (module UserChats) ]

let inner pool =
  let open Fambook.Models in
  let* _ = User.Table.drop pool in
  let* _ = User.Table.create pool in
  let* user1 = User.insert pool ~name:"tjdevries" ~email:"tjdevries@gmail.com" in
  let* _ = Chat.Table.drop pool in
  let* _ = Chat.Table.create pool in
  let* chat = Chat.insert pool (* Insert a record *) ~user_id:user1.id ~message:"Hello world" in
  let* _ = Chat.update pool { chat with message = "updated" } in
  let* loaded = Chat.Model.read pool 1 in
  let _ =
    match loaded with
    | Some loaded ->
      Format.printf "loaded: %s / %s (%s)@." loaded.message loaded.user.name loaded.user.email
    | None -> Format.printf "None@."
  in
  let* _ =
    Chat.user_chats pool ~user_id:user1.id ~f:(fun { id; user_id; message } ->
      Format.printf "%d, %d: %s@." id user_id message;
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
  let= db = Octane.Database.connect ~sw ~env url in
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
    match false with
    | true -> Drive.run ~sw ~env ~port:8082 ~db routes
    | false -> ())
;;
