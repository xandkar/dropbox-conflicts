open Core.Std

type t =
  { path_current  : string
  ; path_original : string
  ; host          : string
  ; date          : Date.t
  ; sequence      : int option
  }

let find ~path:path_current =
  Option.map (Dropbox_conflict_lexer.find ~path:path_current) ~f:(
    fun {Dropbox_conflict_info.path_original; host; date; sequence} ->
      { path_current
      ; path_original
      ; host
      ; date
      ; sequence
      }
  )
