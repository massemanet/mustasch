% mustasch lexer grammar.
% tokens are;
% '}}': end token
% '{{', '.', ':': as themselves
% int: an integer
% sq: single quoted string
% dq: double quoted string
% bq: binary quoted string
% uq: unquoted text

Definitions.

WS = [\000-\s]
REGULAR = [^'"{}:0-9<\.\000-\s]

Rules.

{WS}+ :
  skip_token.

[0-9]+ :
  {token,{int,TokenLine,TokenChars}}.

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

{{ :
  {token,{'{{',TokenLine}}.

}} :
  {end_token,{'}}',TokenLine}}.

({REGULAR}|<[^<]|<<[^"]|}[^}]|\\{|\\})+ :
  {token,{uq,TokenLine,TokenChars}}.

Erlang code.

btrim(N,S) -> lists:reverse(lists:nthtail(N,lists:reverse(lists:nthtail(N,S)))).
