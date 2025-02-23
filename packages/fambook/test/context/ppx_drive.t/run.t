  $ echo "hi"
  hi

  $ pp_drive_context ./lib/simple_module.ml | ocamlformat --impl -
  module User = struct
    type t = [ `user of string ] [@@deriving context]
  
    include struct
      let _ = fun (_ : t) -> ()
      let t value = (`user value : t)
      let _ = t
  
      let get (l : [> t ] list) =
        (match List.find_map (function `user s -> Some s | _ -> None) l with
         | Some s -> s
         | None -> failwith "impossible: by construction"
          : string)
  
      let _ = get
    end [@@ocaml.doc "@inline"] [@@merlin.hide]
  end
  
  module Log = struct
    type t = [ `log of string -> unit ] [@@deriving context]
  
    include struct
      let _ = fun (_ : t) -> ()
      let t value = (`log value : t)
      let _ = t
  
      let get (l : [> t ] list) =
        (match List.find_map (function `log s -> Some s | _ -> None) l with
         | Some s -> s
         | None -> failwith "impossible: by construction"
          : string -> unit)
  
      let _ = get
    end [@@ocaml.doc "@inline"] [@@merlin.hide]
  end
  
  let ctx = [ User.t "teej_dv" ]
  let user = User.get ctx
