open Printf
let file = "input7.txt"

let read_lines name : string list =
  let ic = open_in name in
  let try_read () =
    try Some (input_line ic) with End_of_file -> None in
  let rec loop acc = match try_read () with
    | Some s -> loop (s :: acc)
    | None -> close_in ic; List.rev acc in
  loop []

let is_number s = match int_of_string_opt s with
  | Some _ ->  true
  | None   -> false

let combine a b = int_of_string ((string_of_int a) ^ (string_of_int b))

(* Part 1 *)
let check_if_doable goal numbers  =
  let rec check_if_doable' curr l = 
    match l with
    | [] -> false
    | x :: [] when x = curr -> true
    | x :: [] -> false
    | x :: xs when curr < 0 -> false
    | x :: xs when (curr mod x) = 0 -> (check_if_doable' (curr - x) xs || check_if_doable' (curr / x) xs) 
    | x :: xs ->  check_if_doable' (curr - x) xs in
  check_if_doable' goal (List.rev numbers) 


(* Part 2*)
let check_if_doable2 goal numbers =
  let rec check_if_doable2' curr l =
    let result = check_if_doable curr l in 
    if result then result else
    match l with 
    | x :: y :: [] when (combine y x) = curr -> true
    | x :: _ when curr <= 0 -> result
    | x :: y :: xs when (x mod curr) = 0 -> check_if_doable2' curr ([combine y x] @ xs) || check_if_doable2' (curr - x) ([y] @ xs) || check_if_doable2' (curr / x) ([y] @ xs)
    | x :: y :: xs -> check_if_doable2' curr ([combine y x] @ xs) || check_if_doable2' (curr - x) ([y] @ xs)  
    | _ -> check_if_doable curr l
  in
  check_if_doable2' goal (List.rev numbers)



let () =
  let content = read_lines file in 
  let split  = List.map (String.split_on_char ':') content in
  let result = List.map (fun x-> int_of_string (List.hd x)) split in 
  let operations = List.map (fun x-> List.map int_of_string (List.filter is_number (String.split_on_char ' ' (List.hd (List.rev x))))) split in
  let zipped = List.map2 (fun x y -> [y] @ x) operations result in 
  let res2 = (List.map List.hd (List.filter (fun x -> check_if_doable2 (List.hd x) (List.tl x)) zipped)) in
  let res = (List.map List.hd (List.filter (fun x -> check_if_doable (List.hd x) (List.tl x)) zipped)) in
  (printf "Part 1; %d %d") (List.fold_left (+) 0 res)  (List.fold_left (+) 0 res2)
