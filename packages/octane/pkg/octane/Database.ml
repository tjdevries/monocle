module type T = Caqti_eio.CONNECTION
type db = (module T)

type db_error =
  [ Caqti_error.connect
  | Caqti_error.call_or_retrieve
  ]
type t = (db, db_error) Caqti_eio.Pool.t

(* TODO: Do we let this happen? I kind of like ONLY allowing pool usage. *)
(* let use (t : pool) f = Caqti_eio.Pool.use (fun db -> f db) t *)
let connect ~sw ~env uri : (t, 'b) result =
  Caqti_eio_unix.connect_pool ~sw ~stdenv:(env :> Caqti_eio.stdenv) uri
;;

let exec (t : t) query params = Caqti_eio.Pool.use (fun (module DB : T) -> DB.exec query params) t

let find (t : t) query params = Caqti_eio.Pool.use (fun (module DB : T) -> DB.find query params) t

let find_opt (t : t) query params =
  Caqti_eio.Pool.use (fun (module DB : T) -> DB.find_opt query params) t
;;

let iter (t : t) query params ~f =
  Caqti_eio.Pool.use (fun (module DB : T) -> DB.iter_s query f params) t
;;

let collect (t : t) query params =
  Caqti_eio.Pool.use (fun (module DB : T) -> DB.collect_list query params) t
;;
