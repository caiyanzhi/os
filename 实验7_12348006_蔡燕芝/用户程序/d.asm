org 100h
start:
mov ax, cs
mov es, ax
mov ds, ax
mov ss, ax
mov sp, 100h-4
Exit:
mov dx, 0
mov ah,12
int 33
ret