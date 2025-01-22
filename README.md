# Monocle

Mono repo for ocaml -> monocle

# Usage

I don't care if you use it or not. Please don't actually.

# TODO:

- Add octane support for caqti (because i'm switching to EIO - caqti-eio exists)
    - effects i/o (so ocaml 5 multicore, very cool effects, no monads needed)
    - a.k.a. async without async await
- Wrote part of a server thing with eio + piaf or something
    - (drive.ml), which is like dream but going faster (someday)
- Simple server side rendering situation
- Melange hydration situation
    - Talk to DAVE!!! about react server components in melange in ocaml

# What do we need?

## Phase 1

- Server with routing
    - Static files
    - Server side rendering
    - Client side rendering
    - (optional) Websockets
- Database (typesafe)
- Everything is serde

## Phase 1.5

- Forms

## Phase  2

- Authentication/Users
  - (this is where we can get clerk money?)
- Live reload
- Middleware
- Deploy with SST (or just ask dax how to do anything to the internet)


# Open Questions

- How to integreate Vite, and possibly vite middleware server?
