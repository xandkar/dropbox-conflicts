open Core.Std
open Async.Std

module DiGraph : sig
  type node_id = string

  type t

  val create : unit -> t

  val add_link : t -> src:node_id -> dst:node_id -> unit

  val print_dot : t -> unit
end = struct
  type node_id = string

  type links =
    { incoming : node_id Hash_set.t
    ; outgoing : node_id Hash_set.t
    }

  type t =
    (node_id, links) Hashtbl.t

  let create () =
    String.Table.create ()

  let add_link t ~src ~dst =
    let get_links node_id =
      Hashtbl.find_or_add t node_id ~default:(fun () ->
        { incoming = String.Hash_set.create ()
        ; outgoing = String.Hash_set.create ()
        }
      )
    in
    Hash_set.add (get_links src).outgoing dst;
    Hash_set.add (get_links dst).incoming src

  let print_dot t =
    print_endline "digraph G {";
    Hashtbl.iter t ~f:(fun ~key:src ~data:{outgoing=dsts; _} ->
      Hash_set.iter dsts ~f:(fun dst -> printf "%S -> %S;\n" src dst)
    );
    print_endline "}"
end

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
    let graph = DiGraph.create () in
    Pipe.iter conflicts_r ~f:(
      fun {Dropbox_conflict.path_current=dst; path_original=src; _} ->
        DiGraph.add_link graph ~src ~dst;
        return ()
    ) >>| fun () ->
    DiGraph.print_dot graph
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
