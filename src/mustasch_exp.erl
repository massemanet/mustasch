%% -*- mode: erlang; erlang-indent-level: 4 -*-
-module(mustasch_exp).

-export(
   [go/1]).

go(Str) ->
    RE = '^([+-]?)([0-9]+?)(0*)(?:\.([0-9]+?)0*|)[Ee]([+-]?[0-9]+)$',
    case re:run(Str, atom_to_list(RE), [{capture,all_but_first,list}]) of
        {match, [Sign, IntNZ, IntZ, Frac, Ex]} ->
            Exp = int(Ex),
            Int = num(Sign, denull(IntNZ), Exp+length(IntZ)),
            Frc = num(Sign, denull(Frac), Exp-length(Frac)),
            Int+Frc
    end.

num(Sign, Str, E) ->
    case {int(Str), E < 0} of
        {0, _} -> 0;
        {_, true} -> list_to_float(Sign++"0."++zeros(-(E+1))++Str);
        {_, false} -> int(Sign++Str++zeros(E))
    end.

zeros(N) -> lists:duplicate(N, $0).

int(Str) -> list_to_integer(Str).

denull("") -> "0";
denull(Str) -> Str.
