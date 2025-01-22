open Import
include Types
module Response = Response
module Route = Route
module Examples = Examples

let setup_log ?style_renderer level =
  Logs_threaded.enable ();
  Fmt_tty.setup_std_outputs ?style_renderer ();
  Logs.set_level ~all:true level;
  Logs.set_reporter (Logs_fmt.reporter ())
;;

let run ?(port = 80) routes =
  let open Piaf in
  setup_log (Some Info);
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let host = Eio.Net.Ipaddr.V4.loopback in
  let conn = `Tcp (host, port) in
  (* let domains = Domain.recommended_domain_count () in *)
  let domains = 1 in
  let config =
    Server.Config.create
      ~buffer_size:0x1000
      ~domains
      ~reuse_addr:true
      ~reuse_port:true
      conn
  in
  let handler = Route.to_handler env routes in
  let connection_handler (params : Request_info.t Server.ctx) =
    Logs.info (fun m -> m "Handling Request: %s" params.request.target);
    let request = params.request in
    match request.target with
    | _ ->
      (match handler request with
       | Ok response -> response
       | Error _ ->
         Piaf.Response.of_string
           ~body:(Fmt.str "OH NO %d // Error" (Domain.self () :> int))
           `Internal_server_error
       | exception _ ->
         Piaf.Response.of_string
           ~body:(Fmt.str "OH NO %d // Exception" (Domain.self () :> int))
           `Internal_server_error)
  in
  let server = Server.create ~config connection_handler in
  let _command = Server.Command.start ~sw env server in
  ()
;;
