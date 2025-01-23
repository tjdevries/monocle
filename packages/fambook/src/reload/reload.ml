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
