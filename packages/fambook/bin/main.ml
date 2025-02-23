open Drive
open Fambook.Models

module SSR = Fambook.SSR

let ( let* ) = Result.bind
let ( let= ) x f =
  match x with
  | Ok res -> f res
  | _ -> assert false
;;

let%query (module PhotosForUserByID) =
  "SELECT Photo.*
    FROM Photo INNER JOIN Account ON Account.id = Photo.user_id
    WHERE Account.id = $1"
;;

(* let items%route = "GET /items/user_id:UserID" *)
module UserPhotos : Route.T = struct
  type t = { user_id : int }

  let href t = Format.sprintf "/photos/%d" t.user_id

  let parse (request : Request.t) =
    match String.split_on_char '/' request.target with
    | [ ""; "photos"; user_id ] -> Some { user_id = int_of_string user_id }
    | _ -> None
  ;;

  let handle ~(ctx : Drive.Route.context) (request : Request.t) (t : t) =
    let= account = Account.read ctx.db t.user_id in
    let account = Core.Option.value_exn account in
    match request.meth with
    | `GET ->
      let= photos = PhotosForUserByID.query ctx.db t.user_id in
      let photos = Core.List.map ~f:(fun p -> p.photo) photos in
      let page = SSR.Photos.page { user = account; photos } in
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
      let= _ = Photo.insert ctx.db ~user_id:t.user_id ~url:message ~comment:"Message from chat" in
      let= photos = PhotosForUserByID.query ctx.db t.user_id in
      let photos = Core.List.map photos ~f:(fun p -> p.photo) in
      let page = SSR.Photos.render_photos { user = account; photos } in
      Response.of_string ~content_type:"text/html" ~fragment:true @@ JSX.render page
    | _ -> Response.of_string "NOPE"
  ;;
end

let routes : (module Route.T) list = [ (module UserPhotos) ]

let setup pool =
  let* _ = Account.Table.drop pool in
  let* _ = Photo.Table.drop pool in
  let* _ = Account.Table.create pool in
  let* _ = Photo.Table.create pool in
  let* user = Account.insert pool ~name:"tjdevries" ~email:"tjdevries@example.com" in
  let* _ =
    Photo.insert
      pool
      ~user_id:user.id
      ~url:"https://pbs.twimg.com/profile_images/1613151603564986368/dZoNeRKn_400x400.jpg"
      ~comment:"First Photo"
  in
  let* _ =
    Photo.insert
      pool
      ~user_id:user.id
      ~url:"https://pbs.twimg.com/profile_images/1759330620160049152/2i_wkOoK_400x400.jpg"
      ~comment:"Second Photo"
  in
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

(* class user_context = *)
(*   object *)
(*     method user : string = "teej_dv" *)
(*   end *)
(**)
(* class log_context = *)
(*   object *)
(*     method log : string -> unit = fun s -> print_endline s *)
(*   end *)
(**)
(* class time_context = *)
(*   object *)
(*     method time : int = 42 *)
(*   end *)
(**)
(* class context = *)
(*   object *)
(*     inherit user_context *)
(*     inherit log_context *)
(*     inherit time_context *)
(*   end *)
(**)
(* let log_only = new log_context *)
(* let context = new context *)
(**)
(* let handle ctx = *)
(*   let user = ctx#user in *)
(*   (* do some real things with this  *) *)
(*   Fmt.str "user: %s" user *)
(* ;; *)
(**)
(* let _ = handle context *)
(* let _ = handle log_only *)

module User = struct
  type t = [ `user of string ] [@@deriving context]
end

module Log = struct
  type t = [ `log of string -> unit ] [@@deriving context]
end

(* let ctx : [ User.t | Log.t ] list = [ User.t "teej_dv"; Log.t print_endline ] *)

let%context ctx = [ User.t "teej_dv"; Log.t print_endline ]
let user = User.get ctx

let%context ctx = [ Log.t print_endline ]
let user = User.get ctx
