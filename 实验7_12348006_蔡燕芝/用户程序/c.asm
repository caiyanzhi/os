
org 100h
start:
        mov ax, cs
        mov es, ax
        mov ds, ax
        mov ss, ax
        mov sp, 100h-4
        mov ax, 0b800h
        mov es, ax
        mov ah, 0Ch
        mov al, 'A'
        mov word[es: (80*24 + 40)*2], ax
showch1:
        call timedelay
        mov ah, 0
        inc ax
        mov ah,0Ch 
        mov word[es: (80*24 + 40)*2], ax
        mov dword [count],4000000
        dec dword [ccount]
        cmp dword [ccount], 0
        je Exit
        jmp showch1
timedelay:
        dec dword [count]
        jnz timedelay
        ret     

Exit:
mov dx, 0
mov ah, 12
int 33

count dd 4000000
ccount dd 6000
