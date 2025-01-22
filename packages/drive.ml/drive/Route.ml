open Import

(* let user%route = "/user/user_id:UserID/:string" *)

type env = Eio_unix.Stdenv.base
type context = { env : env }

module type T = sig
  type t

  val href : t -> string
  val parse : string -> t option
  val handle : ctx:context -> Request.t -> t -> (Response.t, Piaf.Error.common) result

  (* Could use this to cache all static routes
     val is_static_route : bool *)
end

(* /user/5/hello *)

(* let%route (module UserRoute) = *)
(*   ("/user/user_id:UserID/action:string", fun { user_id; action } -> assert false) *)

(* let _ = *)
(*   let routes : (module ROUTE) list = [ (module UserRoute) ] in *)
(*   Drive.run [ user ] *)

let to_handler env (routes : (module T) list) =
  let handler (request : Request.t) =
    let ctx = { env } in
    List.find_map
      ~f:(fun (module Route : T) ->
        let path = request.target in
        Route.parse path |> Option.map ~f:(Route.handle ~ctx request))
      routes
    |> Option.value_exn
  in
  handler
;;

