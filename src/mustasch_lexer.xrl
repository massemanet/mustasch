% mustasch lexer grammar.
% tokens are;
% '}}': end token
% '.', ':': as themselves
% int: an integer
% sq: single quoted string
% dq: double quoted string
% uq: unquoted text

Definitions.

WS = ([\000-\s])

Rules.

{WS}*[0-9]+{WS}* :
  {token,{int,TokenLine,list_to_integer(string:strip(TokenChars))}}.

[^'"}:\.]+ :
  {token,{uq,TokenLine,TokenChars}}.

"([^"]|\\")*" :
  {token,{dq,TokenLine,btrim(TokenChars)}}.

'([^']|\\')*' :
  {token,{sq,TokenLine,btrim(TokenChars)}}.

\. :
  {token,{'.',TokenLine}}.

: :
  {token,{':',TokenLine}}.

{WS}*}} :
  {end_token,{'}}',TokenLine}}.

Erlang code.

btrim(S) -> lists:reverse(tl(lists:reverse(tl(S)))).
