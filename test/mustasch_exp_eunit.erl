%% -*- mode: erlang; erlang-indent-level: 4 -*-
-module(mustasch_exp_eunit).

-include_lib("eunit/include/eunit.hrl").


t0_test() ->
    lists:map(
      fun runner/1,
      [{"0E0", 0},
       {"0e-0", 0},
       {"1E0", 1},
       {"1E-1", 0.1},
       {"1E1", 10},
       {"1E+1", 10},
       {"10E+1", 100},
       {"10E-1", 1},
       {"0.0E0", 0},
       {"0.1E0", 0.1},
       {"1.0E0", 1},
       {"0.0E1", 0},
       {"0.1E1", 1},
       {"1.0E1", 10},
       {"0.0E-1", 0},
       {"0.1E-1", 0.01},
       {"1.0E-1", 0.1},
       {"10.0e-1", 1}]).

runner({Str, Num}) ->
    try mustasch_exp:go(Str) of
        N when N =:= Num -> ok;
        N -> #{fail => Str, expected => Num, got => N}
    catch
        C:R:S -> error_info(Str, C, R, S)
    end.

error_info(Str, C, R, S) ->
    [{M, F, A, _}, {MS, FS, AS, PL}|_] = S,
    {C, R, Str, [{M, F, A}, {MS, FS, AS, proplists:get_value(line, PL)}]}.
