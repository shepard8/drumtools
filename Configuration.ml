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
    if n < low then acc else aux (n :: acc) (n - 1)
  in aux [] high

let listdiff l1 l2 = (* l1 without the elements of l2 *)
  List.filter (fun e -> not (List.mem e l2)) l1

let genericChangeRange absmin absmax configlist changetype low high =
  let range = genRange absmin absmax low high in
  match changetype with
  | Set -> range @ listdiff configlist range (* to avoid duplicates *)
  | Reset -> listdiff configlist range
  | Toggle -> listdiff range configlist @ listdiff configlist range

let addRangesFromString absmin absmax configlist s =
  let l = String.split_on_char ',' s in
  List.fold_left (fun configlist part ->
    let subparts = String.split_on_char '-' part in
    match List.length subparts with
    | 1 ->
        let v = int_of_string (String.trim (List.hd subparts)) in
        genericChangeRange absmin absmax configlist Set v v
    | 2 -> 
        let low = int_of_string (String.trim (List.hd subparts)) in
        let high = int_of_string (String.trim (List.hd (List.tl subparts))) in
        genericChangeRange absmin absmax configlist Set low high
    | _ ->
        Printf.printf "Wrong range : %s\n%!" part;
        configlist
  ) configlist l

let absoluteMinRhythm = 1
let absoluteMaxRhythm = 10 (* TODO retrieve this number from Rhythms directory *)

let rhythmsUpdater = genericChangeRange absoluteMinRhythm absoluteMaxRhythm
let changeRhythmRange config changetype low high =
  { config with rhythms = rhythmsUpdater config.rhythms changetype low high }
let rhythmsAdder = addRangesFromString absoluteMinRhythm absoluteMaxRhythm
let addRhythmsFromString config s =
  { config with rhythms = rhythmsAdder config.rhythms s }

let absoluteMinFill = 1
let absoluteMaxFill = 5 (* TODO retrieve this number from Rhythms directory *)

let fillsUpdater = genericChangeRange absoluteMinFill absoluteMaxFill
let changeFillRange config changetype low high =
  { config with fills = fillsUpdater config.fills changetype low high }
let fillsAdder = addRangesFromString absoluteMinRhythm absoluteMaxRhythm
let addFillsFromString config s =
  { config with fills = fillsAdder config.fills s }

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

let emptyConfig = {
  rhythms = [];
  fills = [];
  bpm = (absoluteMinBpm, absoluteMaxBpm);
  repeats = (absoluteMinRepeats, absoluteMaxRepeats);
  fillsamount = (absoluteMinFills, absoluteMaxFills);
  measures = absoluteMinMeasures;
}

(* Export/Import to/from string *)
let fromString lines =
  let relevantLines = List.filter (fun l -> l <> "" && l.[0] <> '#') lines in
  List.fold_left (fun config line ->
    let parts = String.split_on_char '=' line in
    if (List.length parts = 2) then begin
      let v = String.trim (List.hd (List.tl parts)) in
      ignore v;
      match String.trim (List.hd parts) with
      | "rhythms" -> addRhythmsFromString config v
      | "fills" -> addFillsFromString config v
      | "minbpm" -> setMinBpm config (int_of_string v)
      | "maxbpm" -> setMaxBpm config (int_of_string v)
      | "minrepeats" -> setMinRepeats config (int_of_string v)
      | "maxrepeats" -> setMaxRepeats config (int_of_string v)
      | "minfills" -> setMinFillsAmount config (int_of_string v)
      | "maxfills" -> setMaxFillsAmount config (int_of_string v)
      | "measures" -> setMeasures config (int_of_string v)
      | _ -> Printf.printf "Wrong config line : %s\n%!" line; config
    end
    else begin
      Printf.printf "Ignored config line : %s\n%!" line;
      config
    end
  ) emptyConfig relevantLines

let rec listToSequences start cur = function
  | [] -> ((start, cur) :: [])
  | h :: t when h = cur + 1 -> listToSequences start h t
  | h :: t -> (start, cur) :: listToSequences h h t

let listToString = function
  | [] -> ""
  | h :: t ->
      let seqs = listToSequences h h t in
      let strings = List.map (fun (a, b) -> Printf.sprintf "%d-%d" a b) seqs in
      String.concat "," strings

let toString config =
  Printf.sprintf {config|rhythms=%s
fills=%s
minbpm=%d
maxbpm=%d
minrepeats=%d
maxrepeats=%d
minfills=%d
maxfills=%d
measures=%d|config}
    (listToString config.rhythms)
    (listToString config.fills)
    (fst config.bpm)
    (snd config.bpm)
    (fst config.repeats)
    (snd config.repeats)
    (fst config.fillsamount)
    (snd config.fillsamount)
    config.measures

