open Import

(* let user%route = "/user/user_id:UserID/:string" *)

type env = Eio_unix.Stdenv.base

type context =
  { env : env
  ; sw : Eio.Switch.t
  ; db : Database.pool
  }

module type T = sig
  type t

  val href : t -> string
  val parse : Request.t -> t option
  val handle : ctx:context -> Request.t -> t -> (Response.t, 'a) result

  (* Could use this to cache all static routes
     val is_static_route : bool *)
end

(* /user/5/hello *)

(* let%route (module UserRoute) = *)
(*   ("/user/user_id:UserID/action:string", fun { user_id; action } -> assert false) *)

(* let _ = *)
(*   let routes : (module ROUTE) list = [ (module UserRoute) ] in *)
(*   Drive.run [ user ] *)

let to_handler ~sw ~env ~db (routes : (module T) list) =
  let handler (request : Request.t) =
    List.find_map
      ~f:(fun (module Route : T) ->
        Route.parse request
        |> Option.map ~f:(fun t ->
          let ctx = { env; sw; db } in
          Route.handle ~ctx request t))
      routes
  in
  handler
;;
