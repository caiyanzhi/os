;程序源代码（boot.asm）
;用NASM汇编此程序
;nasm –f bin boot.asm –o boot.bin
org  7c00h		; BIOS将把引导扇区加载到0:7C00处，并开始执行
Start:
mov	ax, cs	; 置其他段寄存器值与CS相同
mov	ds, ax	; 数据段
LoadKernal:
;读软盘或硬盘上的kernal到内存的ES:BX处：
mov ax, SegOfKernal  ;段地址 ; 存放数据的内存基地址
mov es,ax           ;设置段地址（不能直接mov es,段地址）
mov bx, OffSetOfKernal  ;偏移地址; 存放数据的内存偏移地址
mov ah,2                ; 功能号
mov al, 10        ;扇区数
mov dl,0          ;驱动器号 ; 软盘为0，硬盘和U盘为80H
mov dh,0          ;磁头号 ; 起始编号为0
mov ch,0          ;柱面号 ; 起始编号为0
mov cl,2           ;起始扇区号 ; 起始编号为1
int 13H ; 调用中断
;内核已加载到指定内存区域中

jmp SegOfKernal : OffSetOfKernal
jmp $             ;无限循环
Message:
    db 'Loading MyOs kernal'
MessageLength  equ ($-Message)
OffSetOfKernal  equ 100h
SegOfKernal    equ 4096;第二个64k内存的段地址  
QTYofBlockOfKernal equ 10     ;内核占用扇区数
times 510-($-$$)	db	0	; 用0填充引导扇区剩下的空间
	db 	55h, 0aah				; 引导扇区结束标志
