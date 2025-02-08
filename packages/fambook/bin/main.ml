open Drive
module SSR = Fambook.App.SSR

let ( let* ) = Result.bind
let ( let= ) x f =
  match x with
  | Ok res -> f res
  | _ -> assert false
;;

(* let items%route = "GET /items/user_id:UserID" *)
module UserPhotos : Route.T = struct
  type t = { user_id : string }

  let href t = Format.sprintf "/photos/%s" t.user_id

  let parse (request : Request.t) =
    match String.split_on_char '/' request.target with
    | [ ""; "photos"; user_id ] -> Some { user_id }
    | _ -> None
  ;;

  let handle ~ctx:_ (request : Request.t) (t : t) =
    match request.meth with
    | `GET ->
      let chats = [] in
      let page = SSR.Photos.page { user = t.user_id; chats } in
      Response.of_string @@ JSX.render page
    | `POST ->
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
      let page = SSR.Photos.render_photos { user = "hello"; chats } in
      Response.of_string ~content_type:"text/html" ~fragment:true @@ JSX.render page
    | _ -> Response.of_string "NOPE"
  ;;
end

let routes : (module Route.T) list = [ (module UserPhotos) ]

open Fambook.Models

let%query (module UserInfoQuery) = "SELECT Account.id, Account.name, Account.email FROM Account"

let setup pool =
  let* _ = Account.Table.drop pool in
  let* _ = Photo.Table.drop pool in
  let* _ = Account.Table.create pool in
  let* _ = Photo.Table.create pool in
  let* user = Account.insert pool ~name:"tjdevries" ~email:"tjdevries@example.com" in
  let* _ = Photo.insert pool ~user_id:user.id ~url:"https://picsum.photos/200/300" in
  let* _ = Photo.insert pool ~user_id:user.id ~url:"https://picsum.photos/300/300" in
  let* _ = Account.insert pool ~name:"theprimeagen" ~email:"cantread@example.com" in
  Ok ()
;;

let () =
  let url = Uri.of_string "postgresql://tjdevries:password@localhost:5432/fambook_dev" in
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let= db = Octane.Database.connect ~sw ~env url in
  let= () = setup db in
  Eio.Switch.run (fun sw ->
    match true with
    | true -> Drive.run ~sw ~env ~port:8082 ~db routes
    | false -> ())
;;
