# Installation

## With LuaRocks

Clone the repo, then, from this directory :

```sh
luarocks make
```

## Manually

```sh
ln -s ltl.moon SOMEWHERE/IN/YOUR/PATH/ltl
```

Or, if you’d like not to depend on MoonScript at runtime :

```sh
echo '#!/usr/bin/env lua[jit]' > ltl.lua && moonc -p ltl.moon >> ltl.lua && chmod +x ltl.lua [&& mv ltl.lua SOMEWHERE/IN/YOUR/PATH/ltl]
```

# Usage

`ltl` will write to stdout the result of the code given as argument.
If this code returns a string, it will be output to stdout ;
if it returns a table, it will be output to stdout line by line
(with `tconcat(RESULT, '\n')`) ; if it returns a function (that *must*
be an iterator), it will be iterated, and the result printed line by line.

`ltl` may operate as a filter thanks to the special `IN` table (that wraps
`io.stdin`), reading the file given as input (or stdin) if applicable.

## Arguments description

```sh
echo SOMETHING | ltl [-i] [-n] [--clean] "LUA CODE" [FILE]
echo ANYTHINGELSE | ltl -m [-i] [--clean] "MOONSCRIPT CODE" [FILE]
```

`-m` : use MoonScript instead of Lua.

`-i` : in-place (like `sed`) ; only means something if `FILE` is defined.

`-n` : don't add newline at end (like `echo`)

`--clean` : By default, properties of `lpeg`, `coroutine`, `table`
(and `moon` for moonscript) are injected in the metatable index of the global environment,
for convenience in a shell context ; `re` is imported.
Moreover, a special proxy table is created, named `IN` (see below).
All that is omitted when using `--clean`.

`LUA CODE` or `MOONSCRIPT CODE` : a string containing the "program" to execute.

`FILE` : optional argument indicating from which file to read ; if you leave it empty,
but use `IN`, input will be read from stdin (and if no stdin, from user input).

## IN

IN is a special table that represents stdin. It can be used :

- by calling it, as an iterator over *lines* : `for l in IN` is an equivalent of `for l in io.stdin:lines()` ;
- by indexing it, as a table of *lines* : `IN[2]` is the 2nd line ;
- by invoking a string method on it, as a string : `ltl "print(IN)"` will output the content of stdin, `ltl -m '"--"..IN.."--"'` will output the content of stdin with all "a" replaced by "b".

## Examples

Three ways to get the square root of numbers from 1 to 10 :

```sh
$ seq 1 10 | ltl -m '[math.sqrt i for i in IN]'
```
or
```sh
$ ltl -m '[math.sqrt i for i = 1, 10]'
```
or (less ram, more cpu)
```sh
$ ltl -m 'wrap -> yield math.sqrt i for i = 1, 10'
1
1.4142135623731
1.7320508075689
2
2.2360679774998
2.4494897427832
2.6457513110646
2.8284271247462
3
3.1622776601684
```

String substitution (here, all empty lines are removed) :

```sh
$ echo '13\nabc\n\n05' | ltl -n -m 'IN\gsub("\n[\n]+", "\n")'
13
abc
05
```

Pattern-matching thanks to `lpeg` :

```sh
$ echo '13\nabc\n05' | ltl 'num = locale().digit; function non(x) return P(1) - x end; function maybe(x) return x^-1 end; return Ct((C(num^2) * maybe(non(num)^1))^1):match(tostring(IN))'
13
05
```

```sh
$ echo '13abc\n05' | ltl -m '
num = locale!.digit
non = => P(1) - self
maybe = => self^-1
Ct((C(num^2) * maybe non(num)^1)^1)\match tostring IN
'
13
05
```

Regex (`p` is a pretty-printing function from `moon`) :

```sh
$ ltl -m 'p {re.match "the number 423 is odd}", "({%a+} / .)*"'
{
    [1] = "the"
    [2] = "number"
    [3] = "is"
    [4] = "odd"
}

```
