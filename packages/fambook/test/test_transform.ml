let does_nothing_to_boring_string () =
  let input = "boring" in
  let output, found = Oql.Ast.replace_all_named_params_with_positional input in
  Alcotest.(check string) "does nothing: boring" input output;
  Alcotest.(check (list string)) "found" [] found
;;

let does_nothing_to_positional_params () =
  let input = "select * from users where id = $1" in
  let output, found = Oql.Ast.replace_all_named_params_with_positional input in
  Alcotest.(check string) "does nothing: positional" input output;
  Alcotest.(check (list string)) "found" [] found
;;

let substitutes_named_params () =
  let input = "select * from users where id = $identifier" in
  let output, found = Oql.Ast.replace_all_named_params_with_positional input in
  Alcotest.(check string) "changes named" "select * from users where id = $1" output;
  Alcotest.(check (list string)) "found" [ "$identifier" ] found
;;

let cases =
  ( "oql"
  , [ "parse", `Quick, does_nothing_to_boring_string
    ; "positional", `Quick, does_nothing_to_positional_params
    ; "substitutes named params", `Quick, substitutes_named_params
    ] )
;;
