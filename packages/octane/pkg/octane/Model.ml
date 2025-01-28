type 'a unfetched = [ `unfetched of 'a ]
type ('id, 'model) fetched = [ `fetched of 'id * 'model ]

type ('id, 'model) t =
  [ 'id unfetched
  | ('id, 'model) fetched
  ]

let fetch db (model : _ t) =
  match model with
  | `unfetched id -> failwith "TODO"
  | `fetched (_, model) -> model
;;

let unwrap (t : _ fetched) =
  match t with
  | `fetched (_, t) -> t
;;

let id (t : _ t) =
  match t with
  | `unfetched id -> id
  | `fetched (id, _) -> id
;;
