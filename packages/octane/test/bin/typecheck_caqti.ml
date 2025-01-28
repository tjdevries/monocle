module User = struct
  type t =
    { user : string
    ; email : string
    }
  [@@deriving table { name = "users" }]
end

let x db = User.insert ~user:"tjdevries" ~email:"tjdevries@gmail.com" db
