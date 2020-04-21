package = "led"
version = "scm-1"
source = {
   url = "https://github.com/jperon/led"
}
description = {
   homepage = "https://github.com/jperon/led",
   license = "MIT"
}
dependencies = {
   "lua ~> 5.1",
   "argparse",
   "lpeg",
}
build = {
   type = "builtin",
   modules = {
      led = "led.lua"
   }
}
