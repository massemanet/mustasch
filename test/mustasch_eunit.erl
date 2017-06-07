%% -*- mode: erlang; erlang-indent-level: 2 -*-

-module('mustasch_eunit').
-author('mats cronqvist').

-include_lib("eunit/include/eunit.hrl").

t0_test() ->
  ?assertEqual("abc "++atom_to_list(node())++" def",
               mustasch:run(<<"abc {{ .erlang:node }} def">>)).

t1_test() ->
  ?assertEqual("abc sirap def",
               mustasch:run(<<"abc {{ \"paris\".lists:reverse }} def">>)).
t2_test() ->
  ?assertEqual("A",
               mustasch:run(<<"{{ a }}">>, [{a, "A"}])).

t3_test() ->
  ?assertEqual("abc A def",
               mustasch:run(<<"abc {{ a }} def">>, [{a, "A"}])).

t4_test() ->
  ?assertEqual("a",
               mustasch:run(<<"{{ a.string:to_lower }}">>, [{a, "A"}])).
