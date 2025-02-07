module User = struct
  type t =
    { id : int [@primary_key { autoincrement = true }]
    ; user : string
    ; email : string
    }
  [@@deriving table { name = "users" }]
end

let x db = User.insert ~user:"tjdevries" ~email:"tjdevries@gmail.com" db
let _ = x
