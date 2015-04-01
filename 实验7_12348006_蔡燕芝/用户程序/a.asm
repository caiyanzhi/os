extrn _cmain:near
;主要功能在cmain实现
.8086
_TEXT segment byte public 'CODE'
DGROUP group _TEXT,_DATA,_BSS
       assume cs:_TEXT

org 100h
start:
	mov ax, cs
    mov es, ax
    mov ds, ax
    mov ss, ax
    mov sp, 100h-4
    call _cmain
include userlib.asm

_TEXT ends
;************DATA segment*************
_DATA segment word public 'DATA'
_DATA ends
;*************BSS segment*************
_BSS	segment word public 'BSS'
_BSS ends
;**************end of file***********
end start
