let () =
  let imgpath = Sys.argv.(1) in
  let img = Png.load imgpath [] in
  let (w, h) = Images.size img in
  Printf.printf "%s : %d %d\n%!" imgpath w h
