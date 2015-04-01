tcc -mt -c -okernal.obj kernal.h
tasm akernal.asm -o akernal.obj
tcc -mt -c -ockernal.obj ckernal.c
tlink /3/t akernal.obj ckernal.obj myInt33.obj kernal.obj, kernal.com
pause
