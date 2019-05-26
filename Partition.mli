type measure_type = Fill | Rhythm

type measure = {
  measure_type : measure_type;
  tempo : int;
  id : int;
}

type t = measure list

val measure_of_string : string -> measure
val string_of_measure : measure -> string

val read : string -> t
val write : t -> string -> unit

