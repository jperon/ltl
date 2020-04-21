# "Compilation" du projet

## Dépendances

### Nécessaires

[Lua](http://www.lua.org) (version 5.1 testée)

[MoonScript](https://moonscript.org) (version 0.5 à ce jour)

### Recommandées

[LuaJit](http://www.luajit.org)

[Luamin](https://github.com/mathiasbynens/luamin)

## Commande

```sh
moonc led.moon && echo '#!/usr/bin/env luajit' > led.lua.tmp && luamin -f led.lua >> led.lua.tmp && mv led.lua.tmp led
```


# Utilisation

## De base

```sh
echo SOMETHING | moon led.moon [-i] [--clean] "LUA CODE"
echo ANYTHINGELSE | moon led.moon -m [-i] [--clean] "MOONSCRIPT CODE"
```

## Après compilation

```sh
echo SOMETHING | led [-i] [--clean] "LUA CODE"
echo ANYTHINGELSE | led -m [-i] [--clean] "MOONSCRIPT CODE"
```

