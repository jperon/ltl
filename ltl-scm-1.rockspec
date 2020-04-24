package = "ltl"
version = "scm-1"
source = {
   url = "https://github.com/jperon/ltl"
}
description = {
   homepage = "https://github.com/jperon/ltl",
   license = "MIT"
}
dependencies = {
   "lua ~> 5.1",
   "argparse",
   "copas",
   "copas-async",
   "lpeg",
   "moonscript"
}
build = {
   type = "command",
   build_command = "make",
   modules = {
      ltl = "ltl.lua"
   },
   install = {
      bin = { "ltl" }
   }
}
