let () = Random.self_init ()

let randomInRange (rmin, rmax) =
  if rmin = rmax then rmin
  else rmin + Random.int (rmax - rmin)

type measure_type = Rhythm | Fill

let stringOfMeasureType = function
  | Rhythm -> "RHYTHM"
  | Fill -> "FILL"

type measure = {
  measureType : measure_type;
  file : int;
  repeats : int;
  tempo : int;
}

let stringOfMeasure { measureType; file; repeats; tempo } =
  Printf.sprintf "%s %d : %d repeats at %d bpm"
    (stringOfMeasureType measureType) file repeats tempo

type partition = measure list

let rec genRhythms config prevTempo measuresNeeded =
  if measuresNeeded <= 0 then []
  else
    let rhythms = Array.of_list config.Configuration.rhythms in
    let repeats = randomInRange config.Configuration.repeats in
    let rhythm = rhythms.(Random.int (Array.length rhythms)) in
    let measure = {
      measureType = Rhythm;
      file = rhythm;
      repeats = repeats;
      tempo = prevTempo;
    } in
    measure :: genFills config prevTempo (measuresNeeded - repeats)
    
and genFills config prevTempo measuresNeeded =
  if measuresNeeded <= 0 then []
  else
    let fills = Array.of_list config.Configuration.fills in
    let repeats = randomInRange config.Configuration.fillsamount in
    if repeats = 0
    then genRhythms config prevTempo measuresNeeded
    else begin
      let fill = fills.(Random.int (Array.length fills)) in
      let measure = {
        measureType = Fill;
        file = fill;
        repeats = repeats;
        tempo = prevTempo;
      } in
      measure :: genRhythms config prevTempo (measuresNeeded - repeats)
    end

let () =
  let configFile = Sys.argv.(1) in
  let configChannel = open_in configFile in
  let rec aux acc =
    try
      aux (input_line configChannel :: acc)
    with End_of_file -> List.rev acc
  in
  let configLines = aux [] in
  let config = Configuration.fromString configLines in
  let tempo = randomInRange config.Configuration.bpm in
  let l = genRhythms config tempo config.Configuration.measures in
  List.iter (fun m -> print_endline (stringOfMeasure m)) l
