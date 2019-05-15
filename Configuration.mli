type config = {
  rhythms : int list;
  fills : int list;
  bpm : int * int;
  repeats : int * int;
  fillsamount : int * int;
  measures : int;
}

type changetype = Set | Reset | Toggle

val absoluteMinRhythm : int
val absoluteMaxRhythm : int
val changeRhythmRange : config -> changetype -> int -> int -> config

val absoluteMinFill : int
val absoluteMaxFill : int
val changeFillRange : config -> changetype -> int -> int -> config

val absoluteMinBpm : int
val absoluteMaxBpm : int
val setMinBpm : config -> int -> config
val setMaxBpm : config -> int -> config

val absoluteMinRepeats : int
val absoluteMaxRepeats : int
val setMinRepeats : config -> int -> config
val setMaxRepeats : config -> int -> config

val absoluteMinFills : int
val absoluteMaxFills : int
val setMinFillsAmount : config -> int -> config
val setMaxFillsAmount : config -> int -> config

val absoluteMinMeasures : int
val absoluteMaxMeasures : int
val setMeasures : config -> int -> config

val defaultConfig : config

val readConf : string -> config

