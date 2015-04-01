
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;                              klib.asm
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


; 导入全局变量
extrn	_disp_pos

;**************************************************
;* 内核库过程版本信息                             *
;**************************************************

;************ *****************************
; *SCOPY@                               *
;****************** ***********************
; 实参为局部字符串带初始化异常问题的补钉程序
public SCOPY@
SCOPY@ proc 
		arg_0 = dword ptr 6
		arg_4 = dword ptr 0ah
		push bp
			mov bp,sp
		push si
		push di
		push ds
			lds si,[bp+arg_0]
			les di,[bp+arg_4]
			cld
			shr cx,1
			rep movsw
			adc cx,cx
			rep movsb
		pop ds
		pop di
		pop si
		pop bp
		retf 8
SCOPY@ endp

;*************** ********************
;*  void _cls()                       *
;**************** *******************
; 清屏
public _cls
_cls proc 
; 清屏  push bp
        push ax
        push bx
        push cx
        push dx	
			mov	ax, 600h	; AH = 6,  AL = 0
			mov	bx, 700h	; 黑底白字(BL = 7)
			mov	cx, 0		; 左上角: (0, 0)
			mov	dx, 184fh	; 右下角: (24, 79)
				int	10h		; 显示中断
			;设置光标位置(dh,dl) = (行，列) = (0,0)
            ;mov bx,0
            ;mov ah,2
            ;int 10h
		pop dx
		pop cx
		pop bx
		pop ax
        mov word ptr [_disp_pos],0
		ret
_cls endp

;**** ***********************************
;* void _PrintChar()                       *
;******* ********************************
; 字符输出
public _printChar
_printChar proc 
	push bp
		mov bp,sp
		;***
		mov al,[bp+4]
		mov bl,0
		mov ah,0eh
		int 10h
		;***
		mov sp,bp
	pop bp
	ret
_printChar endp

;*********** ****************************
;*  void _GetChar()                       *
;****************** *********************
; 读入一个字符
public _getChar
_getChar proc
	mov ah,0
	int 16h
showch: ; 显示键入字符
	mov ah,0eh 	    ; 功能号
	mov bl,0 		; 对文本方式置0
	int 10h 		; 调用10H号中断
	mov ah,0
	ret
_getChar endp

; ****************************************
; *  void _printf(char * pszInfo);             *
; ****************************************
; 字符串输出
Public	_printf
_printf proc
	push	bp         ;sp+2
	push	es         ;sp+2+2
	push    ax         ;sp+2+2+2
    	mov ax,0b800h
		mov es,ax	
		mov	bp, sp     

		mov	si, word ptr [bp + 2+2+2+2]	; pszInfo\IP\bp\es\ax
		mov	di, word ptr [_disp_pos]
		mov	ah, 0Fh
	.1:
		mov al,byte ptr [si]
		inc si
		mov byte ptr [di],al
		test al, al
		jz	.2
		cmp	al, 0Ah	; 是回车吗?
		jnz	.3
		push	ax
		mov	ax, di
		mov	bl, 160
		div	bl
		and	ax, 0FFh
		inc	ax
		mov	bl, 160
		mul	bl
		mov	di, ax
		pop	ax
		jmp	.1
	.3:
		mov	es:[di], ax
		add	di, 2
		jmp	.1
	.2:
		mov	[_disp_pos], di
    pop ax
	pop es
	pop	bp
	ret
_printf endp

;*********** ****************************
;*  int getline(char *mess);                  *
;****************** *********************
;读入字符串，返回读入的字符串的个数
public _getline
_getline proc
 push bp
 push cx
 push dx
 push bx
 mov bp, sp

 ;dx清0，存放输入的字符个数
 xor dx,dx
 mov ax, offset [bp+10] ;字符串mess的地址
 mov bx,ax
 ;存放字符串的地址放入bx
 ;从键盘输入一个字符
