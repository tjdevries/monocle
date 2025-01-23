open Import
include Types

module Database = Database
module Examples = Examples
module Request = Request
module Response = Response
module Route = Route

let setup_log ?style_renderer level =
  Logs_threaded.enable ();
  Fmt_tty.setup_std_outputs ?style_renderer ();
  Logs.set_level ~all:true level;
  Logs.set_reporter (Logs_fmt.reporter ())
;;

let run ~port ~env ~sw ~db routes =
  setup_log (Some Info);
  let open Piaf in
  let host = Eio.Net.Ipaddr.V4.loopback in
  let conn = `Tcp (host, port) in
  (* let domains = Domain.recommended_domain_count () in *)
  let domains = 1 in
  let config =
    Server.Config.create ~buffer_size:0x1024 ~domains ~reuse_addr:true ~reuse_port:true conn
  in
  let handler = Route.to_handler ~db ~env ~sw routes in
  let connection_handler (params : Request_info.t Server.ctx) =
    Logs.info (fun m -> m "Handling Request: %s" params.request.target);
    let request = params.request in
    match handler request with
    | Some (Ok response) -> response
    | Some (Error err) ->
      Piaf.Response.of_string
        ~body:
          (Fmt.str
             "OH NO %d // Error: %s"
             (Domain.self () :> int) (* (Piaf.Error.to_string (err :> Piaf.Error.t))) *)
             "oops")
        `Internal_server_error
    | None ->
      Piaf.Response.of_string ~body:(Fmt.str "404 not found: %d" (Domain.self () :> int)) `Not_found
    | exception _ ->
      Piaf.Response.of_string
        ~body:(Fmt.str "OH NO %d // Exception" (Domain.self () :> int))
        `Internal_server_error
  in
  let server = Server.create ~config connection_handler in
  let _command = Server.Command.start ~sw env server in
  ()
;;

let main ~port routes =
  Eio_main.run @@ fun env -> Eio.Switch.run @@ fun sw -> run ~port ~env ~sw routes
;;
