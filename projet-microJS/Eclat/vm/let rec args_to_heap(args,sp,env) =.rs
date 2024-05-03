let rec args_to_heap(args,sp,env) =
    if(args = 0) then 
        sp
    else(
        heap.(env) <- stack.(sp-args);
        args_to_heap(args-1,sp+1,env+1)
    )