(lang dune 3.16)

(cram enable)

(using menhir 3.0)

(using directory-targets 0.1)

(using melange 0.1)

(dialect
 (name mlx)
 (implementation
  (extension mlx)
  (merlin_reader mlx)
  (preprocess
   (run mlx-pp %{input-file}))))

(name monocle)

(source
 (github tjdevries/monocle.ml))

(license MIT)

(authors "TJ DeVries")

(maintainers "TJ DeVries")

(generate_opam_files false)

(pin
 (url "git+https://github.com/riot-ml/riot.git")
 (package
  (name riot)))

; (pin
;  (url "git+https://github.com/ocaml-mlx/mlx.git")
;  (package (name mlx)))

(package
 (name fambook)
 (depends ocaml dune ocamlformat caqti caqti-eio caqti-driver-postgresql))

(package
 (name oql)
 (synopsis "OCaml Query Language")
 (description "OCaml Query Language - very cool")
 (depends
  ;; OCaml deps
  ocaml
  dune
  ocamlformat
  ;; Parsing deps
  menhir
  menhirLib
  DBCaml
  DBCamlSqlite
  bos
  serde
  serde_derive
  (mirage-crypto-rng
   (>= "1"))
  fmt
  core
  ppx_deriving
  ppx_jane)
 (tags
  (topics "oql")))

(package
 (name octane)
 (synopsis "The fastest, hottest")
 (description "The fastest, hottest")
 (tags
  (topics "sql" "database" "query builder"))
 (depends
  ocaml
  dune
  fmt
  bos
  core
  ppx_deriving
  ppx_expect
  ;; Riot suite
  DBCaml
  DBCamlSqlite
  riot
  serde
  serde_derive
  ;; Local projects
  oql
  ppx_octane_dbcaml))

(package
 (name ppx_octane_caqti)
 (synopsis "PPX for deriving octane tables, queries and more")
 (description
  "PPX for deriving octane tables, queries and more. Includes %query, %table")
 (depends ocaml dune ppxlib fmt bos core oql))

(package
 (name ppx_octane_dbcaml)
 (synopsis "PPX for deriving octane tables, queries and more")
 (description
  "PPX for deriving octane tables, queries and more. Includes %query, %table")
 (depends ocaml dune ppxlib fmt bos core oql))

;; Serde

(package
 (name serde)
 (depends
  ocaml
  (qcheck :with-test)
  (rio
   (>= "0.0.8"))
  (spices :with-test)
  dune))

(package
 (name serde_derive)
 (depends
  ocaml
  (ppx_deriving
   (>= "5.2.1"))
  (ppxlib
   (>= "0.28.0"))
  (serde
   (= :version))
  (serde_json
   (and
    :with-test
    (= :version)))
  dune))

(package
 (name serde_json)
 (depends
  ocaml
  (ppx_inline_test
   (>= "v0.16.0"))
  (qcheck :with-test)
  (rio
   (>= "0.0.8"))
  (serde
   (= :version))
  (serde_derive
   (and
    :with-test
    (= :version)))
  (spices :with-test)
  (yojson
   (>= "2.1.0"))
  dune))

(package
 (name blog)
 (allow_empty)
 (depends ocaml dune melange reason-react))

(package
 (name drive)
 (depends
  ocaml
  dune
  core
  fmt
  ;; mlx
  mlx
  ocamlmerlin-mlx
  ;; html
  html_of_jsx
  ;; EIO
  eio
  eio_main
  cohttp-eio
  httpun
  httpun-eio
  piaf
  ;; Dev Tools?...
  ocaml-index
  ;; Picos? Not sure if we'll use this...
  ; picos
  ; picos_mux
  ; picos_std
  ;;
  saturn))

;; vite-plugin-ocaml

(package
 (name vite-plugin-ocaml)
 (allow_empty)
 (depends ocaml dune melange s_tier))

;; dbcaml

(package
 (name DBCaml)
 (synopsis "Database toolkit for OCaml")
 (description "Database toolkit for OCaml")
 (depends
  ocaml
  dune
  (alcotest :with-test)
  (riot
   (>= 0.0.9))
  ppx_deriving
  serde
  uri)
 (tags
  (topics "database" "dbcaml")))

(package
 (name DBCamlPostgres)
 (synopsis "Postgres driver for dbcaml")
 (description "Postgres driver for dbcaml")
 (depends
  ocaml
  (alcotest :with-test)
  dune
  DBCaml
  bytestring
  cryptokit
  castore
  serde
  serde_derive
  (riot
   (>= 0.0.9))
  (tls
   (>= 1.0.0))
  uri)
 (tags
  (topics "database" "dbcaml" "postgres")))

(package
 (name DBCamlSqlite)
 (synopsis "Sqlite support for DBCaml")
 (description "Sqlite support for DBCaml")
 (depends
  ocaml
  (alcotest :with-test)
  dune
  DBCaml
  riot
  sqlite3
  serde
  serde_json
  yojson)
 (tags
  (topics "sqlite" "serde" "ocaml")))

(package
 (name dbcaml-examples)
 (allow_empty)
 (depends DBCaml DBCamlPostgres serde riot))

;; vendored pg-query stuff, don't know if we'll keep

(package
 (name PGQuery)
 (depends
  (ocaml
   (>= 4.07))
  (dune
   (>= 2.0))
  cmdliner
  ctypes
  ctypes-foreign
  ppx_deriving
  ocaml-protoc
  (alcotest :with-test)))
