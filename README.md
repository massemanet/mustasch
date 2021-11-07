# mustasch

Template substitution.

Replace `{{` `MP` `}}` with the result of evaluating `MP`, a Mustasch
Pattern.

An `MP` looks like;

```
Format || Pipeline
```

where `Format` is a format string as used by `io:format/2`, and
`Pipeline` looks like;

```
A [ | B ]...
```

As a shorthand, `"~s" || Generator` can be written as `Generator`.

A `Pipeline` is a sequence of pipeline elements (`PE`) separated by a
pipe `|`.

The first `PE` in a pipleine must have arity zero (`PE/0`, and the followng
`PE` must have arity one (`PE/1`).

A `PE/0` can be;
  * a literal (a string, an atom, or a number)
  * a function expression with no free parameters (`ets:all`, `ets:first(foo)`)

A `PE/1` is a function expression with one free parameter, denoted by
a `$`. E.g. `ets:first($)` or `lists:nth(2, $)`.

As a shorthand, `m:f($)` can be written as `m:f`.

`$` is a special `PE/1`, equvalent to;

`os:cmd | string:tokens($, "\n") | lists:map(fun string:trim/1, $)`.


Examples;


These are all the same, and will be replaced by the value of `$HOME`.
```
{{ $HOME }}
{{ os:getenv("HOME") }}
{{ "HOME" | os:getenv }}
{{ "HOME" | os:getenv($) }}
```

This will be replaced by the value of `$HOME`, with the last path
element removed.

```
{{ os:getenv("HOME") | filename:dirname }}
{{ os:getenv("HOME") | filename:dirname($) }}
```

This will be replaced by a 2 byte number, read from `dev/urandom` by a
shell, formatted a hex;

```
{{ ~.16B || "od -i -N2 -An  </dev/urandom" | $ | list_to_integer }}
```

This will be replaced by the values of all environment variables in
the shell, each on a separate line, preceded by the string `<li> `.

```
{{ "<li> ~s~n" || $("env") }}
```
