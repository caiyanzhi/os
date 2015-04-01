
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;                              klib.asm
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


; 导入全局变量
extrn	_disp_pos
extrn   _upper:near
extrn   _int2Chars:near
extrn   _chars2Int:near
extrn   _lowwer:near
extrn   _showTime:near
extrn   _SaveCurrentPCB:near
extrn   _CurrentPCBno:near
extrn   _getCurrentPCB:near
extrn   _Schedule:near
extrn   _isUserMode:near
extrn   _currentSeg:near
extrn   _SP_OFF:near
extrn   _exit:near
extrn   _fork:near
extrn   _wait:near
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
 mov ax,dx    ;返回的字符串的长度
 mov byte ptr [bx],0
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
	push si
	mov bp, sp
	mov dx , 0
	mov si, [bp+10]
	sub1:
		mov al, [si]
		add si, 1
		test al,al
		jz exit1
		push ax
		call _printchar
		pop ax
		jmp sub1
exit1:
	pop si
	pop dx
	pop ax
	pop bp
	ret
_myprintf endp


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
;      void loadsubProgram(int numOfsector, int startSector)
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
		mov ax,word ptr[_currentSeg];段地址 ; 存放数据的内存基地址
		mov es,ax       ;设置段地址（不能直接mov es,段地址）
		mov ax, word ptr[_SP_OFF];偏移地址; 存放数据的内存偏移地址
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

; ****************************************
;      void powerOff()
; ; ****************************************
; 关机
public _powerOff 
_powerOff proc
	mov    ax,5301H
    xor    bx,bx
    xor    cx,cx
    int    15H
    mov    ax,530EH
    xor    bx,bx
    mov    cx,102H
    int    15H
    mov    ax,5307H
    mov    bx,1
    mov    cx,3
    int    15H
_powerOff endp


; ****************************************
;      void _memcopy(char *,char *, int len);
; ; ****************************************
; 复制内存的数据
public _memcopy
_memcopy proc
push ax
push es
push ds
push di
push si
push cx

mov ax,[bp+10]
mov es,ax
mov di, 0
mov ax, [bp+12]
mov si, 0
mov cx, [bp+14]

cld
rep movsw; ds:si->es:di

pop cx
pop si
pop di
pop ds
pop es
pop ax
ret
_memcopy endp

; ****************************************
;  void setNewInt(int offset, int numOfInt)
; ; ****************************************
; 安装中断向量
public _setNewInt
_setNewInt proc
	push bp
	push ax
	push es
	mov bp, sp  

	mov ax, 0
	mov es, ax
	
	mov al, 4
	mov bl, [bp+10]
	mul bl
	mov di, ax

	mov ax, [bp+8]
	mov word ptr es:[di], ax ; 设置中断向量的偏移地址
	add di, 2
	mov ax, [bp+12]          
	mov word ptr es:[di], ax; 设置中断向量的段地址

	mov sp, bp
	pop es
	pop ax
	pop bp
	ret
_setNewInt endp

; ****************************************
;  void setTimer()
; ; ****************************************
;	设置计时器函数，每秒20次中断
public _setTimer
_setTimer proc
	push ax
	mov al, 34h	;设置控制字值
	out 43h,al  ;写控制字到控制字寄存器
	mov ax, 59660; 1193182/59660=20次
	out 40h, al
	mov al, ah
	out 40h,al
	pop ax
	ret
_setTimer endp
; ****************************************
;  void setMyClock()
; ; ****************************************
;	安装时钟中断程序
public _setMyClock 
_setMyClock proc
	push ax
	;call setTimer ;设置计时器函数，每秒20次中断
	mov ax, cs
	push ax
	mov ax, 8
	push ax
	mov ax, offset Timer ;设置时钟中断向量
	push ax
	call _setNewInt       ;	安装时钟中断程序
	pop ax
	pop ax
	pop ax
	pop ax
	ret
_setMyClock endp

Timer: ;时间中断，用于用户程序轮转
call _Save
call _Schedule      ;时间片顺序轮转
jmp _Restart

public _Save
_Save proc
	;当前栈顶:\psw\cs\ip\call_save   用户栈，第一次进入为内核栈
	.386
	push ss 
	push gs
	push fs
	push es
	push ds
	.8086
	push di
	push si
	push bp
	push sp  ;  这里的sp是当前的栈顶,而非进入前栈顶
	push bx
	push dx
	push cx
	push ax     ;将pcb 表需要的东西压栈作为参数传给_SaveCurrentPCB

	mov ax,cs
	mov ds, ax
	mov es, ax

	call _SaveCurrentPCB ;sp暂时是不正确的,在restart里面修复

	add sp, 2*13  ;当前栈顶:\psw\cs\ip\call_save
	ret
