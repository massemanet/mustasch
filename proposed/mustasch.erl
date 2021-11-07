 R = fun(E) -> case is_list(E) andalso lists:all(fun(C) -> is_integer(C) andalso $ =< C end, E) of true -> unicode:characters_to_binary(E); false -> E end end.

H = fun(B,{A,C}) -> case is_list(A) of true -> case erlang:fun_info(B,arity)of{arity,1}->{[R(B(X))||X<-A],C}; {arity,2}->{[R(B(X,C))||X<-A],C} end; false -> case erlang:fun_info(B,arity)of{arity,1}->{R(B(A)),C};{arity,3}->{A,B(A,C,C)}end end end.

element(1,lists:foldl(H, {R((fun()->os:getenv("HOME")end)()),#{}}, [fun(V,C,_)->C#{'K'=>V}end,fun(D)->file:list_dir(D)end,fun({ok,V})->V end,fun(F,#{'K':=V})->filename:join(V,F)end,fun(F)->file:read_file_info(F) end, fun({ok,V}) -> V end, fun(T) -> element(4,T) end])).

keywords: bind, match, with, select, make
{{ os:getenv("HOME") | bind Dir=$ | file:list_dir | match {ok,$} | with Dir filename:join(Dir,$) | file:read_file_info | match {ok,$} | make {select 4, select file#file_info.mtime }}

