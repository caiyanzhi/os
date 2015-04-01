tcc -mt -c -oe.obj e.c
tasm user.asm -o user.obj
tlink /3/t user.obj e.obj, e.com
tcc -mt -c -of.obj f.c
tlink /3/t user.obj f.obj, f.com
tcc -mt -c -oa.obj a.c
tlink  /3/t user.obj a.obj, a.com
tcc -mt -c -oh.obj h.c
tlink /3/t user.obj h.obj, h.com
tcc -mt -c -og.obj g.c
tlink /3/t user.obj g.obj, g.com
pause
