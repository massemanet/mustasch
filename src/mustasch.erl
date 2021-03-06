%% -*- mode: erlang; erlang-indent-level: 2 -*-

-module('mustasch').
-author('mats cronqvist').
-export([run/1, run/2]).

%%-----------------------------------------------------------------------------

run(Text) ->
  run(Text, []).

run(Text, Ctxt) ->
  exec(generator(Text), Ctxt).

%%-----------------------------------------------------------------------------

exec([],_) -> "";
exec([F|R],Ctxt0) -> F(Ctxt0)++exec(R,Ctxt0).

generator(Bin) ->
  assert_ets(),
  Hash = erlang:md5(Bin),
  case lookup_ets(Hash) of
    [{Hash,Gen}] ->
      Gen;
    _ ->
      Gen = compile(Bin),
      insert_ets({Hash,Gen}),
      Gen
  end.

%% compile the mustasch file to internal form; a list of fun/1
compile(Bin) ->
  Str = binary_to_list(Bin),
  try gen(parse(lex(Str)))
  catch throw:R -> error_logger:error_report(R),[Str]
  end.

%% lexer
lex(Str) ->
  case split_at_mustasch(Str) of
    {S,""} ->
      [{uq,99,S}];
    {S,M} ->
      {done,{ok,Toks,_},C} = mustasch_lexer:tokens([],M),
      [{uq,0,S}|Toks]++lex(C)
  end.

split_at_mustasch(Str) ->
  {S,M} = split_at_mustasch(Str,[]),
  {lists:reverse(S), M}.

split_at_mustasch(Str,B) ->
  case Str of
    "\\{"++T-> split_at_mustasch(T,[${|B]);
    "\\}"++T-> split_at_mustasch(T,[$}|B]);
    "{{"++_ -> {B,Str};
    []      -> {B,""};
    [H|T]   -> split_at_mustasch(T,[H|B])
  end.

%% parser
parse(Toks) ->
  {ok,P} = mustasch_parser:parse(Toks),
  P.

%% generate mustasch code (a list of fun/1)
gen(Nuggs) ->
  [mk_fun(N) || N <- Nuggs].

mk_fun(N) when is_list(N) ->
  fun(_) -> N end;
mk_fun({[{},{M,F}|N]}) ->
  Fs = [wrap(SN) || SN <- N],
  fun(_) -> thread(M:F(),Fs) end;
mk_fun({N}) ->
  [F0|Fs] = [wrap(SN) || SN <- N],
  fun(Ctxt) -> thread(F0(Ctxt),Fs) end.

thread(Ctxt,[])     ->
  assert_string(Ctxt);
thread(Ctxt,[F|Fs]) ->
  try thread(F(Ctxt),Fs)
  catch _:X -> error_logger:error_report(X),""
  end.

assert_string(X) ->
  case is_string(X) of
    true -> X;
    false-> lists:flatten(io_lib:fwrite("~p",[X]))
  end.

-define(is_c(X),9=:=X orelse 10=:=X orelse 13=:=X orelse (31<X andalso X<256)).
is_string([])                  -> true;
is_string([C|R]) when ?is_c(C) -> is_string(R);
is_string(_)                   -> false.

wrap(X) when is_integer(X) ->
  fun(Ctxt) ->
      case Ctxt of
        [{_,_}|_]             -> proplists:get_value(X,Ctxt);
        [_|_]                 -> lists:nth(X,Ctxt);
        _ when is_tuple(Ctxt) -> element(X,Ctxt);
        _                     -> throw([{field,X},{ctxt,Ctxt}])
      end
  end;
wrap({ets,T}) ->
  fun(Ctxt)->
      try element(2,hd(ets:lookup(T,Ctxt)))
      catch _:_ -> throw([{table,T},{ctxt,Ctxt}])
      end
  end;
wrap({}) ->
  fun(_) ->
      ""
  end;
wrap({M,F}) ->
  fun(Ctxt) ->
      try M:F(Ctxt)
      catch _:R -> throw([{mf,{M,F}},{ctxt,Ctxt},{reason,R}]),""
      end
  end;
wrap(A) ->
  fun(Ctxt) ->
      case Ctxt of
        #{}       -> maps:get(A, Ctxt);
        [{_,_}|_] -> proplists:get_value(A,Ctxt);
        _         -> A
      end
  end.

%% ets helpers
assert_ets() ->
  case ets:info(mustasch,size) of
    undefined -> ets:new(mustasch,[public,named_table,ordered_set]);
    _ -> ok
  end.

lookup_ets(K) ->
  ets:lookup(mustasch,K).

insert_ets(T) ->
  ets:insert(mustasch,T).
