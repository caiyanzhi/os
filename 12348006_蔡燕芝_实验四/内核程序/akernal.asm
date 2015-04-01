extrn _cmain:near
;主要功能在cmain实现，涉及到io操作等的在kliba.asm 中实现，在cmain中调用
.8086
_TEXT segment byte public 'CODE'
DGROUP group _TEXT,_DATA,_BSS
       assume cs:_TEXT


org 100h

start:
	mov  ax,  cs
	mov  ds,  ax           ; DS = CS
	mov  es,  ax           ; ES = CS
	mov  ss,  ax           ; SS = cs
	mov  sp, 100h   
	call setint33
	call setint34
	call setint35
	call setint36 
	call setMyClock
	call near ptr _cmain
    jmp $

include kliba.asm
_TEXT ends
;************DATA segment*************
_DATA segment word public 'DATA'
_DATA ends
;*************BSS segment*************
_BSS	segment word public 'BSS'
_BSS ends
;**************end of file***********
end start
