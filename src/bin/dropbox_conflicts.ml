open Core.Std
open Async.Std

let main ~dir =
  let paths_r     , paths_w     = Pipe.create () in
  let conflicts_r , conflicts_w = Pipe.create () in
  let worker_finder () =
    let finder = Async_find.create dir in
    Async_find.iter finder ~f:(fun (path, _stats) ->
      Pipe.write_without_pushback paths_w path;
      return ()
    ) >>= fun () ->
    Pipe.close paths_w;
    Async_find.close finder
  in
  let worker_parser () =
    Pipe.iter paths_r ~f:(fun path ->
      let conflicts = Dropbox_conflict.find ~path in
      List.iter conflicts ~f:(fun conflict ->
        Pipe.write_without_pushback conflicts_w conflict
      );
      return ()
    ) >>| fun () ->
    Pipe.close conflicts_w
  in
  let worker_printer () =
    print_endline "digraph G {";
    Pipe.iter conflicts_r ~f:(
      fun {Dropbox_conflict.path_current; path_original; _} ->
        printf "%S -> %S;\n" path_original path_current;
        return ()
    ) >>| fun () ->
    print_endline "}"
  in
  Deferred.List.iter
    ~how:`Parallel
    ~f:(fun w -> w ())
    [ worker_finder
    ; worker_parser
    ; worker_printer
    ]

let () =
  let open Command.Spec in
  let (+) = (+>) in
  Command.run (Command.async_basic
    ~summary:"USAGE EXAMPLE: ./dropbox_conflicts.native -dir $HOME/Dropbox \
              | neato -T png > conflicts.png && open conflicts.png"
    ( empty
    + flag "-dir" (required string) ~doc:" Directory to search for conflicts"
    )
    (fun dir () -> main ~dir)
  )
