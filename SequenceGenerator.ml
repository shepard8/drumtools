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
  print_endline (Configuration.toString config)
