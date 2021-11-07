% mustasch lexer grammar.

Definitions.

SIGN = ([\-|\+]?)
INT = ({SIGN}(([1-9][0-9]*)|0))
FLOAT = ({INT}\.[0-9]+)
EXP = (({INT}|{FLOAT})[Ee]{INT})

Rules.

% whitespace, skipped
[\000-\s]+ :
  skip_token.

% as themselves
\{\{|\|\||\||\(|\)|\$|#|\.|,|:|=|\{|\} :
  {token, {list_to_atom(TokenChars), TokenLine}}.

% end token
\}\} :
  {end_token, {list_to_atom(TokenChars), TokenLine}}.

% numbers
{INT} :
  {token, {int, TokenLine, list_to_integer(TokenChars)}}.  

{FLOAT} :
  {token, {float, TokenLine, list_to_float(TokenChars)}}.

{EXP} :
  {token, mk_int_or_float(TokenLine, TokenChars)}.

%% strings are represented as lists in the token. there are 5 kinds;
%% binary-quoted, double-quoted, single-quoted, format-quoted, unquoted.

% binary string
<<"([^"]|\\")*">> :
  {token, {bq, TokenLine, trim(TokenChars)}}.

% double-quoted string
"([^"]|\\")*" :
  {token, {dq, TokenLine, trim(TokenChars)}}.

% single-quoted string
'([^']|\\')*' :
  {token, {sq, TokenLine, trim(TokenChars)}}.

% format string
(~[a-zA-Z]+(\.[0-9]+(\.[0-9])?)?)+ :
  {token, {fq, TokenLine, TokenChars}}.

% unquoted string, basically an atom()
[a-z][a-zA-Z0-9_]* :
  {token, {uq, TokenLine, TokenChars}}.

% variable
[A-Z][a-zA-Z0-9_]* :
  {token, {var, TokenLine, TokenChars}}.

Erlang code.

% trim quotes
-define(TRIM(X), fun(Z) -> X++T = lists:reverse(Z), lists:reverse(T) end).
trim(Chars) ->
    case Chars of
        "<<\""++S -> (?TRIM(">>\""))(S);
        "\""++S   -> (?TRIM("\""))(S);
        "'"++S    -> (?TRIM("'"))(S);
        _         -> Chars
    end.

% handle expoments, like "10e-1"
mk_int_or_float(L, T) ->
    case mustach_exp:go(T) of
        I when is_integer(I) -> {int, L, I};
        F when is_float(F) -> {float, L, F}
    end.
