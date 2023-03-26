#!/usr/bin/env moon

parser = require"argparse" "ltl", "LuaTooL - lua/moonscript for shell"
parser\argument "code", "Code to execute"
parser\argument("file", "File to read from (or - for stdin)")\args"?"
parser\flag "-i", "In-place editing"
parser\flag "-n", "No newline at end"
parser\flag "-m --moonscript"
parser\flag "-d --debug"
parser\flag "--clean"
args = parser\parse!
assert(args.file, "In-place on which file ?") if args.i
_moonscript = args.moonscript or arg[0]\sub(-3) == 'mtl'
_dbg = (...) -> args.debug and io.stderr\write ...

ok, fun = pcall require, "fun"
fun! if ok
loadstring or= load
unpack or= table.unpack

math.randomseed os.time!

export IN, MOONSCRIPT_HEADER, r, re, create, resume, status, wrap, yield, concat, insert, pack, remove, sort
if not args.clean
  re = require"re"
  r = (...) -> require ...
  MOONSCRIPT_HEADER = "r'moon.all'\n"

do
  local _fn, _stdin
  if args.file
    _fn = ->
      f = assert io.open(args.file), "Can't read from #{args.file}"
      _r = f\read"*a"
      f\close!
      _r
  else
    _fn = -> io.stdin\read"*a"
  _mt = getmetatable(_G) or {}
  _oldindex = _mt.__index
  _mt.__index = (idx) =>
    if idx == 'IN'
      IN = {
      __index: (i) =>
        str = tostring @
        ret = str[i]
        ret if type(ret) ~= 'function' else (...) => ret str, ...
      __call: coroutine.wrap =>
        yield or= coroutine.yield
        yield l for l in @gmatch"[^\n]+"
      __tostring: =>
        _stdin or= _fn!
        _stdin
      }
      setmetatable IN, IN
      i = 1
      IN[i], i = l, i + 1 for l in IN\gsub("\n$", "")\gmatch"([^\n]*)\n?"
      return IN
    else
      for t in *{coroutine, table, math, require"lpeg"}
        return t[idx] if t[idx]
    _oldindex @, idx if _oldindex
  setmetatable _G, _mt

_code = args.code
if _moonscript
  _code = assert require"moonscript.base".to_lua MOONSCRIPT_HEADER.._code

ret, err = loadstring _code
assert ret, err
ret = ret!

out = args.i and assert(io.open(args.file, 'w'), "Can't write to #{args.file}") or io.stdout
_dbg type ret, ret
if ret
  switch type ret
    when 'function'
      out\write"#{_r}\n" for _r in ret
    when 'table'
      if ret.param
        ret\each => out\write"#{@}\n"
      else
        out\write"#{table.concat ret, '\n'}#{args.n and '' or '\n'}"
    else
      out\write"#{ret}#{args.n and '' or '\n'}"
