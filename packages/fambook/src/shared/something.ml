module Account = Models.Account

module Router = struct
  type t =
    | Home
    | About
    | UserPhotos of Account.t
  (* [@@deriving router] *)
end
(**)
(* (* type safe path *) *)
(* let home = Router.href Home  *)
(**)
(* let user_photos = Router.href (UserPhotos account) *)
