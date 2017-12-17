% mustasch lexer grammar.
% tokens are;
% '}}': end token
% '.', ':': as themselves
% int: an integer
% sq: single quoted string
% dq: double quoted string
% bq: binary quoted string
% uq: unquoted text

Definitions.

WS = ([\000-\s])

Rules.

{WS}*[0-9]+{WS}* :
  {token,{int,TokenLine,list_to_integer(string:strip(TokenChars))}}.

[^'"}:\.]+ :
  {token,{uq,TokenLine,TokenChars}}.

<<"([^"]|\\")*">> :
  {token,{bq,TokenLine,btrim(3,TokenChars)}}.

"([^"]|\\")*" :
  {token,{dq,TokenLine,btrim(1,TokenChars)}}.

'([^']|\\')*' :
  {token,{sq,TokenLine,btrim(1,TokenChars)}}.

\. :
  {token,{'.',TokenLine}}.

: :
  {token,{':',TokenLine}}.

{WS}*}} :
  {end_token,{'}}',TokenLine}}.

Erlang code.

btrim(N,S) -> lists:reverse(lists:nthtail(N,lists:reverse(lists:nthtail(N,S)))).
