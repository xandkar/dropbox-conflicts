open Core.Std

type t =
  { path_current  : string
  ; path_original : string
  ; host          : string
  ; date          : Date.t
  ; sequence      : int option
  }

val find : path:string -> t list
