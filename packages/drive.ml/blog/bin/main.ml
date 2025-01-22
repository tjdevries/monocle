open Drive

(* let user%route = "/user/user_id:UserID" *)
module UserRoute : Route.T = struct
  type t = { user_id : string }

  let href t = Format.sprintf "/user/%s" t.user_id

  let parse path =
    match String.split_on_char '/' path with
    | [ ""; "user"; user_id ] -> Some { user_id }
    | _ -> None
  ;;

  let handle ~ctx:_ _ t = Response.of_string (Drive.Examples.page t.user_id)
end

(* let items%route = "GET /items/user_id:UserID" *)
module Items : Route.T = struct
  type t = { user_id : string }

  let href t = Format.sprintf "/items/%s" t.user_id

  let parse path =
    match String.split_on_char '/' path with
    | [ ""; "items"; user_id ] -> Some { user_id }
    | _ -> None
  ;;

  let handle ~ctx:_ _ _ = Response.of_string @@ JSX.render Blog.SSR.Simple.page
end

module StaticAssets : Route.T = struct
  type t = { path : string }

  let href t = Format.sprintf "/items/%s" t.path

  let parse path =
    match String.split_on_char '/' path with
    | [ ""; "static"; path ] -> Some { path }
    | _ -> None
  ;;

  let handle ~(ctx : Route.context) _ t =
    let cwd = Eio.Stdenv.cwd ctx.env in
    let file_contents = Eio.Path.(load (cwd / t.path)) in
    Response.of_string file_contents
  ;;
end

module HotReload = struct
  type t = unit

  let href _ = "reload"

  let parse path =
    match path with
    | "reload" | "/reload" -> Some ()
    | _ -> None
  ;;

  let handle ~ctx:_ request () =
    Logs.info (fun m -> m "Requesting reload...");
    let open Piaf in
    Response.Upgrade.websocket request ~f:(fun wsd ->
      let frames = Ws.Descriptor.messages wsd in
      Stream.iter
        ~f:(fun (_opcode, frame) ->
          Fmt.pr "@.RECEIVED NEW MSG@.";
          Ws.Descriptor.send_iovec wsd frame)
        frames)
  ;;
end

module BlogRoute : Route.T = struct
  type t = unit

  let href _ = "/blog/main.js"

  let parse path =
    match path with
    | "/blog/main.js" -> Some ()
    | _ -> None
  ;;

  let handle ~ctx:_ _request () =
    Response.of_string
      ~content_type:"text/javascript"
      {|
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from "@melange/App.js";

const rootElement = document.getElementById('root');
const root = createRoot(rootElement);

const app = StrictMode({
  children: App({}),
});

root.render(app);
    |}
  ;;
end

module CompiledJS : Route.T = struct
  type t = unit

  let href _ = "compiled"

  let parse path =
    match path with
    | "compiled" | "/compiled" -> Some ()
    | _ -> None
  ;;

  let handle ~ctx:_ _request () =
    Response.of_string
      {|
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Melange Basic Template</title>

    <!-- if development -->
    <script type="module">
      import RefreshRuntime from 'http://localhost:5173/@react-refresh'
      RefreshRuntime.injectIntoGlobalHook(window)
      window.$RefreshReg$ = () => {}
      window.$RefreshSig$ = () => (type) => type
      window.__vite_plugin_react_preamble_installed__ = true
    </script>
    <script type="module" src="http://localhost:5173/@vite/client"></script>
    <script type="module" src="http://localhost:5173/blog/main.js"></script>

    <!-- <script type="module" src="/blog/main.js"></script> -->
	<style>
		* { background: black; color: white; }
	</style>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>

    |}
  ;;
end

let routes : (module Route.T) list =
  [ (module HotReload)
  ; (module UserRoute)
  ; (module Items)
  ; (module CompiledJS)
  ; (module BlogRoute)
  ]
;;

let _ =
  let version = `piaf in
  match version with
  | `piaf -> Drive.run ~port:8082 routes
;;