string: 
 mov ah,0
 int 16h
 ;判断是否是回车
 cmp al,13
 je exit
 ;判断是否是退格
 cmp al,8
 jne save;不是退格才存储字符
 mov ax, 0
 cmp dx, ax
 je noTobackspace
 jmp backspace

noTobackspace:
push bx
push dx
  ;读光标位置，(dh,dl) = (行，列)
 mov bh,0
 mov ah,3
 int 10h
 ;保存行列
 ;mov row,dh
 ;mov col,dl
 ;设置光标位置(dh,dl) = (行，列)
 mov bh,0
 mov ah,2
 int 10h
 ;在光标位置显示空字符
 mov bh,0
 mov al,32 ;显示字符
 mov bl,7 ;字符属性
 mov cx,1 ;字符重复次数
 mov ah,9
 pop dx
 pop bx
jmp nextstr

save:
 ;存储字符到[bx]单元中
 mov byte ptr [bx],al
 push bx
 push dx
 showch@: ; 显示键入字符
	mov ah,0eh 	    ; 功能号
	mov bl,0 		; 对文本方式置0
	int 10h 		; 调用10H号中断
	mov ah,0
 pop dx
 pop bx
 inc bx
 inc dx
nextstr:
 jmp string
exit:
 mov ax,dx
 mov byte ptr [bx],'$'
 mov sp, bp
 pop bx
 pop dx
 pop cx
 pop bp
 ret
_getline endp

;退格键功能子程序，当按下退格键的时候调用
backspace proc
 sub bx,1
 sub dx,1
 push bx
 push dx
  ;读光标位置，(dh,dl) = (行，列)
 mov bh,0
 mov ah,3
 int 10h
 ;保存行列
 ;mov row,dh
 ;mov col,dl
 sub dl,1
 ;设置光标位置(dh,dl) = (行，列)
 mov bh,0
 mov ah,2
 int 10h
 ;在光标位置显示空字符
 mov bh,0
 mov al,32 ;显示字符
 mov bl,7 ;字符属性
 mov cx,1 ;字符重复次数
 mov ah,9
 int 10h 
 pop dx
 pop bx
 jmp nextstr
backspace endp

; ****************************************
;      void _myprintf(char * info, int color);
; ****************************************
; 字符串输出，光标置于尾部
public _myprintf
_myprintf proc
	push bp
	push ax
	push dx
	mov bp, sp
	mov dx , 0
	mov si, [bp+8]
	sub1:
		mov al, [si]
		add si, 1
		cmp al, '$'
		je exit1
		push ax
		call _printchar
		loop sub1
exit1:
	mov sp,bp
	pop dx
	pop ax
	pop bp
	ret
_myprintf endp


; ****************************************
;      void _cprintf(char * info, int color);
; ****************************************
; 彩色字符串输出
Public	_cprintf
_cprintf proc
	push	bp         ;sp+2
	push	es         ;sp+2+2
	push    ax         ;sp+2+2+2
    	mov ax,0b800h
		mov es,ax
		mov	bp, sp

		mov	si, word ptr [bp + 2+2+2+2]	; pszInfo\IP\bp\es\ax
		mov	di, word ptr [_disp_pos]
		mov	ah, byte ptr [bp +2+2+2+2]	; color
	.1@:
		mov al,byte ptr [si]
		inc si
		mov byte ptr [di],al

		test	al, al
		jz	.2@
		cmp	al, 0Ah	; 是回车吗?
		jnz	.3@
		push	ax
		mov	ax, di
		mov	bl, 160
		div	bl
		and	ax, 0FFh
		inc	ax
		mov	bl, 160
		mul	bl
		mov	di, ax
		pop	ax
		jmp	.1@
	.3@:
		mov	word ptr es:[di], ax
		add	di, 2
		jmp	.1@

	.2@:
		mov	word ptr [_disp_pos], di

    pop ax
	pop es
	pop	bp
	ret
