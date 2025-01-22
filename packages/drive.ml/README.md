
- But I don't want exactly Dream, it has some stuff I didn't like (custom way to generate HTML, etc)

Ideal OCaml SaaS Framework:
- HTTP Server + Routing (NO FILE BASED ROUTING THATS LAME)
    - Routing:
        - Typesafe routes
        - Named parameters
        - Custom types
        - Validation

    - Query Params (and validation)

```ocaml
(* let user%route = / user / (module UserID) *)
let user%route = "/user/user_id:UserID/:string"

module UserRoute = struct

end

(* let user%route = "/user/:int/:string" -> fun a b *)
(* let user%route = "/user/:int?" *)
```

- Easy Melange Integration
    - First: Easy React Pages
        - Use VITE?!?!
- Database shenanigans
    - `@@ Dream.sql_pool "sqlite3:db.sqlite"`
- Forms
    - multipart forms
- Session
- Cookies
- Websockets
- Melange integration
- Backend workers (queues)
- mlx working
    - SSR
    - Client side
- Logging
- Middleware
- JSON
- Assets / Bundling
- Live reload

Nice To Have:
- Admin panel

Lower Priority / Later:
- Auth
- Graphql

How do people normally make website have react?

Option 1:
- You just write some HTML
- You have script tags
- You have js bundle
- load js bundle, put into html, zoom zoom

OCaml module:
- compile it to JS (melange) -> bundle with vite -> some asset.js
- compile it to something that the server knows about?
    - for now, could hardcode a path for this...

Can we make it really easy to do:
- ocaml native server backend, uses multi-core, much fast, such wow
- melange frontend
- melange native app via rn??




## FRONTEND STUFF

- we can do server-side rendering easy peasy
    - just return a string OMEGALUL
    - we already have templating for this, easy peasy
    - Can use html_of_jsx to do this easily.
        - Future problem: Would be cool if we could write ocaml in the onclick stuff...
    - ... but we don't have compile to JS working with this idea.

- we can do client-side rendering easy peasy
    - ... but it's a bit harder to serve random pages ...
    - OK, i have Dashboard.mlx and Users.mlx. How do I route to them?

## Total Stack

- Backend
    - Write our own server thing
- Frontend
    - SSR
    - CSR
    - Bundle these with vite
        - Custom Vite Plugin
