module Account = struct
  type t =
    { id : int [@primary_key { autoincrement = true }]
    ; name : string
    ; age : int
    }
  [@@deriving table { name = "accounts" }]
end

let%query (module AccountNameQuery) = "SELECT Account.id, Account.name FROM Account"
