tcc -mt -c -oe.obj e.c
tasm a.asm -o a1.obj
tlink /3/t a1.obj e.obj, e.com
tcc -mt -c -of.obj f.c
tlink /3/t a1.obj f.obj, f.com
tcc -mt -c -oh.obj h.c
tlink /3/t a1.obj h.obj, h.com
tcc -mt -c -og.obj g.c
tlink /3/t a1.obj g.obj, g.com
pause
