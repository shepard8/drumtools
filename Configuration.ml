type config = {
  rhythms : int list;
  fills : int list;
  bpm : int * int;
  repeats : int * int;
  fillsamount : int * int;
  measures : int;
}

(* Rhythms and fills update *)

type changetype = Set | Reset | Toggle

let genRange absmin absmax low high =
  let low = max low absmin in
  let high = min high absmax in
  let rec aux acc n =
    if n > high then acc else aux (n :: acc) (n + 1)
  in aux [] low

let listdiff l1 l2 = (* l1 without the elements of l2 *)
  List.filter (fun e -> not (List.mem e l2)) l1

let genericChangeRange absmin absmax configlist changetype low high =
  let range = genRange absmin absmax low high in
  match changetype with
  | Set -> range @ listdiff configlist range (* to avoid duplicates *)
  | Reset -> listdiff configlist range
  | Toggle -> listdiff range configlist @ listdiff configlist range

let absoluteMinRhythm = 1
let absoluteMaxRhythm = 10 (* TODO retrieve this number from Rhythms directory *)

let rhythmsUpdater = genericChangeRange absoluteMinRhythm absoluteMaxRhythm
let changeRhythmRange config changetype low high =
  { config with rhythms = rhythmsUpdater config.rhythms changetype low high }

let absoluteMinFill = 1
let absoluteMaxFill = 5 (* TODO retrieve this number from Rhythms directory *)

let fillsUpdater = genericChangeRange absoluteMinFill absoluteMaxFill
let changeFillRange config changetype low high =
  { config with fills = fillsUpdater config.fills changetype low high }

(* BPM update *)

let updatemin absmin (_, curmax) newmin =
  (max newmin absmin, max curmax newmin)

let updatemax absmax (curmin, _) newmax =
  (min curmin newmax, min newmax absmax)

let absoluteMinBpm = 40
let absoluteMaxBpm = 360

let setMinBpm config bpm =
  { config with bpm = updatemin absoluteMinBpm config.bpm bpm }

let setMaxBpm config bpm =
  { config with bpm = updatemax absoluteMaxBpm config.bpm bpm }

(* Rhythms sequence lengths update *)

let absoluteMinRepeats = 1
let absoluteMaxRepeats = 100

let setMinRepeats config repeats =
  { config with repeats = updatemin absoluteMinRepeats config.repeats repeats }

let setMaxRepeats config repeats =
  { config with repeats = updatemax absoluteMaxRepeats config.repeats repeats }

(* Fills amount update *)

let absoluteMinFills = 0
let absoluteMaxFills = 100

let setMinFillsAmount config fills =
  { config with fillsamount = updatemin absoluteMinFills config.fillsamount fills }

let setMaxFillsAmount config fills =
  { config with fillsamount = updatemax absoluteMaxFills config.fillsamount fills }

(* Number of measures update *)

let absoluteMinMeasures = 1
let absoluteMaxMeasures = 500

let setMeasures config n =
  let n = min absoluteMaxMeasures (max absoluteMinMeasures n) in
  { config with measures = n }

(* Default configuration, read configuration from file *)

let defaultConfig = {
  rhythms = [ 1; 2; 3; 4; 5; 6; 7; 8; 9; 10 ];
  fills = [ 1; 2; 3; 4; 5 ];
  bpm = (50, 100);
  repeats = (8, 8);
  fillsamount = (1, 1);
  measures = 36;
}

(* TODO *)
let readConf file =
  ignore file;
  defaultConfig

