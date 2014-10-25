open Core.Std
open Async.Std

let main ~dir =
  let conflicts = String.Table.create () in
  let finder = Async_find.create dir in
  Async_find.iter finder ~f:(fun (path, _stats) ->
    ( match Dropbox_conflict.find ~path with
    | None ->
        ()
    | Some conflict ->
        let
          { Dropbox_conflict.
            path_current
          ; path_original
          ; host          = _
          ; date          = _
          ; sequence      = _
          } = conflict
        in
        assert (path_current = path);
        Hashtbl.change
          conflicts
          path_original
          ( function
          | None           -> Some [conflict]
          | Some conflicts -> Some (conflict :: conflicts)
          )
    );
    return ()
  ) >>= fun () ->
  Hashtbl.iter conflicts ~f:(fun ~key:path_original ~data:conflicts ->
    print_endline path_original;
    List.iter conflicts ~f:(fun {Dropbox_conflict.path_current; _} ->
      printf "\t%s\n" path_current
    );
    print_newline ()
  );
  Async_find.close finder

let () =
  let open Command.Spec in
  let (+) = (+>) in
  Command.run (Command.async_basic
    ~summary:""
    ( empty
    + flag "-dir" (required string) ~doc:" Directory to search for conflicts"
    )
    (fun dir () -> main ~dir)
  )
