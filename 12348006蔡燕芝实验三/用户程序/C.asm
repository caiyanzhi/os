org 7e00h
start:
push bp
mov bp, sp
push bp
	push ax
	push bx
	push cx
	push dx
	mov si, Message
	sub1:
		mov al, [si]
		add si, 1
		cmp al, '$'
		je quit
		mov ah, 0eh
		mov bl, 0
		int 10h
		loop sub1
quit:
	mov ah,0
	int 16h
showch: ; 显示键入字符
	mov ah,0eh 	    ; 功能号
	mov bl,0 		; 对文本方式置0
	int 10h 		; 调用10H号中断
exit1:
pop dx
pop cx
pop bx
pop ax
pop bp
mov sp, bp
pop bp
	ret
Message:
	db 'hello, here is C.com!please print any char to quit..$'
MessageLength  equ ($-Message)
times 512-($-$$)	db	0	; 用0填充引导扇区剩下的空间