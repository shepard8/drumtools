type measure_type = Fill | Rhythm

type measure = {
  measure_type : measure_type;
  id : int;
  tempo : int;
}

type t = measure list

exception Parse_error of string

let measure_type_of_string = function
  | "R" -> Rhythm
  | "F" -> Fill
  | _ -> raise (Parse_error "R or F expected.")

let string_of_measure_type = function
  | Rhythm -> "R"
  | Fill -> "F"

let measure_of_string s =
  let parts = String.split_on_char ' ' s in
  match parts with
  | measure_type :: id :: tempo :: [] ->
      let measure_type = measure_type_of_string measure_type in
      let id = int_of_string id in
      let tempo = int_of_string tempo in
      { measure_type; id; tempo }
  | _ -> raise (Parse_error s)

let string_of_measure { measure_type; id; tempo } =
  Printf.sprintf "%s %d %d" (string_of_measure_type measure_type) id tempo

val read : string -> t
val write : t -> string -> unit

