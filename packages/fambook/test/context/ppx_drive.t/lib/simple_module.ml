module User = struct
  type t = [ `user of string ] [@@deriving context]
end

module Log = struct
  type t = [ `log of string -> unit ] [@@deriving context]
end

(* let%context ctx = [ User.t "teej_dv"; Log.t print_endline ] *)
let ctx = [ User.t "teej_dv" ]

let user = User.get ctx
