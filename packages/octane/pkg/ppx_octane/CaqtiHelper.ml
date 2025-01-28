open Ppxlib
open Ast_builder

let get_caqti_t ~loc length =
  match length with
  | 2 -> [%expr t2]
  | 3 -> [%expr t3]
  | 4 -> [%expr t4]
  | 5 -> [%expr t5]
  | 6 -> [%expr t6]
  | 7 -> [%expr t7]
  | 8 -> [%expr t8]
  | 9 -> [%expr t9]
  | _ -> failwith "Yo, please use less fielsd automatically :)"
;;
