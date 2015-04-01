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
	;call near ptr _cls 
	call setint33           ;设置33号中断。自定义的dos中断功能服务
	call near ptr _cmain    ;进入主程序
	
    jmp $

include kliba.asm

Mess db 'i   lllll  lllll'
_TEXT ends
;************DATA segment*************
_DATA segment word public 'DATA'
_DATA ends
;*************BSS segment*************
_BSS	segment word public 'BSS'
_BSS ends
;**************end of file***********
end start