_cprintf endp
; ****************************************
;      void _port_out(u16 port, u8 value);
; ; ****************************************
; 端口输出
Public	_port_out
_port_out proc
    push bp
            mov bp,sp
        	mov	dx, word ptr [bp + 2]		; port
			mov	al, byte ptr [bp + 2 + 2]	; value
			out	dx, al
			nop	; 一点延迟
			nop
			mov sp,bp
	pop bp
	ret
_port_out endp
; ****************************************
;* u8 _Port_In(u16 port)                     *;
; ****************************************
; 端口输出
public	_Port_In
_Port_In proc
    push bp
    mov bp,sp
    mov	dx, word ptr [bp + 2]		; port
	  xor	ax, ax
	  in	al, dx
		nop	; 一点延迟
		nop
	  mov sp,bp
	  pop bp
	  ret
_Port_In endp

; ****************************************
; *    void _getTime(int *hh, int *mm, int *ss) 返回时间
; * 获取系统时间
public _getTime
_getTime proc
push bp
push bx
push cx
push dx
push ax
push di
mov bp,sp
	;mov ah,2ch;2ch号功能调用，取系统时间：ch,cl,dh中分别存放时分秒
	;int 21h
	mov ah, 2h
	int 1ah
	mov ax, [bp + 14]
	mov bx, ax
	mov [bx], ch
	mov ax, [bp + 16]
	mov bx, ax
	mov [bx], cl
	mov ax, [bp + 18]
	mov bx, ax
	mov [bx], dh
	mov sp, bp
pop di
pop ax
pop dx
pop cx
pop bx
pop bp
ret
_getTime endp

; ****************************************
; *    void _getDate(int *yy, int *mm, int *dd) 返回时间
; * 获取系统日期
public _getDate
_getdate proc
push bp
push bx
push cx
push dx
push ax
push di
mov bp,sp
	;mov ah,2ah;cx,dh,dl中分别年月日
	;int 21h
	mov ah, 4h
	int 1ah
	mov ax, [bp + 14]
	mov bx, ax
	mov [bx], cx
	mov ax, [bp + 16]
	mov bx, ax
	mov [bx], dh
	mov ax, [bp + 18]
	mov bx, ax
	mov [bx], dl
	mov sp, bp
pop di
pop ax
pop dx
pop cx
pop bx
pop bp
ret
_getdate endp


; ****************************************
;      void runSubProgram(int numOfsector, int startSector)
; ; ****************************************
; 运行子程序
public _runSubProgram 
_runSubProgram proc
push bp
	push ax
	mov bp, sp  
		mov ax, [bp+8] ; numofSector
		push ax
		mov ax, [bp + 6]; startSector
		push ax
		call _loadSubProgram ;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
		pop ax
		pop ax
		mov ax, 7e00h
		call ax
exits:	
	mov sp, bp
	pop ax
pop bp
	ret						;用户程序C已加载到指定内存区域中
_runSubProgram endp

; ****************************************
;      void loadsubProgram(int address, int offset,int numOfsector, int startSector)
; ; ****************************************
; 加载子程序到内存
public _LoadsubProgram
_LoadsubProgram proc					
	push bp
	push ax
	push bx
	push cx
	push dx
	mov bp, sp  
		;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
		mov ax, cs;段地址 ; 存放数据的内存基地址
		mov es,ax       ;设置段地址（不能直接mov es,段地址）
		mov ax, 7e00h   ;偏移地址; 存放数据的内存偏移地址
		mov bx, ax;      
		mov ah,2                 ;功能号
		mov al,[bp+12]                 ;扇区数 
		mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
		mov dh,0                 ;磁头号 ; 起始编号为0
		mov ch,0                 ;柱面号 ; 起始编号为0
		mov cl,[bp+14]           ;起始扇区号 ; 起始编号为1
		int 13H 				; BIOS的13h功能调用：读入指定磁盘的若干扇区到指定内存区//功能号，读取内存
	mov sp, bp
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret						;用户程序C已加载到指定内存区域中
_LoadsubProgram endp
