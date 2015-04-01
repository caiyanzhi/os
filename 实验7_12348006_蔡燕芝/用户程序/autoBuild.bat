tasm a.asm -o a1.obj
tcc -mt -c -oa2.obj a.c
tlink /3/t a1.obj a2.obj, a.com
pause
