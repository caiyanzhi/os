; 程序源代码（stone.asm）
; By Ling Yingbiao 2013/12/28 
; 还有bugs  已修复恰好到达四个角落之后屏幕上失去小球的bugs by 蔡燕芝 2014年4月1日
; 本程序在文本方式显示器上从左边射出一个*号,以45度向右下运动，撞到边框后反射,如此类推.
Dn_Rt equ 1                  ;D-Down,U-Up,R-right,L-Left
Up_Rt equ 2                  ;把_Rt定义为1,2,3,4
Up_Lt equ 3                  ;
Dn_Lt equ 4                  ; 
delay equ 10000					; 计时器延迟计数,用于控制画框的速度
ddelay equ 1000					; 计时器延迟计数,用于控制画框的速度

org 7e00h					; 程序加载到100h，可用于生成COM
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

	mov ax,cs                 ;
	mov ds,ax                 ;
	mov bp,ax
	mov	bp, Message ; BP=当前串的偏移地址
	mov	ax, ds			    ; ES:BP = 串地址
	mov	es, ax			    ; 置ES=DS 
	mov	 cx, MessageLength        	; CX = 串长（=10）
	mov	 ax, 1301h	 
	; AH = 13h（功能号）、AL = 01h（光标置于串尾）
	mov	 bx, 0007h
	; 页号为0(BH = 0) 黑底白字(BL = 07h)
	mov  dh, 0	; 行号=10
	mov	 dl, 0		; 列号=10
	int	10h		; BIOS的10h功能：显示一行字符
	
	xor ax,ax						; AX = 0
	mov es,ax					; ES = 0
	mov ax, word[es:24h]
	push ax
	mov word[es:24h],OUCHOUCH	; 设置键盘中断向量的偏移地址,敲击键盘则 两个小球显示OUCH！
	mov ax, [es:26h]
	push ax
	mov ax,cs 
	mov [es:26h],ax				; 设置键盘中断向量的段地址=CS
	
	xor ax,ax						; AX = 0
	mov es,ax					; ES = 0
	mov ax, word[es:20h]
	push ax
	mov word[es:20h],AnotherShow		; 设置时钟中断向量的偏移地址,显示两个小球的运动�
	mov ax, [es:22h]
	push ax
	mov ax,cs 
	mov [es:22h],ax				; 设置时钟中断向量的段地址=CS

	mov ds,ax					; DS = CS
	mov es,ax					; ES = CS

	mov	ax,0B800h				; 文本窗口显存起始地址
	mov	gs,ax					; GS = B800h
    mov byte[char],'A'
	mov byte[char@],'B'
	mov word[Flag], 0
loopp1:
	cmp word[Flag], 1
	je Exit
	jmp loopp1

;键盘中断程序
OUCHOUCH:
	call showOUCH				;显示ouch
	in al , 0x60 				;不读取键盘中断无法再次响应
	cmp al, 1
	je setFlag
endd:							;从中断返回
	mov al,20h					; AL = EOI
	out 20h,al						; 发送EOI到主8529A
	out 0A0h,al					; 发送EOI到从8529A
	iret							; 从中断返回
	
setFlag:
	mov word[Flag], 1
	jmp endd
		
;	时钟中断程序
AnotherShow:
	dec byte[counttime]				; 递减计数变量
	jnz endd						; >0：跳转
	mov byte[counttime],delaytime			; 重置计数变量=初值delay
	call movA
	call movB
	
	jmp endd

movB:
	mov al,1
    cmp al,byte[rdul@]    
	jz  DnRt@
    mov al,2
    cmp al,byte[rdul@]    
	jz  UpRt@
    mov al,3
    cmp al,byte[rdul@]    
	jz  UpLt@
    mov al,4
    cmp al,byte[rdul@]    
	jz  DnLt@
DnRt@:
	inc word[x@]
	inc word[y@]
	mov bx,word[x@]
	add bx, word[y@]
	mov ax, 105
	cmp ax, bx
	je dr2ul@
	mov bx,word[x@]
	mov ax,25
	sub ax,bx
    jz  dr2ur@
	mov bx,word[y@]
	mov ax,80
	sub ax,bx
    jz  dr2dl@
	jmp show@
dr2ul@:
	mov word[x@],23
	mov word[x@],78
    mov byte[rdul@],Up_Rt
    jmp show@
dr2ur@:
    mov word[x@],23
    mov byte[rdul@],Up_Rt
    jmp show@
dr2dl@:
    mov word[y@],78
    mov byte[rdul@],Dn_Lt
    jmp show@

UpRt@:
	dec word[x@]
	inc word[y@]
	mov bx,word[y@]
	mov ax,80
	cmp ax, bx
	je urChange@
	mov bx,word[x@]
	mov ax,0
	sub ax,bx
    jz  ur2dr@
	jmp show@
	
