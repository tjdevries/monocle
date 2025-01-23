type t = Piaf.Response.t

let of_string ?(content_type = "text/html") ?(fragment = false) body =
  let body =
    match fragment, content_type with
    | false, "text/html" ->
      Format.sprintf
        {| 
<html>
  <head>
    <script src="https://unpkg.com/htmx.org@2.0.4/dist/htmx.js" integrity="sha384-oeUn82QNXPuVkGCkcrInrS1twIxKhkZiFfr2TdiuObZ3n3yIeMiqcRzkIcguaof1" crossorigin="anonymous"></script>
    <style>
        * { background: black; color: white; }
    </style>
  </head>
  <body>
  %s
  </body>
</html> |}
        body
    | _ -> body
  in
  (* Cohttp_eio.Server.respond_string () ~status:`OK *)
  Ok
    (Piaf.Response.of_string
       ~headers:(Piaf.Headers.of_list [ "content-type", content_type ])
       ~body
       `OK)
;;
