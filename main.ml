
open Printf
open Lexing

let finally handler f x =
  let r = try f x with e -> handler (); raise e in 
  handler (); r

let open_in_do ?path f =
  match path with 
  | None -> f stdin
  | Some file -> 
      let in_channel = open_in file in
      finally (fun () -> close_in in_channel) f in_channel


let syntax_error p =
  eprintf "File %S at line %d, character %d:@.Syntax error.@." 
    p.pos_fname p.pos_lnum (p.pos_cnum - p.pos_bol)

let read_file filename =
  let f ch = 
    let lexbuf = from_channel ch in
    let lex_curr_p = 
      { lexbuf.lex_curr_p with pos_fname = filename } in
    try
      Trs_parse.rules Trs_lex.lex { lexbuf with lex_curr_p = lex_curr_p }
    with Parsing.Parse_error -> 
      (syntax_error lexbuf.lex_curr_p; exit 1)
  in
  try
    open_in_do ~path:filename f
  with Sys_error s -> 
    (eprintf "Error:@.%s@." s; exit 1)

let () =
  let trs = read_file Sys.argv.(1) in
	let deg = Homcomp.degree trs in
  if deg = 0  then
		let module M = Matrix.Make(Q) in
    let signt = Homcomp.signt_from_trs trs in
		let m2 = Array.map (Array.map Q.of_int) @@ Homcomp.del2til trs in
		let ri2 = M.rank (Array.length m2) (Array.length m2.(0)) m2 in
		let rk2 = Array.length m2.(0) - ri2 in
		let m1 = Array.map (Array.map Q.of_int) @@ Homcomp.del1til trs signt in
		let ri1 = M.rank (Array.length m1) (Array.length m1.(0)) m1 in
		let rk1 = Array.length m1.(0) - ri1 in
		let m0 = Array.map (Array.map Q.of_int) @@ Homcomp.del0til trs signt in
		let ri0 = M.rank (Array.length m0) (Array.length m0.(0)) m0 in
		let rk0 = Array.length m0.(0) - ri0 in
    printf "degree = %d\n#symbol = %d, #rule = %d, #cp = %d\nrank(ker2) = %d, rank(im2) = %d, rank(ker1) = %d, rank(im1) = %d, rank(ker0) = %d, rank(im0) = %d, b2 = %d, b1 = %d\n"
            deg (List.length signt) (List.length trs) (List.length (Homcomp.crit_pairs trs)) rk2 ri2 rk1 ri1 rk0 ri0 (rk1 - ri2) (rk0 - ri1)
  else if Homcomp.is_small_prime deg then
		let module F =
			struct
				type t = Farith.t
				let add = Farith.add deg
				let sub = Farith.sub deg
				let neg = Farith.neg deg
				let mul = Farith.mul deg
				let inv = Farith.inv deg
				let div = Farith.div deg
				let of_int = Farith.of_int deg
			end
	  in
		let module M = Matrix.Make(F) in
    let signt = Homcomp.signt_from_trs trs in
		let m2 = Array.map (Array.map F.of_int) @@ Homcomp.del2til trs in
		let ri2 = M.rank (Array.length m2) (Array.length m2.(0)) m2 in
		let rk2 = Array.length m2.(0) - ri2 in
		let m1 = Array.map (Array.map F.of_int) @@ Homcomp.del1til trs signt in
		let ri1 = M.rank (Array.length m1) (Array.length m1.(0)) m1 in
		let rk1 = Array.length m1.(0) - ri1 in
		let m0 = Array.map (Array.map F.of_int) @@ Homcomp.del0til trs signt in
		let ri0 = M.rank (Array.length m0) (Array.length m0.(0)) m0 in
		let rk0 = Array.length m0.(0) - ri0 in
    printf "degree = %d\n#symbol = %d, #rule = %d, #cp = %d\nrank(ker2) = %d, rank(im2) = %d, rank(ker1) = %d, rank(im1) = %d, rank(ker0) = %d, rank(im0) = %d, b2 = %d, b1 = %d\n"
            deg (List.length signt) (List.length trs) (List.length (Homcomp.crit_pairs trs)) rk2 ri2 rk1 ri1 rk0 ri0 (rk1 - ri2) (rk0 - ri1)
  else
    printf "non applicable\n"
