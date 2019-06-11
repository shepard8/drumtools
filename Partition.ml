open Base

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
  let parts = String.split_on_chars s ~on:[' '; '\t'] in
  let parts = List.filter parts ~f:String.is_empty in
  match parts with
  | measure_type :: id :: tempo :: [] ->
      let measure_type = measure_type_of_string measure_type in
      let id = Int.of_string id in
      let tempo = Int.of_string tempo in
      { measure_type; id; tempo }
  | _ -> raise (Parse_error s)

let string_of_measure { measure_type; id; tempo } =
  Printf.sprintf "%s %d %d" (string_of_measure_type measure_type) id tempo

let of_string s =
  let lines = String.split_lines s in
  List.map lines ~f:measure_of_string

let to_string l =
  let sep = "\n" in
  let f = string_of_measure in
  let measures = List.map l ~f in
  String.concat ~sep measures
  