_Save endp

public _Restart
_Restart proc
	mov ax, cs
	mov ds, ax
	call _getCurrentPCB             ;第一次进入时为 &pcb_list[0]
	mov si, ax

	mov ss,word ptr ds:[si+0]         
	mov sp,word ptr ds:[si+2*8]
	add sp, 12*2    ;恢复进入时间中断前栈顶

	push word ptr ds:[si+2*15] ; push fl
	push word ptr ds:[si+2*14] ;push cs
	push word ptr ds:[si+2*13]	;push ip    ;模拟中断进入操作
	
	push word ptr ds:[si+2*1]   ;push gs    ;调出寄存器值
	push word ptr ds:[si+2*2]   ;push fs
	push word ptr ds:[si+2*3]   ;push es
	push word ptr ds:[si+2*4]   ;push ds
	push word ptr ds:[si+2*5]   ;push di
	push word ptr ds:[si+2*6]   ;push si
	push word ptr ds:[si+2*7]   ;push bp
	push word ptr ds:[si+2*9]   ;push bx
	push word ptr ds:[si+2*10]   ;push dx
	push word ptr ds:[si+2*11]   ;push cx
	push word ptr ds:[si+2*12]   ;push ax

	;恢复各寄存器值
	pop ax
	pop cx
	pop dx
	pop bx
	pop bp
	pop si
	pop di
	pop ds
	pop es
	.386
	pop fs
	pop gs
	.8086

TimerExit:
	push ax         
	mov al,20h; AL = EOI          ; 发送中断处理结束消息给中断控制器
	out 20h,al; 发送EOI到主8529A
	out 0A0h,al; 发送EOI到从8529A
	pop ax
	iret
_Restart endp


MyClock:	
	push ax
	push es
	jmp MyClockBegin
	charA equ 1
	charB equ 2
	charC equ 3
	chx dw charA
	delay equ 4					; 计时器延迟计数
	count dw delay				;计时器计数变量，初值=delay

MyClockBegin:
	dec word ptr [count]				; 递减计数变
	jnz endd@						; >0：跳转
	mov word ptr [count], delay			; 重置计数变量=初值delay
	call showChar
	jmp endd@

showChar:
	mov	ax,0B800h				; 文本窗口显存起始地址
	mov	es,ax					; GS = B800h
	mov ax, 1
	mov di, (24*80+79)*2 		;右下角
	cmp ax, word ptr[chx]		;轮流显示| \ /
	jz show1
	mov ax, 2
	cmp ax, word ptr[chx]
	jz show2
	mov ax, 3
	cmp ax, word ptr[chx]
	jz show3
show1:							;显示'|'
	mov ah,0Fh
	mov al, '|'
	mov word ptr es:[di], ax
	mov word ptr [chx], 2
	ret
show2:                          ;显示'/'
	mov ah,0Fh
	mov al, '/'
	mov word ptr es:[di], ax
	mov word ptr [chx], 3
	ret
show3:                          ;显示'\'
    mov ah,0Fh
	mov al, '\'
	mov word ptr es:[di], ax
	mov word ptr [chx], 1
	ret
endd@:						; 从中断返回
	pop es
	pop ax
	mov al,20h					; AL = EOI
	out 20h,al						; 发送EOI到主8529A
	out 0A0h,al					; 发送EOI到从8529A
	iret	


; ****************************************
;  void setInt33()
; ; ****************************************
; 33号中断的安装，实现自己的系统能调用
public setint33
setint33 proc
push ax
push es
	mov ax, cs
	push ax
	mov ax, 33
	push ax
	mov ax, offset int33
	push ax
	call _setNewInt
	pop ax
	pop ax
	pop ax
pop es
pop ax
	ret

int33_12_1:
	mov ax, cs
	mov es, ax
	mov ds, ax
	push dx 					;当前栈顶:\psw\cs\ip\dx\call_save ->exit()中会重新开始下一进程
	call _exit
	jmp _restart

int33_10_1:
	call _Save
	call _fork
	jmp _restart

int33_11_1:
	call _Save
	call _wait
	jmp _restart

