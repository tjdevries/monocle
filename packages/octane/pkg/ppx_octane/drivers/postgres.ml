module T : OctaneTypes.Driver.DATABASE = struct
  let name = "postgres"
  let create_table ~name ~columns = [%string "CREATE TABLE %{name} (%{columns})"]
  let drop_table ~name = [%string "DROP TABLE IF EXISTS %{name} CASCADE"]

  let coretype_to_sql = function
    | "int" -> Some "INTEGER"
    | "string" -> Some "TEXT"
    | _ -> None
  ;;
end

include T
