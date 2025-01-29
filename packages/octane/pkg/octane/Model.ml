(* FOR NOW: WE ARE NOT GOING TO USE THIS. *)

type 'a id = [ `id of 'a ]
type ('id, 'model) model = [ `model of 'id * 'model ]

type ('id, 'model) t =
  [ 'id id
  | ('id, 'model) model
  ]

let fetch db (model : _ t) =
  match model with
  | `id id -> failwith "TODO"
  | `model (_, model) -> model
;;

let unwrap (t : _ model) =
  match t with
  | `model (_, t) -> t
;;

let id (t : _ t) =
  match t with
  | `id id -> id
  | `model (id, _) -> id
;;
