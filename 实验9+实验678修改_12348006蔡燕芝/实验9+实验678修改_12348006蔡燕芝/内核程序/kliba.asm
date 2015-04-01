; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;                              klib.asm
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;**************************************************
;* 内核库过程版本信息      by CYZ  modify at 2014年5月26日                       *
;**************************************************


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
extrn  _SemaGet:near
extrn  _SemaFree:near
extrn  _P:near
extrn  _V:near

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

	;************ *****************************
;FAT文件系统变量
;************ *****************************
; 下面是 FAT12 磁盘的头
BS_OEMName db 'MY-OS2.0' ; OEM String,必须 8 个字节（不足补空格）
BPB_BytsPerSec dw 512; 每扇区字节数
BPB_SecPerClus db 1; 每簇多少扇区
BPB_RsvdSecCnt dw 1; Boot 记录占用多少扇区
BPB_NumFATs DB 2 ; 共有多少FAT 表
BPB_RootEnt DW 224 ; 根目录文件数最大值
BPB_TotSec16 DW 2880 ; 逻辑扇区总数
BPB_Media DB 0F0h; 介质描述符
BPB_FATSz16 DW 9; 每 FATFATFAT扇区数 扇区数
BPB_SecPerTrk db 18 ; 每磁道扇区数
BPB_NumHeads DW 2 ; 磁头数 (面数 )
BPB_HiddSec DD 0 ; 隐藏扇区数
BPB_TotSec32 DD 0 ; wTotalSectorCount 为 0时这个值记录扇区数
BS_DrvNum DB 0; 中断 13 的驱动器号
BS_Reserved1 DB 0 ; 未使用
BS_BootSigB DB 29h ; 扩展引导标记 
BS_VolID DD 12345678h ; 卷序列号 
BS_VolLab DB 'MyOS System'; ; 卷标 , 必须 11 个字节（不足补空格） 
BS_FileSysType DB 'FAT12   ' ; 文件系统类型必须 8个字节（不足补空格） 

RootDirSectors equ 14 ;根目录占用扇区数
SectorNoOfRootDirectory equ 19 ;根目录区的首扇区号
SectorNoOfFAT1 equ 1   ;FAT#1的首扇区号
SectorNoOfFAT2 equ 10   ;FAT#2的首扇区号
DeltaSectorNo equ 17   ; DeltaSectorNo = BPB_RsvdSecCnt + (BPB_NumFATs * FATSz)  - 2 
						;文件的开始扇区号 = 簇序号 + 根目录占用扇区数 + DeltaSectorNo = 簇序号 + 31
wRootDirSizeForLoop dw RootDirSectors  ;根目录剩余扇区数
wSectorNo dw 0
bOdd db 0   ;奇数还是偶数FAT项
MessageLen equ 9
Message:
	db  "Booting  ",0
	db  "Ready... ",0
	db  "Not Found",0


;*************** ********************
;*  void loadProg(char *name)
public _loadProg
_loadProg proc
	push bp
	mov bp, sp
	push bx
	push cx
	push dx
	push es
	push ds
	push si

LOAD_BEGIN:
	mov ax, cs
	mov ds, ax
	mov es, ax
	;软驱复位
	mov dh, 0
	call DispStr
	push [bp+4]
	call _myprintf
	pop ax

	xor ah, ah  ;
	xor dl, dl  ;
	int 13H
	mov word ptr[wSectorNo], 19
	mov word ptr[wRootDirSizeForLoop], 14
Label_Search_in_root_dir_begin:			;*在A盘根目录中查找文件
	cmp word ptr[wRootDirSizeForLoop], 0
	jz LABEL_NO_KERNAL_BIN
	dec word ptr[wRootDirSizeForLoop]
	mov ax, word ptr[_currentSeg]
	mov es, ax
	mov bx, word ptr [_SP_OFF] 
	mov ax, word ptr [wSectorNo]
	mov cl, 1
	
	call  ReadSector

	mov si, [bp+4]
	mov di, word ptr [_SP_OFF]
	cld ;清除DF位   word[_currentSeg]:100h = es：di 

	mov dx, 10h ;每个扇区有16个文件条目

LABEL_SEARCH_FOR_KERNAL_BIN:
	cmp dx, 0
	jz LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR
	dec dx
	mov cx,11 ;循环次数
