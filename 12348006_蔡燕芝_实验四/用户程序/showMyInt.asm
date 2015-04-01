; 程序源代码（showOuch.asm）
;实现的功能是，显示OS提供的33 34 35 36号中断，按Esc返回
;create by YZ Cai
; time: 2014年4月3日
org 7e00h					; 

start:
	;xor ax,ax					; AX = 0   程序加载到0000：100h才能正确执行
	; 设置时钟中断向量（08h），初始化段寄存器
push bp
mov bp, sp
push bp
	push ax
	push cx
	push bx
	push dx
	push ds
	push es
	
	xor ax,ax						; AX = 0
	mov es,ax					; ES = 0
	mov ax, word[es:24h]
	push ax
	mov word[es:24h],toExit	; 设置键盘中断向量的偏移地址
	mov ax, [es:26h]
	push ax
	mov ax,cs 
	mov [es:26h],ax				; 设置键盘中断向量的段地址=CS
	
	mov ax,cs
	mov ds,ax					; DS = CS
	mov es,ax					; ES = CS
	mov word[Flag], 0

	mov ax,cs                 ;
	mov ds,ax                 ;
	mov bp,ax
	mov	bp, Message ; BP=当前串的偏移地址
	mov	ax, ds			    ; ES:BP = 串地址
	mov	es, ax			    ; 置ES=DS 
	mov	 cx, MessageLength       	; CX = 串长（=MessageLength）
	mov	 ax, 1301h	 
	; AH = 13h（功能号）、AL = 01h（光标置于串尾）
	mov	 bx, 0007h
	; 页号为0(BH = 0) 黑底白字(BL = 07h)
	mov  dh, 0	; 行号=0
	mov	 dl, 0		; 列号=0
	int	10h		; BIOS的10h功能：显示一行字符

	mov	bp, Message1 ; BP=当前串的偏移地址
	mov	ax, ds			    ; ES:BP = 串地址
	mov	es, ax			    ; 置ES=DS 
	mov	 cx, MessageLength1       	; CX = 串长（=10）
	mov	 ax, 1301h	 
	; AH = 13h（功能号）、AL = 01h（光标置于串尾）
	mov	 bx, 0007h
	; 页号为0(BH = 0) 黑底白字(BL = 07h)
	mov  dh, 10	; 行号=1
	mov	 dl, 0		; 列号=0
	int	10h		; BIOS的10h功能：显示一行字符

	int 33
	int 34
	int 35
	int 36
	
	myLoop:
		mov ax, word[Flag]
		cmp ax, 1
		je Exit
	jmp myLoop
	
;键盘中断程序
toExit:
	push es
	push ax
	in al , 0x60 				;不读取键盘中断无法再次响应
	cmp al, 1
	je setFlag
endd:					;从中断返回
	pop ax
	pop es
	mov al,20h					; AL = EOI
	out 20h,al						; 发送EOI到主8529A
	out 0A0h,al					; 发送EOI到从8529A
	iret							; 从中断返回

	
setFlag:
	mov word[Flag], 1
	jmp endd

Flag dw 0
Exit:
	xor ax,ax						; AX = 0
	mov es,ax	
	pop ax
	mov [es:26h], ax
	pop ax
	mov word[es:24h],ax 
	pop es
	pop ds
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	mov sp, bp
	pop bp
	ret

	Message db 'Here is the showMyInt.com which show the server int 33, 34,35,36'
	MessageLength equ ($-Message)
	Message1 db 'You can type Esc to exit...'
	MessageLength1 equ ($-Message1)