module type T = Caqti_eio.CONNECTION

type t = (module T)

(* TODO: Don't know if I like this *)
type db_error =
  [ Caqti_error.connect
  | Caqti_error.call_or_retrieve
  ]

type pool = (t, db_error) Caqti_eio.Pool.t

(* TODO: Do we let this happen? I kind of like ONLY allowing pool usage. *)
(* let use (t : pool) f = Caqti_eio.Pool.use (fun db -> f db) t *)
let connect ~sw ~env uri : (pool, 'a) result =
  Caqti_eio_unix.connect_pool ~sw ~stdenv:(env :> Caqti_eio.stdenv) uri
;;

let exec (t : pool) query params =
  Caqti_eio.Pool.use (fun (module DB : T) -> DB.exec query params) t
;;

let iter (t : pool) query params ~f =
  Caqti_eio.Pool.use (fun (module DB : T) -> DB.iter_s query f params) t
;;