LABEL_CMP_FILENAME:
	cmp cx, 0
	jz LABEL_FILENAME_FOUND
	dec cx
	lodsb         ;转入字符串字节  al = ds：si

	cmp al, byte ptr es:[di]
	je LABEL_GO_ON;
	jmp LABEL_DIFFERENT

LABEL_GO_ON:
    inc di
    jmp LABEL_CMP_FILENAME

LABEL_DIFFERENT:
	and di, 0FFE0h     ;还原初始di
	add di, 20h        ; di+20h指向下一条目地
	mov si, [bp+4];文件名起始地址
	
	jmp LABEL_SEARCH_FOR_KERNAL_BIN;

LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
	add word ptr[wSectorNo],1
	jmp Label_Search_in_root_dir_begin

LABEL_NO_KERNAL_BIN:
	mov dh, 2
	call DispStr
	mov ax, -1
	jmp end@@

LABEL_FILENAME_FOUND:
;计算文件簇的起始扇区号
	mov ax, RootDirSectors; 根目录占用扇区数
	and di, 0FFE0h ;di = 当前条目的开始地址
	add di, 1Ah    ;di = 文件的开始扇区号当前条目的偏移地址
	mov cx, word ptr es:[di] ;cx = 文件的相对起始扇区号
	push cx             ;保存文件的相对起始扇区号
	add cx, ax ;cx = 文件的相对起始扇区号 + 根目录占用扇区数
	add cx, DeltaSectorNo; 文件的起始扇区号
	mov ax, word ptr[_currentSeg]  ;
	mov es, ax           ;
	mov bx, word ptr[_SP_OFF];
	mov ax,cx 			  ;
LABEL_GOON_LOADING_FILE:
	push bx         ;
	mov cl, 1        ;
	call ReadSector

	mov ah, 0Eh 
	mov al, '.'
	mov bl, 0Fh 
	int 10h

	pop bx              ;装载程序的偏移地址
	pop ax              ;FAT序列号
	call GetFATEntry    ;是否下一簇号
	cmp ax, 0FF8h       ;是否是最后簇
	jae LABEL_FILE_LOADED ; > 0ff8h 跳转

	;读下一簇
	push ax
	mov dx, RootDirSectors;
	add ax, dx
	add ax, DeltaSectorNo;
	add bx,word ptr [BPB_BytsPerSec]; 下一个扇区地址
	jmp LABEL_GOON_LOADING_FILE
LABEL_FILE_LOADED:
	mov dh, 1
	call DispStr
	mov ax, 1
end@@:
	pop si
	pop ds
	pop es
	pop dx
	pop cx
	pop bx
	pop bp
	ret
_loadProg endp

;----------------------------------------------------------------------------
; 函数名：ReadSector()
;----------------------------------------------------------------------------
; 作用：从第 AX个扇区开始，将CL个扇区读入ES:BX中
public ReadSector
ReadSector proc 
	; -----------------------------------------------------------------------
	; 怎样由扇区号求扇区在磁盘中的位置 (扇区号->柱面号、起始扇区、磁头号)
	; -----------------------------------------------------------------------
	; 设扇区号为 x
	;                           ┌ 柱面号 = y >> 1
	;       x           ┌ 商 y ┤
	;   -------------- 	=> ┤      └ 磁头号 = y & 1
	;  每磁道扇区数     │
	;                   └ 余 z => 起始扇区号 = z + 1
;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
		push cx
		push bx
		mov bl, byte ptr [BPB_SecPerTrk]
		div bl;
		inc ah      ;z++
		mov cl,ah   ;起始扇区号 
		mov dh, al 	; dh = y
		shr al, 1 	;y >> 1
		mov ch, al	;ch = y >> 1 柱面号
		and dh, 1   ;dh = y & 1 磁头号
		
		pop bx
		mov dl,  byte ptr [BS_DrvNum] ; ;驱动器号 软盘为0，硬盘和U盘为80H
		
		pop ax
.GoOnReading:  
		mov ah, 2
		int 13H 		
		jc .GoOnReading
	ret
ReadSector endp

;----------------------------------------------------------------------------
; 函数名：GetFATEntry
;----------------------------------------------------------------------------
; 作用：找到序号为AX的扇区在FAT中的条目，结果放在AX中。需要注意的
;     是，中间需要读FAT的扇区到ES:BX处，所以函数一开始保存了ES和BX
public GetFATEntry
GetFATEntry proc
	push es			; 保存ES、BX和AX（入栈）
	push bx
	push ax
