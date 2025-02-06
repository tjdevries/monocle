module Account = struct
  type t =
    { id : int
    ; name : string
    }
  [@@deriving table { name = "users" }]
end

let%query (module AccountByID) = "SELECT Account.name, $2 FROM Account WHERE Account.id = $1"
