open Core.Std
open Async.Std

let main ~dir =
  let finder = Async_find.create dir in
  print_endline "digraph G {";
  Async_find.iter finder ~f:(fun (path, _stats) ->
    List.iter (Dropbox_conflict.find ~path) ~f:(fun conflict ->
      let {Dropbox_conflict.path_current; path_original; _} = conflict in
      printf "%S -> %S;\n" path_original path_current
    );
    return ()
  ) >>= fun () ->
  print_endline "}";
  Async_find.close finder

let () =
  let open Command.Spec in
  let (+) = (+>) in
  Command.run (Command.async_basic
    ~summary:"USAGE EXAMPLE: ./dropbox_conflicts.native -dir `pwd`/Dropbox \
              | neato -T png > conflicts.png && open conflicts.png"
    ( empty
    + flag "-dir" (required string) ~doc:" Directory to search for conflicts"
    )
    (fun dir () -> main ~dir)
  )
