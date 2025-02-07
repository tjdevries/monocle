module Account = struct
  type t = { id : int } [@@deriving table { name = "users" }]
end

let%query (module AccountByID) = "SELECT Account.id, Account.name FROM Account WHERE Account.id = $1"
