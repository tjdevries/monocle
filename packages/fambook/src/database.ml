module type T = Caqti_eio.CONNECTION

type t = (module T)

let exec (module DB : T) query params = DB.exec query params
let iter (module DB : T) query params ~f = DB.iter_s query f params
