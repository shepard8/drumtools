open Printf

let preamble = {pre|
\version "2.18.2"

#(define drumtoolsdrums '(
  (bassdrum default #f -3)
  (lowfloortom default #f -1)
  (snare default #f 1)
  (lowtom default #f 2)
  (hightom default #f 3)
  (hihat cross #f 4)
  (crashcymbal cross #f 6)
))

\paper {
  paper-width = 10\cm
  paper-height = 4\cm
  left-margin = 0
  top-margin = 1\cm
  right-margin = 0
  bottom-margin = 0
}

\header {
  tagline = ##f
}

\layout {
  indent = 0
  \context {
    \DrumStaff
    \remove "Time_signature_engraver"
    \remove "Clef_engraver"
  }
  \context {
    \Score
    proportionalNotationDuration = #(ly:make-moment 1/24)
  }
}

\new DrumStaff <<
  \set DrumStaff.drumStyleTable = #(alist->hash-table drumtoolsdrums)
|pre}

let postamble = {post|
>>
|post}

let print_scoreline oc scoreline =
  fprintf oc "  \\drummode {\n";
  fprintf oc "    %s\n" scoreline;
  fprintf oc "  }\n"

let print_scorelines oc = function
  | [] -> ()
  | line :: [] ->
      print_scoreline oc line
  | line :: lines ->
      print_scoreline oc line;
      fprintf oc "  \\\\\n";
      List.iter (print_scoreline oc) lines

let print_all oc scorelines =
  fprintf oc "%s" preamble;
  print_scorelines oc scorelines;
  fprintf oc "%s" postamble

let gendb dbname dirname =
  let ic = open_in dbname in
  let rec rl directory n =
    let line = input_line ic in
    if String.length line <> 0
    then begin
      let scorelines = String.split_on_char '/' line in
      let oc = open_out (directory ^ Filename.dir_sep ^ string_of_int n ^ ".ly") in
      print_all oc scorelines;
      close_out oc
    end;
    rl directory (n + 1)
  in
  try rl dirname 1
  with End_of_file -> ()

let () =
  let dbname = Sys.argv.(1) in
  let dirname = Sys.argv.(2) in
  gendb dbname dirname

