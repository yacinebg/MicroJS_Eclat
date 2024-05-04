(* le type des instructions de la VM *)
type instr = I_GALLOC of unit 
           | I_GSTORE of ptr
           | I_GFETCH of ptr
           | I_STORE of ptr
           | I_FETCH of ptr
           | I_PUSH of value
           | I_PUSH_FUN of ptr
           | I_POP of unit
           | I_CALL of long (* arity *)
           | I_RETURN of unit
           | I_JUMP of ptr
           | I_JTRUE of ptr
           | I_JFALSE of ptr

(* l'état de la VM comprend (dans l'ordre) :
   - un bloc d'activation
   - un pointeur [gp] sur la prochaine variable globale à allouer
   - un pointeur [hp] sur la prochaine adresse libre dans le tas
   - un buffer d'écriture postée [write_buf],comportement un booléen 
        (qui indique quand une écriture doit avoir lieu), 
        une adresse à écrire et la nouvelle valeur.
   - un booléen [finished] qui passe à vrai à la fin de l'exécution,
     en particulier lors de l'exécution d'une instruction POP
     sur une pile de 1 élément. *)

type vm_state = (frame * ptr * ptr * (bool * (ptr * value)) * bool);; 


let equal ((value1, value2) : value * value): bool =
  match value1 with
  | Int(a) -> match value2 with 
      Int(b) -> a = b 
      | _ -> print_string "types incompatibles\n" ; exit () 
    end
  | Bool(a1) -> match value2 with 
      Bool(b2) -> if a1 then (if b2 then true else false) else (if b2 then false else true) 
      | _ -> print_string "types incompatibles\n" ; exit () 
    end
  | Nil () -> match value2 with 
      Nil () -> true 
      | _ -> print_string "types incompatibles\n" ; exit () 
    end
  | _ ->  print_string "il n'y a pas d'égalité possible \n" ; exit () 
end
   ;;

let rec copy_args_to_heap(args, sp, env) =
  if args = 0 then
    sp
  else
    (
      heap.(env) <- stack.(sp - args - 1);
      print_string "copy heap["; print_int(env); print_string"] <-"; print_value(stack.(sp - args - 1)); print_newline();
      copy_args_to_heap(args - 1, sp, env +1)
    )
;;


  

let print_vm_state ((frame,gp,hp,_,_):vm_state) : unit =
  print_frame frame;
  print_string "|gp:"; print_int gp;
  print_string "|hp:"; print_int gp;
  print_newline();;
  
