(*  Only the last occurrence of a conflict marker is parsed on each scan. Which
 *  means that, for single-level conflict, such as the following example paths:
 *
 *    /home/foo/Dropbox/bar (nano's conflicted copy 2012-01-02 (1))
 *    /home/foo/Dropbox/bar (nano's conflicted copy 2012-01-02)
 *    /home/foo/Dropbox/bar (r3-t2's conflicted copy 2011-12-10)
 *    /home/foo/Dropbox/baz (huayra's conflicted copy 2014-10-22).sqlite
 *
 *  you'll have all the conflict data after a single scan, while to parse
 *  N-level conflicts, such as the following:
 *
 *    /home/foo/Dropbox/qux (r3-t2's conflicted copy 2014-07-06) (zonda's conflicted copy 2014-10-16) (huayra's conflicted copy 2014-10-22).txt
 *
 *  you'll need to continuously re-scan the resulting "path_original" from the
 *  previous scan, until no more conflict markers are found.
 *
 *  So far. I could not think of a nicer way to parse these, because the grammar
 *  is context-sensitive.
 *)
{
  let orig_path_left_buf = Buffer.create 80
}

let d = ['0'-'9']
let num = d+

(* TODO: Are we _really_ sure these are all the characters allowed in host and
 * file extension? *)
let host      = ['A'-'Z' 'a'-'z' '0'-'9' '-' '_']+
let extension = ['A'-'Z' 'a'-'z' '0'-'9'        ]+

rule scan = parse
| eof {
  Buffer.clear orig_path_left_buf;
  None
}
| " ("
  (host as host)
  "'s conflicted copy "
  ((d d d d as year) '-' (d d as month) '-' (d d as day))
  ( " (" ( num as sequence) ')')?
  ')'
  (('.' extension) as extension)?
  eof {
  let open Core.Std in

  let orig_path_left  = Buffer.contents orig_path_left_buf in
  let orig_path_right = Option.value extension ~default:"" in
  let sequence        = Option.map   sequence  ~f:Int.of_string in
  let y = Int.of_string year in
  let m = Month.of_int_exn (Int.of_string month) in
  let d = Int.of_string day in
  (* What if this fails? Do we really care, at parsing time, if Dropbox wrote
   * invalid dates? Maybe we should just keep the integers without converting
   * to Date.t? *)
  let date = Date.create_exn ~y ~m ~d in
  let conflict_info =
    let open Dropbox_conflict_info in
    { path_original = orig_path_left ^ orig_path_right
    ; host
    ; date
    ; sequence
    }
  in
  Buffer.clear orig_path_left_buf;
  Some conflict_info

}
| (_ as c) {
  Buffer.add_char orig_path_left_buf c;
  scan lexbuf
}

{
  let find ~path =
    scan (Lexing.from_string path)
}