urChange@:
	mov bx,word[x@]
	mov ax,0
	cmp ax,bx
	jne ur2ul@
	mov word[y@],78
	mov word[x@], 2
    mov byte[rdul@],Dn_Lt
    jmp show@
	
ur2ul@:
    mov word[y@],78
    mov byte[rdul@],Up_Lt	
    jmp show@
ur2dr@:
    mov word[x@],2
    mov byte[rdul@],Dn_Rt
    jmp show@
UpLt@:
	dec word[x@]
	dec word[y@]
	mov bx,word[x@]
	mov ax,0
	sub ax,bx
    jz  ulChange@
	mov bx,word[y@]
	mov ax,-1
	sub ax,bx
    jz  ul2ur@
	jmp show@
	
ulChange@:
	mov bx,word[y@]
	mov ax,-1
	cmp ax, bx
	jne ul2dl@
	mov word[x@],2
	mov word[y@],1
	mov byte[rdul@],Dn_Rt
    jmp show@
ul2dl@:
    mov word[x@],2
    mov byte[rdul@],Dn_Lt	
    jmp show@
ul2ur@:
    mov word[y@],1
    mov byte[rdul@],Up_Rt
    jmp show@
	
DnLt@:
	inc word[x@]
	dec word[y@]
	mov bx,word[y@]
	mov ax,-1
	sub ax,bx
    jz  dlChange@
	mov bx,word[x@]
	mov ax,25
	sub ax,bx
    jz  dl2ul@
	jmp show@

dlChange@:
	mov bx,word[x@]
	mov ax,25
	cmp bx, ax
	jne dl2dr@
	mov word[y@],1
	mov word[x@],23
    mov byte[rdul@],Up_Rt
    jmp show@
	
dl2dr@:
    mov word[y@],1
    mov byte[rdul@],Dn_Rt	
    jmp show@
	
dl2ul@:
    mov word[x@],23
    mov byte[rdul@],Up_Lt	
    jmp show@
	
show@:	
    xor ax,ax                 ; 计算显存地址
    mov ax,word[x@]
	mov bx,80
	mul bx
	add ax,word[y@]
	mov bx,2
	mul bx
	mov bp,ax
	mov ah,0Fh				;  0000：黑底、1111：亮白字（默认值为07h）
	mov al,byte[char@]			;  AL = 显示字符值（默认值为20h=空格符）
	mov word[gs:bp],ax  		;  显示字符的ASCII码值
	loop22@:
	dec word[count@]				; 递减计数变量
	jnz loop22@					; >0：跳转;
	mov word[count@],delay
	dec word[dcount@]				; 递减计数变量
    jnz loop22@
	mov word[count@],delay
	mov word[dcount@],ddelay
	mov al, ' '
	mov word[gs:bp],ax
	ret
	
movA:	
	mov al,1
    cmp al,byte[rdul]    
	jz  DnRt
    mov al,2
    cmp al,byte[rdul]    
	jz  UpRt
    mov al,3
    cmp al,byte[rdul]    
	jz  UpLt
    mov al,4
    cmp al,byte[rdul]    
	jz  DnLt
DnRt:
	inc word[x]
	inc word[y]
	mov bx,word[x]
	add bx, word[y]
	mov ax, 105
	cmp ax, bx
	je dr2ul
	mov bx,word[x]
	mov ax,25
	sub ax,bx
    jz  dr2ur
	mov bx,word[y]
	mov ax,80
	sub ax,bx
    jz  dr2dl
	jmp show
dr2ul:
	mov word[x],23
	mov word[x],78
    mov byte[rdul],Up_Rt	
    jmp show
dr2ur:
    mov word[x],23
    mov byte[rdul],Up_Rt	
    jmp show
dr2dl:
    mov word[y],78
    mov byte[rdul],Dn_Lt	
    jmp show

UpRt:
	dec word[x]
	inc word[y]
	mov bx,word[y]
	mov ax,80
	cmp ax, bx
	je urChange
	mov bx,word[x]
	mov ax,0
	sub ax,bx
    jz  ur2dr
	jmp show
	
urChange:
	mov bx,word[x]
	mov ax,0
	cmp ax,bx
	jne ur2ul
	mov word[y],78
	mov word[x], 2
    mov byte[rdul],Dn_Lt	
    jmp show
	
ur2ul:
    mov word[y],78
    mov byte[rdul],Up_Lt	
    jmp show
ur2dr:
    mov word[x],2
    mov byte[rdul],Dn_Rt	
    jmp show
UpLt:
	dec word[x]
	dec word[y]
	mov bx,word[x]
	mov ax,0
	sub ax,bx
    jz  ulChange
	mov bx,word[y]
	mov ax,-1
	sub ax,bx
    jz  ul2ur
	jmp show
	
ulChange:
	mov bx,word[y]
	mov ax,-1
	cmp ax, bx
	jne ul2dl
	mov word[x],2
	mov word[y],1
	mov byte[rdul],Dn_Rt	
    jmp show
