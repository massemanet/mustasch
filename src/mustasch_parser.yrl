Terminals '{{' '}}' '||' '|' '(' ')' '$' ',' ':' 'int' 'float' 'uq' 'dq' 'sq' 'bq' 'fq' 'var'.

% unused (for records) Terminals '#' '.' '{' '}'.
% unused (for bind) Terminals '='.

Nonterminals pattern pipeline element0 element1s element1 function0 literal env function1 arg0s arg0 arg1s arg1 format atom string.

Rootsymbol pattern.

pattern -> '{{' format '||' pipeline '}}' : {pattern, '$2', '$4'}.
pattern -> '{{' pipeline '}}'             : {pattern, '', '$2'}.

pipeline -> element0 '|' element1s : {pipeline, ['$1'|'$3']}.
pipeline -> element0               : {pipeline, ['$1']}.

element0 -> function0 : '$1'.
element0 -> literal   : '$1'.
element0 -> env       : '$1'.

element1s -> element1s '|' element1 : '$1'++['$3'].
element1s -> element1               : ['$1'].

element1 -> function1 : '$1'.
element1 -> literal   : '$1'.

function0 -> atom ':' atom '(' arg0s ')' : {call, '$1', '$3', '$5'}.
function0 -> atom ':' atom '(' ')'       : {call, '$1', '$3', []}. 
function0 -> atom ':' atom               : {call, '$1', '$3', []}. 

arg0s -> arg0s ',' arg0 : '$1'++['$3'].
arg0s -> arg0           : ['$1'].

arg0 -> literal : '$1'.

function1 -> atom ':' atom '(' arg1s ')' : {call, '$1', '$3', '$5'}.
function1 -> atom ':' atom               : {call, '$1', '$3', ['$']}.
function1 -> '$'                         : {call, '', 'dollar', ['$']}.

arg1s -> arg1s ',' arg1 : '$1'++['$3'].
arg1s -> arg1           : ['$1'].

arg1 -> '$'     : '$'.
arg1 -> literal : '$1'.

literal -> int    : '$1'.
literal -> float  : '$1'.
literal -> string : '$1'.
literal -> atom   : '$1'.

env -> '$' string : {call, '', 'env', ['$2']}.
env -> '$' var :    {call, '', 'env', ['$2']}.

format -> fq : '$1'.
format -> dq : '$1'.

atom -> sq: '$1'.
atom -> uq: '$1'.

string -> dq: '$1'.
string -> bq: '$1'.