(* exécution d'une instruction du programme, le [pc] 
   courrant est dans l'état de la VM (state) *)
let vm_run_instr (state : vm_state) : vm_state =
  let (frame,gp,hp,wg,finished) = state in
  let (sp,env,pc,fp) = frame in
  let instr = code.(pc) in
  match instr with
  | I_PUSH (v) ->
      stack.(sp) <- v;
      ((sp+1, env, pc, fp), gp, hp, wg, finished)
  | I_POP () ->        
    if(sp - 1 = 0) then
      (print_value(stack.(sp-1)); 
      ((sp-1, env, pc, fp), gp, hp, wg, true))
    else
    ((sp-1, env, pc, fp), gp, hp, wg, finished)
  
  | I_GALLOC ()->((sp, env, pc, fp), gp+1, hp, wg, finished)

  | I_GSTORE (i) -> globals.(i) <- stack.(sp-1);
                    let new_sp = sp - 1 in
                    ((new_sp, env, pc,fp),gp,hp,wg,finished)
  | I_GFETCH (i) -> stack.(sp) <- globals.(i);
          ((sp+1, env, pc, fp), gp, hp, wg, finished)
  
  | I_FETCH (i) -> 
    (* print_string "env "; print_int(env); print_newline();
    print_string "Fetch["; print_int(env+i); print_string"] <-"; print_value(heap.(env+i)); print_newline(); *)

    let local_value = heap.(env+i) in 
    stack.(sp) <- local_value; 
    ((sp + 1, env, pc, fp), gp, hp, wg, finished)         

  | I_JUMP (l) -> ((sp, env, l - 1, fp), gp, hp, wg, finished)

  | I_STORE (i) -> let var = stack.(sp-1) in
                  heap.(env+i) <- var;
                  ((sp-1, env, pc, fp), gp, hp, wg, finished)
                  
  | I_JTRUE (l) ->let v = stack.(sp-1) in
      let cond = match v with
                      | Bool(x)  -> x
                      | _ -> false
                      end
      in
      let new_pc = if cond then l - 1 else pc in
      ((sp-1, env, new_pc, fp), gp, hp, wg, finished)

  | I_JFALSE (l) ->  let v = stack.(sp-1) in
      let condition = match v with
                      | Bool (x) -> x
                      | _ -> false
                      end
      in
      let new_pc = if condition then pc else l - 1 in
      ((sp-1, env, new_pc, fp), gp, hp, wg, finished)
  | I_RETURN () ->
    let v = stack.(sp - 1) in
    let (new_sp, new_env, new_pc, new_fp) = frames.(fp-1) in
    stack.(new_sp) <- v;
    ((new_sp + 1, new_env, new_pc, new_fp), gp, hp, wg, finished)
      
  
  | I_PUSH_FUN (l) ->
    stack.(sp) <- Close (l,env); 
    ((sp + 1, env, pc, fp), gp, hp, wg, finished)
  
  | I_CALL (n) -> let value = stack.(sp - 1) in
      match value with
      | Prim (p) -> match p with 
        | P_ADD () -> let rec add(arg,acc) = (if (arg = 0) then (acc) 
                                              else (let v = stack.(sp - 1 - arg) in 
                                              let int_value = match v with 
                                                  | Int a -> a 
                                                  | _ -> fatal_error "erreur dans ADD, c'est pas un entier "
                                                  end 
                                                in 
                                                add(arg-1,acc + int_value) ))
                                              in 
            (* print_string "stack["; print_int(sp-n-1); print_string"] <-"; print_value(stack.(sp-n-1)); print_newline();
            print_string "stack["; print_int(sp-n); print_string"] <-"; print_value(stack.(sp-n)); print_newline();
            print_string "stack["; print_int(sp-n+1); print_string"] <-"; print_value(stack.(sp-n+1)); print_newline(); *)

            let resultat = add(n,0) in
            stack.(sp - n -1) <- Int resultat;
            print_int(resultat); print_newline();

            ((sp - n, env, pc, fp), gp, hp, wg, finished)
        
        | P_SUB () -> if n < 2 then fatal_error "il faut 2 arguments pour la soustraction" else (
          let rec sub(arg,acc) = (if (arg = 0) then (acc) 
          else (let v = stack.(sp - 1 - arg) in 
          let int_value = match v with 
              | Int a -> a 
              | _ -> fatal_error "erreur"
              end 
            in 
            sub(arg-1,acc - int_value) ))
          in 
          let debut = match (stack.(sp - n - 1)) with Int a -> a | _ -> fatal_error "erreur" end in
          print_string "stack["; print_int(sp-n-1); print_string"] <-"; print_value(stack.(sp-n-1)); print_newline();
          print_string "stack["; print_int(sp-n); print_string"] <-"; print_value(stack.(sp-n)); print_newline();
          print_string "stack["; print_int(sp-n+1); print_string"] <-"; print_value(stack.(sp-n+1)); print_newline();
          let resultat = sub (n - 1, debut) in
          let absolute_res = if(resultat < 0 )then resultat*(-1) else resultat in
          stack.(sp - n - 1) <- Int absolute_res;
          print_string "le resultat :stack["; print_int(sp - n - 1); print_string"] <-"; print_value(stack.(sp - n - 1)); print_newline();
          print_int(absolute_res); print_newline();
          ((sp - n, env, pc, fp), gp, hp, wg, finished))


        | P_MUL () -> let rec mul(arg,acc) = (if (arg = 0) then (acc) 
                                              else (let v = stack.(sp - 1 - arg) in 
                                              let int_value = match v with 
                                                  | Int a -> a 
                                                  | _ -> fatal_error "erreur"
                                                  end 
                                                in 
                                                mul(arg-1,acc * int_value) ))
                                              in 
              let resultat = mul(n,1) in
              print_string "stack["; print_int(sp-n-1); print_string"] <-"; print_value(stack.(sp-n-1)); print_newline();
              print_string "stack["; print_int(sp-n); print_string"] <-"; print_value(stack.(sp-n)); print_newline();
              print_string "stack["; print_int(sp-n+1); print_string"] <-"; print_value(stack.(sp-n+1)); print_newline();
              stack.(sp - n -1) <- Int resultat;
              print_int(resultat); print_newline();
            ((sp - n, env, pc, fp), gp, hp, wg, finished)


        | P_DIV () -> 
          if n < 1 then fatal_error "pas assez d'arguments"
          else
              let rec div (args, acc) = 
                  if args = 0 then acc 
                  else 
                      let divisor = match stack.(sp - 1 - args) with Int a -> a | _ -> fatal_error "erreur" end in
                      if divisor = 0 then fatal_error "Division par zero"
                      else div (args - 1, acc / divisor)
              in
              let debut = match (stack.(sp - n - 1)) with Int a -> a | _ -> fatal_error "erreur" end in
              let resultat = div (n - 1, debut) in
              stack.(sp - n - 1) <- Int resultat; 
              ((sp - n, env, pc, fp), gp, hp, wg, finished)

        | P_POW () -> 
          if n != 2 then fatal_error "il faut exactement 2 arguments"
          else
              let base = match stack.(sp - 3) with Int a -> a | _ -> fatal_error "erreur" end in
              let exponent = match stack.(sp -2 ) with Int a -> a | _ -> fatal_error "erreur" end in
              let rec pow (b, e, acc) =
                  if e = 0 then acc
                  else pow (b, e - 1, acc * b)
              in
              let resultat = pow (base, exponent, 1) in
              stack.(sp - n - 1) <- Int resultat;
              ((sp - n, env, pc, fp), gp, hp, wg, finished)
        
        | P_LT () -> 
          if n != 2 then fatal_error "il faut exactement 2 arguments"
          else
              let fst_operand = match stack.(sp - 3) with Int a -> a | _ -> fatal_error "erreur" end in
              let scd_operand = match stack.(sp - 2) with Int a -> a | _ -> fatal_error "erreur" end in
              let resultat = fst_operand > scd_operand in
              print_string "stack["; print_int(sp - 3); print_string"] <-"; print_value(stack.(sp - 3)); print_newline();
              print_string "stack["; print_int(sp - 2); print_string"] <-"; print_value(stack.(sp - 2)); print_newline();
              print_string "stack["; print_int(sp - 1); print_string"] <-"; print_value(stack.(sp - 1)); print_newline();
              stack.(sp - n - 1) <- Bool resultat; 

              print_string"ICIIIIIIIII" ;print_value(Bool (resultat)); print_newline();
              ((sp - n, env, pc, fp), gp, hp, wg, finished)

        | P_EQ () -> 
          if n != 2 then fatal_error "il faut exactement 2 arguments"
          else
            let first_value = stack.(sp-2) in 
            let second_value = stack.(sp-3) in 
            let res = equal (first_value, second_value)
            in stack.(sp-1-n ) <- Bool res;
            ((sp-n, env, pc, fp),gp ,hp,wg,finished)
        
          | _ -> state
        end
        | Close (l,env_sp) -> 
          let new_env  = hp in
          let new_hp = hp + n + 1 in 
          heap.(new_hp-1) <- Int env;
          let new_sp = copy_args_to_heap (n, sp, new_env) in
          frames.(fp) <- (sp-n-1, env, pc, fp);
          let new_fp = fp + 1 in
          frames.(new_fp)<-(sp-n-1 , env_sp , pc, fp);
          ((sp-n-1 , new_env , l - 1, new_fp), gp, new_hp , wg, finished)
      | _ -> state 
    end
          (*    
  | I_PUSH_FUN 
  *)
  | _ -> exit ()
  end;;

(* exécution d'un programme (stocké dans le tableau global [bytecode] *)
let rec vm_run_code ((state,debug) : vm_state * bool) : unit =
  
  (if debug then print_vm_state state else ()); (* affichage de l'état de la VM *)
  
  let (frame,gp,hp,write_buf,finished) = vm_run_instr(state) in
  
  if finished then () else 
  let (sp,env,pc,fp) = frame in
  let next_pc = pc+1 in
  (* fait [pc+1] après chaque instruction exécutée : 
     en cas de changement de pc par l'instruction d'avant (branchements, etc.), 
     il faudra vers [nouveau_pc-1]) *)
  vm_run_code(((sp,env,next_pc,fp),gp,hp,write_buf,finished),debug) ;; 