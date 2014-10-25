open Core.Std

type t =
  { path_current  : string
  ; path_original : string
  ; host          : string
  ; date          : Date.t
  ; sequence      : int option
  }

let rec find ~path:path_current =
  match Dropbox_conflict_lexer.find ~path:path_current with
  | None -> []
  | Some {Dropbox_conflict_info.path_original; host; date; sequence} ->
      let conflict =
        { path_current
        ; path_original
        ; host
        ; date
        ; sequence
        }
      in
      conflict :: find ~path:path_original