int33:
int33Begin:
	cmp ah, 10
	je int33_10_1
	cmp ah, 11
	je int33_11_1
	cmp ah, 12
	je int33_12_1

	push bp
	push bx
	push cx
	push dx
	push es
	push ds
	
	cmp ah, 0                ;根据功能号实现对应的功能
	je int33_00
	cmp ah, 1
	je int33_01
	cmp ah, 2
	je int33_02
	cmp ah, 3
	je int33_03
	cmp ah, 4
	je int33_04
	cmp ah, 5
	je int33_05
	cmp ah, 6
	je int33_06
	cmp ah, 7
	je int33_07
	cmp ah, 8
	je int33_08
	cmp ah, 9
	je int33_09

int33_00:				;0号功能：在屏幕中间显示"OUCH"
	call int33_00_1
	jmp int33end

int33_01:               ;1号功能: 将es:dx位置的一个字符串中的小字母变为大字
	call int33_01_1
	jmp int33end

int33_02:
	call int33_02_1
	jmp int33end

int33_03:              ;3号功能: 将es:di位置的字符串大写变小写
	call int33_03_1	
	jmp int33end

int33_04:              ;4号功能: 将bx的数值转变对应的es:dx位置的一个数字字符串
	call int33_04_1
	jmp int33end

int33_05:              ;5号功能: 将es:dx位置的一个字符串显示在屏幕指定位置(ch:行号cl:列号)
	call int33_05_1
	jmp int33end

int33_06:              ;6号功能: 读入字符串，放在es：dx位置
	call int33_06_1
	jmp int33end

int33_07:              ;7号功能: 读入一个字符放在ax
	call _getChar
	jmp int33end

int33_08:              ;8号功能: 在屏幕的最下方中间显示当前时间

	call int33_08_1
	jmp int33end

int33_09:				;9号功能： 将es:dx位置的一个字符串显示在屏幕
	call int33_09_1
	jmp int33end

int33end:
	pop ds
	pop es
	pop dx
	pop cx
	pop bx
	pop bp
	iret
setint33 endp


int33_00_1: 
	push es
	push ax
	            ;0号功能具体实现
	mov ax, 0b800h                    ;显示'INT34'
	mov es,ax
	mov di, (80*13+38)*2
	mov ah, 0Fh
	mov al, 'O'
	mov word ptr es:[di], ax
	mov al, 'U'
	mov word ptr es:[di+2], ax
	mov al, 'C'
	mov word ptr es:[di+4], ax
	mov al, 'H'
	mov word ptr es:[di+6], ax
	pop ax
	pop es
	ret

int33_01_1:             ;1号功能具体实现
	mov ax, es
	mov ds, ax
	push dx
	call _upper
	pop dx
	ret

int33_02_1:
	mov ax, es
	mov ds, ax
	push dx
	call _lowwer
	pop dx
	ret

int33_03_1:
	mov ax, es
	mov ds, ax
	push dx
	call _chars2Int
	pop dx
	ret

int33_04_1:
	mov ax, es
	mov ds, ax
	push bx
	push dx
	call _int2Chars
	pop dx
	pop bx
	ret

int33_05_1:
	push dx
	push cx
	 
 	mov bh,0          ;读光标位置，(dh,dl) = (行，列)
 	mov ah,3
 	int 10h
 	
 	pop cx 			  ;恢复cx
 				
	push dx           ;保存光标位置

 	mov dx, cx        ;设置光标位置(dh,dl) = (ch，cl)
 	mov bh,0
 	mov ah,2
 	int 10h

 	pop dx            ;恢复dx

 	mov ax, es
 	mov ds, ax
 	call _myPrintf    ;显示字符串
 	
 	mov bh,0          ;恢复光标位置(dh,dl)
 	mov ah,2
 	int 10h
 	pop dx
	ret

int33_06_1:
	mov ax, es
	mov ds, ax
	push dx
	call _getline;
	pop ax
	ret

int33_08_1:
	mov bh,0          ;读光标位置，(dh,dl) = (行，列)
 	mov ah,3
 	int 10h
 				
	push dx           ;保存光标位置

	mov dh, 24
	mov dl, 38       ;设置光标位置(dh,dl) = (24，38)
 	mov bh,0
 	mov ah,2
 	int 10h

 	call _showTime    ;在(24，35)显示当前时间
 	pop dx
 	mov bh,0          ;恢复光标位置(dh,dl)
 	mov ah,2
 	int 10h
	ret


int33_09_1:
	mov ax, es
 	mov ds, ax
 	push dx
 	call _myPrintf    ;显示字符串
	pop dx
	ret
