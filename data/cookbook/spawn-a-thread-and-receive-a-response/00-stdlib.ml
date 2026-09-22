---
packages: []
discussion: |
  `Thread` is part of the OCaml compiler distribution, not a separate opam
  package. To use it, add `threads.posix` to the `libraries` stanza of your
  dune file, e.g. `(libraries threads.posix)`.

  A single OCaml runtime lock still serializes the execution of OCaml code
  across `Thread`s, so this does not give CPU-bound code a speedup - the
  benefit is that a thread can release the lock while blocked on I/O or on
  `Thread.delay`, letting other threads make progress in the meantime. For
  true parallel execution of OCaml code on multiple cores, use the `Domain`
  module instead.
---

(*
  A worker thread cannot return a value directly: `Thread.create` only
  returns a `Thread.t` handle, and `Thread.join` waits for the thread to
  finish but returns `unit`. To receive a response, have the thread write
  its result into a `ref` that the main thread reads after joining. Because
  `Thread.join` only returns once the thread is done, the write is
  guaranteed to have happened before the read.
*)
let square_slowly n =
  Thread.delay 0.5;
  n * n

(* We spawn the worker, do something else while it runs, then join it and
   read the response back out of the ref. *)
let () =
  let response = ref 0 in
  let worker = Thread.create (fun () -> response := square_slowly 6) () in
  print_endline "Main thread carries on while the worker computes...";
  Thread.join worker;
  Printf.printf "Result received from the thread: %d\n" !response
