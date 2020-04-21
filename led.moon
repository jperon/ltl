#!/usr/bin/env moon

parser = require"argparse" "led", "sed in lua / moonscript"
parser\argument "code", "Code to execute"
parser\flag "-i"
parser\flag "-m --moonscript"
parser\flag "--clean"
args = parser\parse!

loadstring or= load
unpack or= table.unpack

export IN, MOONSCRIPT_HEADER, r, stdin, stderr, create, resume, status, wrap, yield, concat, insert, remove, sort
if not args.clean
  setmetatable _G or _ENV, __index: require"lpeg"
  import create, resume, status, wrap, yield from coroutine
  import concat, insert, remove, sort from table
  --import stdin, stderr from io
  r = (...) -> require ...
  MOONSCRIPT_HEADER = "r = (...) -> require ...\nr'moon.all'\n"

IN =
  _stdin: io.stdin\read'*a'
  __index: (idx, s=tostring(self), r=s[idx]) =>
    if type(r) == 'function' then (...) => r(s, ...)
    else r
  __call: coroutine.wrap =>
    yield or= coroutine.yield
    yield l for l in @gmatch"[^\n]+"
  __tostring: => @_stdin

setmetatable(IN, IN)
do
  i = 1
  for l in IN\gmatch"[^\n]+"
    IN[i], i = l, i + 1

code = args.code
if args.moonscript
  code = assert require"moonscript.base".to_lua MOONSCRIPT_HEADER..code

ret, err = loadstring(code)
io.stderr\write(err) if not ret
ret = ret()
io.stdout\write(tostring(ret)) if ret
