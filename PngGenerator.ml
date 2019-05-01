open Printf

type c = {
  oc : out_channel;
  prefix : string;
}

let version = "2.18.2"
let instruments = [
  ("bassdrum", "default", -3);
  ("lowfloortom", "default", -1);
  ("snare", "default", 1);
  ("lowtom", "default", 2);
  ("hightom", "default", 3);
  ("hihat", "cross", 4);
  ("crashcymbal", "cross", 6);
]

let print_version c =
  fprintf c.oc "%s\\version \"%s\"\n\n" c.prefix version

let print_instruments c =
  fprintf c.oc "%s#(define drumtoolsdrums '(\n" c.prefix;
  List.iter (fun (instrument, notation, line) ->
    fprintf c.oc "  (%s %s #f %i)\n" instrument notation line
  ) instruments;
  fprintf c.oc "%s))\n\n" c.prefix

let print_drumstaff_context c =
  fprintf c.oc "%s\\context {\n" c.prefix;
  fprintf c.oc "%s  \\DrumStaff\n" c.prefix;
  fprintf c.oc "%s  \\remove \"Time_signature_engraver\"\n" c.prefix;
  fprintf c.oc "%s  \\remove \"Clef_engraver\"\n" c.prefix;
  fprintf c.oc "%s}\n" c.prefix

let print_score_context c =
  fprintf c.oc "%s\\context {\n" c.prefix;
  fprintf c.oc "%s  \\Score\n" c.prefix;
  fprintf c.oc "%s  proportionalNotationDuration = #(ly:make-moment 1/24)\n" c.prefix;
  fprintf c.oc "%s}\n" c.prefix

let print_layout c =
  fprintf c.oc "%s\\layout {\n" c.prefix;
  print_drumstaff_context { oc = c.oc; prefix = c.prefix ^ "  " };
  print_score_context { oc = c.oc; prefix = c.prefix ^ "  " };
  fprintf c.oc "%s}\n" c.prefix

let print_scoreline c scoreline =
  fprintf c.oc "%s\\drummode {\n" c.prefix;
  fprintf c.oc "%s  %s\n" c.prefix scoreline;
  fprintf c.oc "%s}\n" c.prefix

let print_scorelines c = function
  | [] -> ()
  | line :: [] ->
      print_scoreline c line
  | line :: lines ->
      print_scoreline c line;
      fprintf c.oc "%s\\\\\n" c.prefix;
      List.iter (print_scoreline c) lines

let print_score c scorelines =
  fprintf c.oc "%s\\score {\n" c.prefix;
  fprintf c.oc "%s  \\new DrumStaff <<\n" c.prefix;
  fprintf c.oc "%s    \\set DrumStaff.drumStyleTable = #(alist->hash-table drumtoolsdrums)\n" c.prefix;
  print_scorelines { oc = c.oc; prefix = c.prefix ^ "    " } scorelines;
  fprintf c.oc "%s  >>\n" c.prefix;
  print_layout { oc = c.oc; prefix = c.prefix ^ "  " };
  fprintf c.oc "%s}\n\n" c.prefix

let print_all c scorelines =
  print_version c;
  print_instruments c;
  print_score c scorelines

let () =
  let ic = open_in "rhythms.db" in
  let rec rl directory n =
    let line = input_line ic in
    if String.length line <> 0
    then begin
      let scorelines = String.split_on_char '/' line in
      let oc = open_out (directory ^ Filename.dir_sep ^ string_of_int n ^ ".ly") in
      print_all { oc; prefix = "" } scorelines;
      close_out oc
    end;
    rl directory (n + 1)
  in
  try rl "rhythms" 1
  with End_of_file -> ()





