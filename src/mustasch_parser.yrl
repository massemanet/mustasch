Nonterminals doc string nugget subnugget atom.
Terminals 'uq' 'dq' 'bq' 'sq' 'int' '.' ':' '{{' '}}'.
Rootsymbol doc.

doc -> string                      : ['$1'].
doc -> doc '{{' nugget '}}' string : '$1' ++ [{'$3'}] ++ ['$5'].

string -> '$empty'                 : [].
string -> 'uq'                     : val('$1').

nugget -> '$empty'                 : [{}].
nugget -> subnugget                : ['$1'].
nugget -> nugget '.' subnugget     : '$1' ++ ['$3'].

subnugget -> atom ':' atom         : {'$1','$3'}.
subnugget -> atom                  : '$1'.
subnugget -> 'dq'                  : val('$1').
subnugget -> 'int'                 : list_to_integer(val('$1')).
subnugget -> 'bq'                  : list_to_binary(val('$1')).

atom -> 'uq'                       : list_to_atom(val('$1')).
atom -> 'sq'                       : list_to_atom(val('$1')).

Erlang code.

val({_,_,V}) -> V.
