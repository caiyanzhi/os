
org 100h
start:
        mov ax, cs
        mov es, ax
        mov ds, ax
        mov ss, ax
        mov sp, 100h-4
      
showch1:
        mov al,'B'
        mov bl,0
        mov ah,0eh
        int 10h 
        call timedelay
        jmp showch1

timedelay:
        dec dword [count]
        jnz timedelay
        mov dword [count],4000000
        ret     

count dd 4000000
