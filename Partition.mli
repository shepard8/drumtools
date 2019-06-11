(* A partition is a list of measures (one per line). Each measure is either a
 * rhythm or a fill, and is described by the rhythm/fill id and the tempo at
 * which it is played. *)
type measure_type = Fill | Rhythm

type measure = {
  measure_type : measure_type;
  id : int;
  tempo : int;
}

type t = measure list

val measure_of_string : string -> measure
val string_of_measure : measure -> string

val of_string : string -> t
val to_string : t -> string

