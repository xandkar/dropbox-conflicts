open Core.Std

type t =
  { path_original : string
  ; host          : string
  ; date          : Date.t
  ; sequence      : int option
  }
