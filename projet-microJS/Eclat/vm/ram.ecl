
(* les tailles des tableaux sont personnalisables *)


let heap = array_create 100 ;;    (* tas *)
let stack = array_create 100 ;;   (* pile *)
let globals = array_create 100 ;; (* variables globales *)
let code = array_create 100 ;;    (* bytecode *)


let push_stack (stack,sp,v) =
    stack.(sp) <- v;
    sp + 1          
;;


let pop_stack (stack,sp) =
    let new_sp = sp - 1 in
    (stack.(new_sp), new_sp)
;;
    