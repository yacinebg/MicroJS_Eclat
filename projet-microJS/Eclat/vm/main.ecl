
let load_bytecode0() =
  code.(0) <- I_PUSH (Int 42);
  code.(1) <- I_POP () ;;  
  (* devrait afficher 42 *)


let load_bytecode1() =
  code.(0) <- I_PUSH (Int 42);
  code.(1) <- I_PUSH (Int 1);
  code.(2) <- I_PUSH (Prim (P_ADD()));
  code.(3) <- I_CALL(2);
  code.(4) <- I_POP () ;;
  (* devrait afficher 43 *)


let load_bytecode2() =
  code.(0) <- I_PUSH (Int 42);
  code.(1) <- I_PUSH (Int 1);
  code.(2) <- I_PUSH (Prim (P_ADD()));
  code.(3) <- I_CALL(2);
  code.(4) <- I_PUSH (Int 5);
  code.(5) <- I_PUSH (Prim (P_ADD()));
  code.(6) <- I_CALL(2);
  code.(7) <- I_POP () ;;
  (* devrait afficher 48 *)


let load_bytecode3() =
  code.(0) <- I_GALLOC ();      (* N := 10 *)
  code.(1) <- I_PUSH (Int 10);   
  code.(2) <- I_GSTORE(0);

  code.(3) <- I_GALLOC ();      (* ACC := 0 *)
  code.(4) <- I_PUSH (Int 0);   
  code.(5) <- I_GSTORE(1);

  (* "debut boucle:" *)
  code.(6) <- I_GFETCH(0);      (* ACC := ACC + N *)
  code.(7) <- I_GFETCH(1); 
  code.(8) <- I_PUSH(Prim (P_ADD()));
  code.(9) <- I_CALL(2);
  code.(10) <- I_GSTORE(1);

  code.(11) <- I_GFETCH(0);     (* goto "fin boucle:" si (N == 0) *)
  code.(12) <- I_PUSH (Int 0);
  code.(13) <- I_PUSH (Prim (P_EQ()));
  code.(14) <- I_CALL(2);
  code.(15) <- I_JTRUE 22;

  code.(16) <- I_GFETCH(0);     (* N := N - 1 *)
  code.(17) <- I_PUSH(Int 1);
  code.(18) <- I_PUSH(Prim (P_SUB()));
  code.(19) <- I_CALL(2);
  code.(20) <- I_GSTORE(0);

  code.(21) <- I_JUMP(6);      (* goto "debut boucle:" *)

 (* "fin boucle:" *)
  code.(22) <- I_GFETCH(1);
  code.(23) <- I_POP() ;;
  (* devrait afficher 55 *)

  let load_bytecode4() =
  code.(0) <- I_PUSH (Int 10);
  code.(1) <- I_PUSH (Int 5);
  code.(2) <- I_PUSH (Prim (P_SUB()));
  code.(3) <- I_CALL(2);
  code.(4) <- I_POP ();;
  (* devrait afficher 5 *)

  let load_bytecode5() =
  code.(0) <- I_PUSH (Int 2);
  code.(1) <- I_PUSH (Int 3);
  code.(2) <- I_PUSH (Prim (P_POW()));
  code.(3) <- I_CALL(2);
  code.(4) <- I_POP ();;
  (* devrait afficher 8 *)

  let load_bytecode6() =
  code.(0) <- I_PUSH (Int 20);
  code.(1) <- I_PUSH (Int 2);
  code.(2) <- I_PUSH (Int 2);
  code.(3) <- I_PUSH (Prim (P_DIV()));
  code.(4) <- I_CALL(3);
  code.(5) <- I_POP ();;
  (* devrait afficher 5 *)

  let load_bytecode7() =
  code.(0) <- I_GALLOC (); 
  code.(1) <- I_GALLOC ();
  code.(2) <- I_PUSH (Int 42);
  code.(3) <- I_GSTORE(0);
  code.(4) <- I_PUSH (Int 100);
  code.(5) <- I_GSTORE(1); 
  code.(6) <- I_GFETCH(1);
  code.(7) <- I_POP ();;
 (* devrait afficher 100 *)

  let load_bytecode_jump() =
  code.(0) <- I_PUSH (Int 10); 
  code.(1) <- I_JUMP (5); 
  code.(2) <- I_PUSH (Int 20);
  code.(3) <- I_PUSH (Int 20);
  code.(4) <- I_PUSH (Int 20);
  code.(5) <- I_POP ();
  code.(6) <- I_POP ();;
 (* devrait afficher 10 *)

  let load_bytecode_jtrue() =
  code.(0) <- I_PUSH (Bool true); 
  code.(1) <- I_JTRUE (4);     
  code.(2) <- I_PUSH (Int 20);   
  code.(3) <- I_POP ();        
  code.(4) <- I_PUSH (Int 30);   
  code.(5) <- I_POP ();;
