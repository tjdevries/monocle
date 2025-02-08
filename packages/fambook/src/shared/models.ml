(*
   user: User.Model.t
user: User.t [@model]
user: User.Model.t [@foreign { on_cascade = "delete" }]

Constraints:
- I don't want to be able to accidentally load another model
- If something is already loaded, don't load it again
- Ideally, I want to know in the type system whether it's loaded or not
- User must not have to type crazy type signatures to get this to work
*)

module Account = struct
  type t =
    { id : int [@primary_key { autoincrement = true }]
    ; name : string
    ; email : string
    }
  [@@deriving table { name = "accounts" }]
end

module Photo = struct
  type t =
    { id : int [@primary_key { autoincrement = true }]
    ; user_id : Account.Fields.id [@references { on_cascade = `delete }]
    ; url : string
    }
  [@@deriving table { name = "photos" }]
end

(* module Album = struct *)
(*   type t = *)
(*     { id : int [@primary_key { autoincrement = true }] *)
(*     ; user_id : Account.Fields.id [@references { on_cascade = `delete }] *)
(*     ; name : string *)
(*     } *)
(*   [@@deriving table { name = "albums" }] *)
(* end *)
