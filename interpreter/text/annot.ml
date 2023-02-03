open Source

type annot = annot' Source.phrase
and annot' = {name : Ast.name; items : item list}

and item = item' Source.phrase
and item' =
  | Atom of string
  | Var of string
  | String of string
  | Nat of string
  | Int of string
  | Float of string
  | Parens of item list
  | Annot of annot


(* Stateful recorder for annotations *)
(* I wish this could be encapsulated in the parser somehow *)

module NameMap = Map.Make(struct type t = Ast.name let compare = compare end)
type map = annot list NameMap.t

let current : map ref = ref NameMap.empty
let cur_buf: Lexing.lexbuf ref = ref (Lexing.from_string "")

let clear () = current := NameMap.empty; cur_buf := Lexing.from_string ""

let record annot =
  let old = Lib.Option.get (NameMap.find_opt annot.it.name !current) [] in
  current := NameMap.add annot.it.name (annot::old) !current

let is_contained r1 r2 = r1.left >= r2.left && r1.right <= r2.right

let get_all () =
  let all = !current in
  current := NameMap.empty;
  all

let filter f map =
  NameMap.filter (fun _ annots -> annots <> [])
    (NameMap.map (List.filter f) map)

let get r =
  let sub = filter (fun annot -> is_contained annot.at r) !current in
  let map' = filter (fun annot -> not (is_contained annot.at r)) !current in
  current := map';
  sub
