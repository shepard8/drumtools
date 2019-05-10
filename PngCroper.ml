(* module I = Genimage.Make(Rgb24)(Png) *)

let detect_staff_top img =
  let rec aux h =
    let pixel = Rgb24.get img 0 h in
    if pixel.Color.r = 255 && pixel.Color.g = 255 && pixel.Color.b = 255
    then aux (h + 1)
    else h
  in
  try
    aux 0
  with _ -> -1

let cut img topcut heightcut =
  Rgb24.sub img 0 topcut img.Rgb24.width heightcut

let croppedimgpath imgpath =
  let open Filename in
  concat (dirname imgpath) ("cropped." ^ basename imgpath)

let () =
  let imgpath = Sys.argv.(1) in
  let img = match Png.load_as_rgb24 imgpath [] with
  | Rgb24 t -> t
  | _ -> assert false
  in
  let w = img.Rgb24.width in
  let h = img.Rgb24.height in
  let stafftop = detect_staff_top img in
  Printf.printf "%s : %d %d, staff top at %d\n%!" imgpath w h stafftop;
  let topcut = stafftop - 42 in (* We leave 42 pixels above the staff *)
  let heightcut = 42 + 29 + 42 in (* And 42 pixels below, staff's height is 29px. *)
  let img' = Images.Rgb24 (cut img topcut heightcut) in
  Png.save (croppedimgpath imgpath) [] img'
