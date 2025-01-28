type 'a unfetched = [ `unfetched of 'a ]
type 'a fetched = [ `fetched of 'a ]

type ('id, 'model) fetch =
  [ 'id unfetched
  | 'model fetched
  ]

module User = struct
  type t =
    { id : int [@primary_key { autoincrement = true }]
    ; name : string
    }
  [@@deriving table { name = "users" }]

  module Model = struct
    type user = t
    type t = (int, user) fetch

    let fetch db (model : t) : user =
      match model with
      | `unfetched id -> failwith "TODO"
      | `fetched user -> user
    ;;
  end
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
