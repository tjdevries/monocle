TAKEN FROM: https://github.com/roddyyaga/pg_query-ocaml/tree/master

# pg_query-ocaml

Bindings for [pg_query](https://github.com/lfittl/libpg_query) for parsing PostgreSQL. Documentation is
[here](https://roddyyaga.github.io/pg_query-ocaml/pg_query/index.html).

## Usage

This provides a library that can be used in OCaml code like so:
```ocaml
let statement = "SELECT user, email FROM users WHERE id = 7"

let () =
  match Pg_query.parse statement with
  | Ok parse_tree -> use parse_tree
  | Error error_message -> use error_message
```

and a command-line utility:

```bash
$ echo "SELECT * FROM users" >> good.sql
$ echo "SELECT * FFROM users" >> bad.sql
$ pg_check good.sql bad.sql
[{"RawStmt": {"stmt": {"SelectStmt": {"targetList": [{"ResTarget": {"val": {"ColumnRef": {"fields": [{"A_Star": {}}], "location": 7}}, "location": 7}}], "fromClause": [{"RangeVar": {"relname": "users", "inh": true, "relpersistence": "p", "location": 14}}], "op": 0}}}}]
syntax error at or near "FFROM"
```
