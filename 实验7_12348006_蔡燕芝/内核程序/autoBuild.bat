tcc -mt -c -oprocess.obj process.h
tasm akernal.asm -o akernal.obj
tcc -mt -c -ockernal.obj ckernal.c
tcc -mt -c -omyInt33.obj myInt33.c
tlink /3/t akernal.obj ckernal.obj myInt33.obj process.obj, kernal.com
pause
