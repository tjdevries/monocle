open! Core
open! Ppxlib

let make_positional_fun ~loc arg body =
  let arg_loc = Loc.make ~loc arg in
  let pattern = Ast_builder.Default.ppat_var ~loc arg_loc in
  Ast_builder.Default.pexp_fun ~loc Nolabel None pattern body
;;
