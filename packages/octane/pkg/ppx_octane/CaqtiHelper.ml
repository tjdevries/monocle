open Core
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

let make_params_field ~loc ?model name =
  let ident =
    match model with
    | Some model -> Ldot (Ldot (Longident.Lident model, "Params"), name)
    | None -> Ldot (Longident.Lident "Params", name)
  in
  Default.pexp_ident ~loc (Loc.make ~loc ident)
;;

module Record = struct
  type record_field =
    { model : string option
    ; name : string
    ; loc : location
    }
  let record_field ~loc ?model name = { model; name; loc }

  let derive ~loc (fields : record_field list) =
    let body =
      Default.pexp_record
        ~loc
        (List.map fields ~f:(fun { name; _ } ->
           let ident = Loc.make ~loc (Lident name) in
           let expr = Default.pexp_ident ~loc ident in
           ident, expr))
        None
    in
    let record =
      List.fold_right fields ~init:body ~f:(fun { name; _ } acc ->
        GenHelper.make_positional_fun ~loc name acc)
    in
    let product =
      List.fold_right fields ~init:[%expr proj_end] ~f:(fun { name; model; _ } acc ->
        let ident = Loc.make ~loc (Lident name) in
        let access = Default.pexp_field ~loc [%expr record] ident in
        let param = make_params_field ~loc ?model name in
        Default.pexp_apply
          ~loc
          [%expr proj]
          [ Nolabel, param; Nolabel, [%expr fun record -> [%e access]]; Nolabel, acc ])
    in
    [%stri
      let record =
        let record = [%e record] in
        product record @@ [%e product]
      ;;]
  ;;
end
