include Core

module Result = struct
  include Result

  module Syntax = struct
    let ( let+ ) result f = map ~f result
    let ( let* ) t f = bind ~f t

    let ( and* ) r1 r2 =
      match r1, r2 with
      | Ok x, Ok y -> Ok (x, y)
      | Ok _, Error e | Error e, Ok _ | Error e, Error _ -> Error e
    ;;
  end
end
