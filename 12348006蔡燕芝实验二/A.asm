; 程序源代码（sum.asm）
; 两个存放内存的数num1和num2相加，将结果存放在sum中
org 8100h
start:
	mov ax,cs                 ;
	mov ds,ax                 ;
	mov bp,ax
	mov	bp, Message		    ; BP=当前串的偏移地址
	mov	ax, ds			    ; ES:BP = 串地址
	mov	es, ax			    ; 置ES=DS
	mov	cx, MessageLength 	; CX = 串长（=9）
	mov	ax, 1300h			; AH = 13h（功能号）、AL = 00h
	;mov	bx, 0007h		    ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov bx, 000ch ; 页号为0 BH = 0 黑底红字 BL = 0ch 高亮
    mov dh, 1			    ; 行号=0
	mov	dl, 0			    ; 列号=0
	int	10h				    ; BIOS的10h功能：显示一行字符
	retf
Message:
	db 'hello, here is A.com!'
MessageLength  equ ($-Message)
times 512-($-$$)	db	0	; 用0填充引导扇区剩下的空间