module User = struct
  type t =
    { id : int [@primary_key { autoincrement = true }]
    ; name : string
    }
  [@@deriving table { name = "users" }]
end

module Post = struct
  type t =
    { id : int [@primary_key { autoincrement = true }]
    ; user : User.Model.t
    ; content : string
    }
  [@@deriving table { name = "posts" }]

  let user_name db t =
    let user = User.Model.fetch db t.user in
    user.name
  ;;
end
