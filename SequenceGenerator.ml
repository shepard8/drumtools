let () =
  let configFile = Sys.argv.(1) in
  let config = Configuration.fromString configFile in
  print_endline (Configuration.toString config)
