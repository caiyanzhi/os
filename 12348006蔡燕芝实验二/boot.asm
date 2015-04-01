;myOs的boot程序，用于加载myOs并将控制权转给myOs
;因为myOsLoader的程序太长了不能放在引导扇区里面...
org 7c00h

call LoadnEx ;读取myOsLoader程序所在的扇区到内存

call dword Address ;跳转到myOsLoader并转交控制权

jmp $

LoadnEx:							;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
	mov ax,cs                ;段地址 ; 存放数据的内存基地址
	mov es,ax                ;设置段地址（不能直接mov es,段地址）
	mov bx, Address;偏移地址; 存放数据的内存偏移地址
	mov ah,2                 ;功能号
	mov al,2                 ;扇区数
	mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov dh,0                 ;磁头号 ; 起始编号为0
	mov ch,0                 ;柱面号 ; 起始编号为0
	mov cl,2                ;起始扇区号 ; 起始编号为1
	int 13H 				; BIOS的13h功能调用：读入指定磁盘的若干扇区到指定内存区//功能号，读取内存
	ret						;用户程序A B C D已加载到指定内存区域中

Address equ 9000h ;myOsLoader程序导入的内存地址，存放于软盘第二和第三扇区
times 510-($-$$) db 0
db 55h,0aah;
