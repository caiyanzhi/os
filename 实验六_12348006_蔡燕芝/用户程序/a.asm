
org 100h
start:
        mov ax, cs
        mov es, ax
        mov ds, ax
        mov ss, ax
        mov sp, 100h-4
        mov ah, 0Fh
        mov al, 'A'
        mov word[es:(80*24+0)*2], ax
showch1:
        mov dword [count],4000000
        call timedelay
        inc byte[es:(80*15+0)*2];
        jmp showch1
timedelay:
        dec dword [count]
        jnz timedelay
        ret     

count dd 4000000
