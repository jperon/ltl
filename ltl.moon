#!/usr/bin/env moon

copas = require"copas"
async = require"copas.async"
parser = require"argparse" "ltl", "LuaTooL - lua/moonscript for shell"
parser\argument "code", "Code to execute"
parser\argument("file", "File to read from (or - for stdin)")\args"?"
parser\flag "-i", "In-place editing"
parser\flag "-n", "No newline at end"
parser\flag "-m --moonscript"
parser\flag "--clean"
args = parser\parse!
assert(args.file, "In-place on which file ?") if args.i
_moonscript = args.moonscript or arg[0]\sub(-3) == 'mtl'

loadstring or= load
unpack or= table.unpack


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
        str = tostring(self)
        ret = str[i]
        ret if type(ret) ~= 'function' else (...) => ret(str, ...)
      __call: coroutine.wrap =>
        yield or= coroutine.yield
        yield l for l in @gmatch"[^\n]+"
      __tostring: =>
        _stdin or= _fn!
        _stdin
      }
      setmetatable(IN, IN)
      i = 1
      IN[i], i = l, i + 1 for l in IN\gmatch"[^\n]+"
      return IN
    else
      for t in *{coroutine, table, require"lpeg"}
        return t[idx] if t[idx]
    _oldindex self, idx if _oldindex
  setmetatable(_G, _mt)

  

_code = args.code
if _moonscript
  _code = assert require"moonscript.base".to_lua MOONSCRIPT_HEADER.._code

ret, err = loadstring(_code)
assert(ret, err)
copas.addthread -> ret = ret!
copas.loop!

out = args.i and assert(io.open(args.file, 'w'), "Can't write to #{args.file}") or io.stdout
if ret
  switch type ret
    when 'function'
      out\write _r..'\n' for _r in ret
    when 'table'
      out\write table.concat(ret, '\n') .. (args.n and '' or '\n')
    when 'number'
      ret .. (args.n and '' or '\n')
    else
      out\write tostring(ret) .. (args.n and '' or '\n')
