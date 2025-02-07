module Account = struct
  type t =
    { id : int
    ; name : string
    }
  [@@deriving table { name = "users" }]
end

let%query (module AccountByID) = "SELECT Account.name FROM Account WHERE Account.id = $1::int"