; 设置读入的FAT扇区写入的基地址
	mov ax, 1000h	; AX=1000h
	mov	es, ax		; ES=1000h
; 判断FAT项的奇偶
	pop	ax			; 取出FAT项序号（出栈）
	mov	byte ptr[bOdd], 0; 初始化奇偶变量值为0（偶）
	mov	bx, 3		; AX*1.5 = (AX*3)/2
	mul	bx			; DX:AX = AX * 3（AX*BX 的结果值放入DX:AX中）
	mov	bx, 2		; BX = 2（除数）
	xor	dx, dx		; DX=0	
	div	bx			; DX:AX / 2 => AX <- 商、DX <- 余数
	cmp	dx, 0		; 余数 = 0（偶数）？
	jz LABEL_EVEN	; 偶数跳转
	mov	byte ptr[bOdd], 1	; 奇数
LABEL_EVEN:		; 偶数
	; 现在AX中是FAT项在FAT中的偏移量，下面来
	; 计算FAT项在哪个扇区中(FAT占用不止一个扇区)
	xor	dx, dx		; DX=0	
	mov	bx, word ptr[BPB_BytsPerSec]	; BX=512
	div	bx			; DX:AX / 512
		  			; AX <- 商 (FAT项所在的扇区相对于FAT的扇区号)
		  			; DX <- 余数 (FAT项在扇区内的偏移)
	push dx			; 保存余数（入栈）
	mov bx, 0 		; BX <- 0 于是，ES:BX = 1000h:0
	add	ax, SectorNoOfFAT1 ; 此句之后的AX就是FAT项所在的扇区号
	mov	cl, 2			; 读取FAT项所在的扇区，一次读两个，避免在边界
	call	ReadSector	; 发生错误, 因为一个 FAT项可能跨越两个扇区
	pop	dx			; DX= FAT项在扇区内的偏移（出栈）
	add	bx, dx		; BX= FAT项在扇区内的偏移
	mov	ax, es:[bx]	; AX= FAT项值
	cmp	byte ptr[bOdd], 1	; 是否为奇数项？
	jnz	LABEL_EVEN_2	; 偶数跳转
	shr	ax, 4			; 奇数：右移4位（取高12位）
LABEL_EVEN_2:		; 偶数
	and	ax, 0FFFh	; 取低12位
LABEL_GET_FAT_ENRY_OK:
	pop	bx			; 恢复ES、BX（出栈）
	pop	es
	ret
GetFATEntry endp


DispStr:  ;从ax个扇区开始读取cl个扇区放入es:bx中
mov ax, cs
mov es, ax
mov ax, MessageLen
mul dh
add ax, offset Message; AX = al*dh
push ax
call _myprintf
pop ax
ret

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
			mov	bx, 700h	; 黑底白字(BH = 7)
			mov	cx, 0		; 左上角: (0, 0)
			mov	dx, 184fh	; 右下角: (24, 79) ;上滚整个文本页
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
mov bp,sp
	;mov ah,2ch;2ch号功能调用，取系统时间：ch,cl,dh中分别存放时分秒
	;int 21h
	mov ah, 2h
	int 1ah
	mov ax, [bp + 12]
	mov bx, ax
	mov [bx], ch
	mov ax, [bp + 14]
	mov bx, ax
	mov [bx], cl
	mov ax, [bp + 16]
	mov bx, ax
	mov [bx], dh
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
mov bp,sp
	;mov ah,2ah;cx,dh,dl中分别年月日
	;int 21h
	mov ah, 4h
	int 1ah
	mov ax, [bp + 12]
	mov bx, ax
	mov [bx], cx
	mov ax, [bp + 14]
	mov bx, ax
	mov [bx], dh
	mov ax, [bp + 16]
	mov bx, ax
	mov [bx], dl
pop ax
pop dx
pop cx
pop bx
pop bp
ret
_getdate endp


; ****************************************
;      void _memcopy(int ss1,int ss2, int len);
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
push bp
mov bp, sp
mov ax,[bp+16]   ;ss_son
mov es,ax
mov di, 0
mov ax, [bp+18]  ;ss_father
mov ds, ax
mov si, 0
mov cx, [bp+20]  ;传输长度
cld
rep movsw; ds:si->es:di
pop bp
pop cx
pop si
pop di
pop ds
pop es
pop ax
ret
_memcopy endp