ul2dl:
    mov word[x],2
    mov byte[rdul],Dn_Lt	
    jmp show
ul2ur:
    mov word[y],1
    mov byte[rdul],Up_Rt	
    jmp show
	
DnLt:
	inc word[x]
	dec word[y]
	mov bx,word[y]
	mov ax,-1
	sub ax,bx
    jz  dlChange
	mov bx,word[x]
	mov ax,25
	sub ax,bx
    jz  dl2ul
	jmp show

dlChange:
	mov bx,word[x]
	mov ax,25
	cmp bx, ax
	jne dl2dr
	mov word[y],2
	mov word[x],23
    mov byte[rdul],Up_Rt
    jmp show
	
dl2dr:
    mov word[y],2
    mov byte[rdul],Dn_Rt	
    jmp show
	
dl2ul:
    mov word[x],23
    mov byte[rdul],Up_Lt	
    jmp show
	
show:	
    xor ax,ax                 ; 计算显存地址
    mov ax,word[x]
	mov bx,80
	mul bx
	add ax,word[y]
	mov bx,2
	mul bx
	mov bp,ax
	mov ah,0Fh				;  0000：黑底、1111：亮白字（默认值为07h）
	mov al,byte[char]			;  AL = 显示字符值（默认值为20h=空格符）
	mov word[gs:bp],ax  		;  显示字符的ASCII码值
loop22:
	dec word[count]				; 递减计数变量
	jnz loop22					; >0：跳转;
	mov word[count],delay
	dec word[dcount]				; 递减计数变量
    jnz loop22
	mov word[count],delay
	mov word[dcount],ddelay
	mov al, ' '
	mov word[gs:bp],ax
	ret

;显示ouch！
showOUCH:
;显示小球A的ouch
showAOUCH:
	xor ax, ax
	mov ax, word[x]
	mov bx, 80
	mul bx
	add ax, word[y]
	mov bx, 2
	mul bx
	mov bp, ax
	mov ah, 0Fh
	mov al, 'O'
	mov word[gs:bp],ax
	mov al, 'U'
	mov word[gs:bp+2],ax
	mov al, 'C'
	mov word[gs:bp+4],ax
	mov al, 'H'
	mov word[gs:bp+6],ax
	mov al, '!'
	mov word[gs:bp+8],ax
	push bp
;显示小球B的ouch
showBOUCH:
xor ax, ax
	mov ax, word[x@]
	mov bx, 80
	mul bx
	add ax, word[y@]
	mov bx, 2
	mul bx
	mov bp, ax
	mov ah, 0Fh
	mov al, 'O'
	mov word[gs:bp],ax
	mov al, 'U'
	mov word[gs:bp+2],ax
	mov al, 'C'
	mov word[gs:bp+4],ax
	mov al, 'H'
	mov word[gs:bp+6],ax
	mov al, '!'
	mov word[gs:bp+8],ax
;延时操作，然后清空刚才显示的ouch！
loop2:
	dec word[count]				; 递减计数变量
	jnz loop2					; >0：跳转;
	mov word[count],delay
	dec word[dcount]				; 递减计数变量
    jnz loop2
	mov word[count],delay
	mov word[dcount],ddelay
	mov al, ' '
	mov word[gs:bp],ax
	mov al, ' '
	mov word[gs:bp+2],ax
	mov al, ' '
	mov word[gs:bp+4],ax
	mov al, ' '
	mov word[gs:bp+6],ax
	mov al, ' '
	mov word[gs:bp+8],ax
	pop bp
	mov al, ' '
	mov word[gs:bp],ax
	mov al, ' '
	mov word[gs:bp+2],ax
	mov al, ' '
	mov word[gs:bp+4],ax
	mov al, ' '
	mov word[gs:bp+6],ax
	mov al, ' '
	mov word[gs:bp+8],ax
	ret

Exit:
	xor ax,ax						; AX = 0
	mov es,ax	
	pop ax
	mov [es:22h], ax
	pop ax
	mov word[es:20h],ax
	pop ax
	mov [es:26h], ax
	pop ax
	mov word[es:24h],ax 
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	mov sp, bp
	pop bp
	ret

datadef:	
	count dw delay
	dcount dw ddelay
    rdul db Dn_Rt         ; 向右下运动
    x dw 2
	y dw -1
	char db 'A'
	count@ dw delay
	dcount@ dw ddelay
    rdul@ db Dn_Lt         ; 向左下运动
    x@ dw 0
	y@ dw 80
	char@ db 'B'
	delaytime equ 3					; 计时器延迟计数
	counttime db delaytime					; 计时器计数变量，初值=delay
	Message db 'Here is the stone.asm, you can input Esc to exit...'
	MessageLength equ ($-Message)
	Flag dw 0
