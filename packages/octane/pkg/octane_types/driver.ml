module type DATABASE = sig
  val name : string
  val create_table : name:string -> columns:string -> string
  val drop_table : name:string -> string
  val coretype_to_sql : string -> string option

  (* TODO: Need to add primary key generation in the drivers here but I don't care right now. 2025/01/28 *)
end
