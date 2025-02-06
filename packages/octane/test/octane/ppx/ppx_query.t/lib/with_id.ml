module Account = struct
  type t =
    { id : int
    ; name : string
    ; age : int
    }
  [@@deriving table { name = "users" }]
end

let%query (module AccountWithID) = "select Account.id, Account.name from Account where Account.id = $id"
