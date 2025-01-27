open Ppxlib

let make_positional_param_expr ~loc i =
  let ident = Loc.make ~loc (Lident ("p" ^ Int.to_string i)) in
  Ast_builder.Default.pexp_ident ~loc ident
;;
