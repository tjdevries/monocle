module Account = struct
  type t =
    { id : int [@primary_key { autoincrement = true }]
    ; name : string
    }
  [@@deriving table { name = "users" }]
end

module Post = struct
  type t =
    { id : int [@primary_key { autoincrement = true }]
    ; user_id : Account.Fields.id
    ; content : string
    }
  [@@deriving table { name = "posts" }]
end
