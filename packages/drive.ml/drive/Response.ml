type t = Piaf.Response.t

let of_string ?(content_type = "text/html") body =
  let body =
    match content_type with
    | "text/html" ->
      Format.sprintf
        {| <style>
            * { background: black; color: white; }
           </style> %s |}
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