(* devrait afficher 30 *)

let load_bytecode_id () =
  code.(0) <- I_JUMP 5;
  code.(1) <- I_FETCH 0;
  code.(2) <- I_RETURN();
  code.(3) <- I_PUSH (Nil());
  code.(4) <- I_RETURN();
  code.(5) <- I_PUSH_FUN (1);
  code.(6) <- I_JUMP 9;
  code.(7) <- I_PUSH (Nil());
  code.(8) <- I_RETURN();
  code.(9) <- I_PUSH_FUN (7);
  code.(10) <- I_CALL (1);
  code.(11) <- I_POP();
  () ;;

          
let load_bytecode_inc () =
  code.(0) <- I_GALLOC();
  code.(1) <- I_JUMP 9;
  code.(2) <- I_FETCH 1;
  code.(3) <- I_FETCH 0;
  code.(4) <- I_PUSH (Prim (P_ADD()));
  code.(5) <- I_CALL (2);
  code.(6) <- I_RETURN();
  code.(7) <- I_PUSH (Nil());
  code.(8) <- I_RETURN();
  code.(9) <- I_PUSH_FUN (2);
  code.(10) <- I_GSTORE 0;
  code.(11) <- I_PUSH (Int 2);
  code.(12) <- I_PUSH (Int 1);
  code.(13) <- I_GFETCH 0;
  code.(14) <- I_CALL (2);
  code.(15) <- I_POP();
  () ;;

  let load_bytecode_fact () =
    code.(0) <- I_GALLOC();
    code.(1) <- I_JUMP 22;
    code.(2) <- I_PUSH (Int 2);
    code.(3) <- I_FETCH 0;
    code.(4) <- I_PUSH (Prim (P_LT()));
    code.(5) <- I_CALL (2);
    code.(6) <- I_JFALSE 10;
    code.(7) <- I_PUSH (Int 1);
    code.(8) <- I_RETURN();
    code.(9) <- I_JUMP 20;
    code.(10) <- I_PUSH (Int 1);
    code.(11) <- I_FETCH 0;
    code.(12) <- I_PUSH (Prim (P_SUB()));
    code.(13) <- I_CALL (2);
    code.(14) <- I_GFETCH 0;
    code.(15) <- I_CALL (1);
    code.(16) <- I_FETCH 0;
    code.(17) <- I_PUSH (Prim (P_MUL()));
    code.(18) <- I_CALL (2);
    code.(19) <- I_RETURN();
    code.(20) <- I_PUSH (Nil());
    code.(21) <- I_RETURN();
    code.(22) <- I_PUSH_FUN (2);
    code.(23) <- I_GSTORE 0;
    code.(24) <- I_PUSH (Int 4);
    code.(25) <- I_GFETCH 0;
    code.(26) <- I_CALL (1);
    code.(27) <- I_POP();
    () ;;

  let load_bytecode_while () =
    code.(0) <- I_GALLOC();
    code.(1) <- I_PUSH (Int 0);
    code.(2) <- I_GSTORE 0;
    code.(3) <- I_GALLOC();
    code.(4) <- I_PUSH (Int 0);
    code.(5) <- I_GSTORE 1;
    code.(6) <- I_JUMP 17;
    code.(7) <- I_PUSH (Int 1);
    code.(8) <- I_GFETCH 1;
    code.(9) <- I_PUSH (Prim (P_ADD()));
    code.(10) <- I_CALL (2);
    code.(11) <- I_GSTORE 1;
    code.(12) <- I_GFETCH 0;
    code.(13) <- I_GFETCH 1;
    code.(14) <- I_PUSH (Prim (P_ADD()));
    code.(15) <- I_CALL (2);
    code.(16) <- I_GSTORE 0;
    code.(17) <- I_PUSH (Int 10);
    code.(18) <- I_GFETCH 1;
    code.(19) <- I_PUSH (Prim (P_LT()));
    code.(20) <- I_CALL (2);
    code.(21) <- I_JTRUE 7;
    () ;; 

  let load_bytecode_delta () =
    code.(0) <- I_GALLOC();
    code.(1) <- I_JUMP 18;
    code.(2) <- I_FETCH 2;
    code.(3) <- I_FETCH 0;
    code.(4) <- I_PUSH (Int 4);
    code.(5) <- I_PUSH (Prim (P_MUL()));
    code.(6) <- I_CALL (2);
    code.(7) <- I_PUSH (Prim (P_MUL()));
    code.(8) <- I_CALL (2);
    code.(9) <- I_FETCH 1;
    code.(10) <- I_FETCH 1;
    code.(11) <- I_PUSH (Prim (P_MUL()));
    code.(12) <- I_CALL (2);
    code.(13) <- I_PUSH (Prim (P_SUB()));
    code.(14) <- I_CALL (2);
    code.(15) <- I_RETURN();
    code.(16) <- I_PUSH (Nil());
    code.(17) <- I_RETURN();
    code.(18) <- I_PUSH_FUN (2);
    code.(19) <- I_GSTORE 0;
    code.(20) <- I_PUSH (Int 3);
    code.(21) <- I_PUSH (Int 2);
    code.(22) <- I_PUSH (Int 1);
    code.(23) <- I_GFETCH 0;
    code.(24) <- I_CALL (3);
    code.(25) <- I_POP();
    code.(26) <- I_PUSH (Int 3);
    code.(27) <- I_PUSH (Int 2);
    code.(28) <- I_PUSH (Int 1);
    code.(29) <- I_GFETCH 0;
    code.(30) <- I_CALL (3);
    code.(31) <- I_POP();
    () ;;

  let load_bytecode_ha () =
    code.(0) <- I_GALLOC();
    code.(1) <- I_PUSH (Int 9);
    code.(2) <- I_GSTORE 0;
    code.(3) <- I_GALLOC();
    code.(4) <- I_JUMP 15;
    code.(5) <- I_GALLOC();
    code.(6) <- I_PUSH (Int 2);
    code.(7) <- I_GFETCH 0;
    code.(8) <- I_PUSH (Prim (P_ADD()));
    code.(9) <- I_CALL (2);
    code.(10) <- I_GSTORE 2;
    code.(11) <- I_GFETCH 2;
    code.(12) <- I_RETURN();
    code.(13) <- I_PUSH (Nil());
    code.(14) <- I_RETURN();
    code.(15) <- I_PUSH_FUN (5);
    code.(16) <- I_GSTORE 1;
    code.(17) <- I_GFETCH 1;
    code.(18) <- I_CALL (0);
    code.(19) <- I_POP();
    () ;;
let init_state = ((0,0,0,0),0,0,(false,(0,Nil())),false) ;;

let run_vm (debug:bool) =
  (* array_init (ram,Nil()); *)
  vm_run_code (init_state,debug);;


let counter (b:bool) =
  reg (fun c -> if b then c + 1 else c) last 0 ;;

let load load_bytecode =
  reg (fun is_loaded -> 
      if is_loaded then true else
      let ((),rdy) = exec
                       load_bytecode()
                     default ()
      in rdy)
  last false ;;

let display_start cy =
   print_string "START (cy="; print_int cy; print_string ")"; print_newline () ;;

let display_end cy =
  print_string "END (cy="; print_int cy; print_string ")"; print_newline (); print_newline () ;;



let main debug =
  (** chargement du programme *)
  let is_loaded = load load_bytecode_inc in

  let cy = counter (is_loaded) in

  let ((),rdy) = exec 
                    display_start cy; run_vm debug
                 default ()
  in
  if rdy then display_end cy else () ;;



(**

$ make
$ make simul NS=15000

START (cy=0)
DISPLAY> 55 
END (cy=1012) 

 *)