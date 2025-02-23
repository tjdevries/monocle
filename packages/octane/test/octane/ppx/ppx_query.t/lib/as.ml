module Account = struct
  type t =
    { id : int [@primary_key { autoincrement = true }]
    ; name : string
    ; age : int
    }
  [@@deriving table { name = "accounts" }]
end

let%query (module AccountNameQuery) = "SELECT Account.id as account_id, Account.name FROM Account"
let%query (module AccountNameQuery) = "SELECT Account.* as my_account, Account.name FROM Account"
