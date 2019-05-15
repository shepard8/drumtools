let () =
  let configFile = Sys.argv.(1) in
  let config = Configuration.readConf configFile in
  ignore config