; ****************************************
;      void loadsubProgram(int numOfsector, int zhutouhao,int zhumian, int qishishanqu)
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
	 ; 设扇区号为 x
    ;                           ┌ 柱面号 = y >> 1
    ;       x           ┌ 商 y ┤
    ; -------------- => ┤      └ 磁头号 = y & 1
    ;  每磁道扇区数     │
    ;                   └ 余 z => 起始扇区号 = z + 1
    ;1.44M软盘结构

	;1、 结构：2面、80道/面、18扇区/道、512字节/扇区 
    ;     扇区总数=2面 X  80道/面 X  18扇区/道  =  2880扇区 
    ;    存储容量= 512字节/扇区X  2880扇区 =  1440 KB

 	;2、  2  面： 编号0----1； 
    ;      80道： 编号0----79 ；
    ;    18扇区：编号1----18 ；
		;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
		mov ax,word ptr[_currentSeg];段地址 ; 存放数据的内存基地址
		mov es,ax       ;设置段地址（不能直接mov es,段地址）
		mov ax, word ptr[_SP_OFF];偏移地址; 存放数据的内存偏移地址
		mov bx, ax;      
		mov ah,2                 ;功能号
		mov al,[bp+12]                 ;扇区数 
		mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
		mov dh,[bp+14]                  ;磁头号 ; 起始编号为0
		mov ch,[bp+16]             ;柱面号 ; 起始编号为0
		mov cl,[bp+18]            ;起始扇区号 ; 起始编号为1
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
call _Restart

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
_Restart proc  ;当前栈顶:\psw\cs\ip\call_restart
	mov ax, cs
	mov ds, ax
	call _getCurrentPCB             ;第一次进入时为 &pcb_list[0]
	mov si, ax

	mov ss,word ptr ds:[si+0]         
	mov sp,word ptr ds:[si+2*8]
	mov bp, sp
	
	;恢复进入中断时栈顶,若用户程序第一次运行，则必须模拟进入中断
	mov ax, word ptr ds:[si + 2*16]  ;状态为GO时，模拟进入中断的入栈
	cmp ax, 1
	je intoInt
	
AfterInt:
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
	push ax         
	mov al,20h; AL = EOI          ; 发送中断处理结束消息给中断控制器
	out 20h,al; 发送EOI到主8529A
	out 0A0h,al; 发送EOI到从8529A
	pop ax
	iret
	
intoInt:
	push word ptr ds:[si+2*15] ; push fl
	push word ptr ds:[si+2*14] ;push cs
	push word ptr ds:[si+2*13]	;push ip    ;模拟中断进入操作
	mov word ptr ds:[si+2*16], 3
	jmp AfterInt
	
_Restart endp

int33_12_1:
	mov ax, cs
	mov ds, ax
	mov es, ax
	push dx 					;当前栈顶:\psw\cs\ip\dx\call_save ->exit()中会重新开始下一进程
	call _exit
	pop dx
	call _Schedule
	call _restart

int33_10_1:
	call _Save
	call _fork
	call _restart

int33_11_1:
	call _Save
	call _wait
	call _Schedule
	call _restart

int33_13_1:
	mov ax, cs
	mov ds, ax
	push dx
	call _SemaGet
	pop dx
	jmp int33end

int33_14_1:
	mov ax, cs
	mov ds, ax
	push dx
	call _SemaFree
	pop dx
	jmp int33end

int33_15_1:
	call _Save
	call _P
	call _restart
	
int33_16_1:
	mov ax, cs
	mov ds, ax
	push dx
	call _V
	pop dx
	jmp int33end

	
; ****************************************
;  void setInt33()
; ; ****************************************
; 33号中断的安装，实现自己的系统调用
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

int33:
int33Begin:
	cmp ah, 11
	je int33_11_1
	cmp ah, 12
	je int33_12_1
	cmp ah, 10
	je int33_10_1
	cmp ah, 15
	je int33_15_1
	push bp
	push bx
	push cx
	push dx
	push es
	push ds
	
	cmp ah, 13
	je int33_13_1
	cmp ah, 14
	je int33_14_1
	cmp ah, 16
	je int33_16_1
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

; ****************************************
;  void exchange(int *bolt, int key)
; ; ****************************************
; 交换指令
public _exchange
_exchange proc
push bp
mov bp,sp
push bx
	mov ax, [bp+6]
	mov bx,[bp+4]
	xchg ax, word ptr[bx];
pop bx
pop bp
ret
_exchange endp

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