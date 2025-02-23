open Core
open Ppxlib
open Ast_builder

module Util = struct
  let throw ~loc fmt =
    Format.kasprintf (fun str -> Location.Error.raise @@ Location.Error.make ~loc ~sub:[] str) fmt
  ;;
end

let args () = Deriving.Args.(empty)
let generate_impl ~ctxt (_, (type_declarations : type_declaration list)) =
  let loc = Expansion_context.Deriver.derived_item_loc ctxt in
  let ty =
    match type_declarations with
    | [ ty ] -> ty
    | _ -> Util.throw ~loc "ppx_table requires exactly one type declaration"
  in
  match ty with
  | { ptype_manifest =
        Some { ptyp_desc = Ptyp_variant ([ { prf_desc = Rtag (x, _, [ t ]); _ } ], _, _) }
    ; _
    } ->
    let open Ast_builder.Default in
    let construct = pexp_variant ~loc x.txt (Some [%expr value]) in
    let pat = ppat_variant ~loc x.txt (Some (ppat_var ~loc @@ Loc.make ~loc "s")) in
    [ [%stri let t (value : [%t t]) = [%e construct]]
    ; [%stri
        let get (l : [> t ] list) : [%t t] =
          Stdlib.List.find_map
            (function
              | [%p pat] -> Some s
              | _ -> None)
            l
          |> Stdlib.Option.get
        ;;]
    ]
  | _ -> Util.throw ~loc "ppx_drive: context can only be applied to a single variant type"
;;

let generator () = Deriving.Generator.V2.make (args ()) generate_impl
let my_deriver = Deriving.add "context" ~str_type_decl:(generator ())

let query_rule =
  let context = Extension.Context.structure_item in
  let extracter () =
    let open Ast_pattern in
    let pat = ppat_var __ in
    let binding = value_binding ~pat ~expr:(elist __) in
    pstr (pstr_value nonrecursive (binding ^:: nil) ^:: nil)
  in
  let my_extender =
    Extension.V3.declare "context" context (extracter ())
    @@ fun ~ctxt pat query ->
    let open Ast_builder.Default in
    let loc = Expansion_context.Extension.extension_point_loc ctxt in
    let ty_ctx =
      List.fold query ~init:[] ~f:(fun acc expr ->
        match expr with
        | { pexp_desc =
              Pexp_apply ({ pexp_desc = Pexp_ident { txt = Ldot (Lident m, "t") as txt }; _ }, _)
          ; pexp_loc
          } ->
          let t = ptyp_constr ~loc { txt; loc } [] in
          let f = { prf_desc = Rinherit t; prf_loc = pexp_loc; prf_attributes = [] } in
          f :: acc
        | _ -> Util.throw ~loc "ppx_drive: expressions must be a Module.t")
    in
    let ty = ptyp_variant ~loc ty_ctx Closed None in
    let query = elist ~loc query in
    [%stri let ctx : [%t ty] list = [%e query]]
  in
  Context_free.Rule.extension my_extender
;;

Driver.register_transformation ~rules:[ query_rule ] "ppx_drive"
