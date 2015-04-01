%define _BOOT_DEBUG_
%ifdef _BOOT_DEBUG_
org 100h
BaseOfStack equ 100h
%else
org 7c00h
BaseOfStack equ 7c00h
%endif

jmp short LABEL_START
nop

; 下面是 FAT12 磁盘的头
BS_OEMName db 'MY-OS2.0' ; OEM String,必须 8 个字节（不足补空格）
BPB_BytsPerSec dw 512; 每扇区字节数
BPB_SecPerClus db 1; 每簇多少扇区
BPB_RsvdSecCnt dw 1; Boot 记录占用多少扇区
BPB_NumFATs DB 2 ; 共有多少FAT 表
BPB_RootEnt DW 224 ; 根目录文件数最大值
BPB_TotSec16 DW 2880 ; 逻辑扇区总数
BPB_Media DB 0xF0; 介质描述符
BPB_FATSz16 DW 9; 每 FATFATFAT扇区数 扇区数
BPB_SecPerTrk DW 18 ; 每磁道扇区数
BPB_NumHeads DW 2 ; 磁头数 (面数 )
BPB_HiddSec DD 0 ; 隐藏扇区数
BPB_TotSec32 DD 0 ; wTotalSectorCount 为 0时这个值记录扇区数
BS_DrvNum DB 0; 中断 13 的驱动器号
BS_Reserved1 DB 0 ; 未使用
BS_BootSigB DB 29h ; 扩展引导标记 
BS_VolID DD 12345678h ; 卷序列号 
BS_VolLab DB 'MyOS System'; ; 卷标 , 必须 11 个字节（不足补空格） 
BS_FileSysType DB 'FAT12   ' ; 文件系统类型必须 8个字节（不足补空格） 

OffSetOfKernal  equ 100h
SegOfKernal    equ 4096;第二个64k内存的段地址 
RootDirSectors equ 14 ;根目录占用扇区数
SectorNoOfRootDirectory equ 19 ;根目录区的首扇区号
SectorNoOfFAT1 equ 1   ;FAT#1的首扇区号
SectorNoOfFAT2 equ 10   ;FAT#2的首扇区号
DeltaSectorNo equ 17   ; DeltaSectorNo = BPB_RsvdSecCnt + (BPB_NumFATs * FATSz)  - 2 
						;文件的开始扇区号 = 簇序号 + 根目录占用扇区数 + DeltaSectorNo = 簇序号 + 31


wRootDirSizeForLoop equ RootDirSectors  ;根目录剩余扇区数
wSectorNo dw 0
bOdd db 0   ;奇数还是偶数FAT项

LABEL_START:
mov ax, cs ; 置 DS 和 ES=CS
mov ds, ax 
mov ax, SegOfKernal
mov es, ax
mov bx, OffSetOfKernal
mov ax, [wSectorNo]
mov cl, 1;只读一个扇区
call ReadSector

mov dh, 0
Call DispStr; 调用显示字符串例程 

jmp $ 



DispStr:  ;从ax个扇区开始读取cl个扇区放入es:bx中
mov ax, MessageLen
mul dh
add ax, Message ; AX = al*dh
mov bp, ax ; ES:BP = 串地址
mov cx, MessageLen; CX = ; CX = ; CX = ; CX = ; CX = ; CX = 串长度 串长度
mov ax, 01301h
mov bx, 000ch ; 页号为 0(BH = 0),(BL = 0Ch, 高亮 )
mov dl, 0
int 10h ; 显示中断
ret

;从ax个扇区开始读取cl个扇区放入es:bx中
ReadSector:
 ; 设扇区号为 x
    ;                           ┌ 柱面号 = y >> 1
    ;       x           ┌ 商 y ┤
    ; -------------- => ┤      └ 磁头号 = y & 1
    ;  每磁道扇区数     │
    ;                   └ 余 z => 起始扇区号 = z + 1

		;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
		push cx
		push bx
		mov bl, [BPB_SecPerTrk]
		div bl;
		inc ah      ;z++
		mov cl,ah   ;起始扇区号 
		mov dh, al 	; dh = y
		shr al, 1 	;y >> 1
		mov ch, al	;ch = y >> 1 柱面号
		and dh, 1   ;dh = y & 1 磁头号
		pop bx
		mov dl, [BS_DrvNum] ; ;驱动器号 软盘为0，硬盘和U盘为80H

.GoOnReading:  
		pop ax
		mov ah, 2
		int 13H 		
		jc .GoOnReading

	ret

;计算文件簇的起始扇区号
mov ax, RootDir

;查找文件
;在A盘根目录中查找文件
mov word[wSectorNo], SectorNoOfRootDirectory
Label_Search_in_root_dir_begin:
	
	cmp word[wRootDirSizeForLoop], 0
	jz LABEL_NO_KERNAL_BIN
	dec word[wRootDirSizeForLoop]
	mov ax, SegOfKernal 
	mov es, ax
	mov bx, OffSetOfKernal
	mov ax, [wSectorNo]
	mov cl, 1
	call ReadSector  ;
	mov si, LoaderFileName;
	mov di, OffSetOfKernal
	cld

	mov dx, 10h

LABEL_SEARCH_FOR_KERNAL_BIN:
	cmp dx, 0
	jz LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR
	dec dx
	mov cs, 11
LABEL_CMP_FILENAME:
	cmp cx, 0
	jz LABEL_FIELNAME_FOUND
	dec cx
	lodsb
	cmp al, byte[es:di]
	jz LABEL_GO_ON; 
	jmp LABEL_DIFFERENT

LABEL_GO_ON:
    inc di
    jmp LABEL_CMP_FILENAME

LABEL_DIFFERENT:
	add word[wSectorNo],1



MessageLen equ 10
Message:
	db  "Booting..."
	db  "Ready...  "
	db  "No kernal"

times 510 -($ -$$) db 0 ; 用 0填充剩下的空间
db 55h, 0aah; 引导扇区结束标志

db 0f0h,0ffh,0ffh  ;介质描述符f0h,fh,结束簇标志项fffh
times 512*9 - 3 db 0; 用 0填充FAT#1剩下的空间 
db 0f0h,0ffh,0ffh  ;介质描述符f0h,fh,结束簇标志项fffh
times 512*9 - 3 db 0; 用 0填充FAT#2剩下的空间 
; 根目 录中的卷标条根目
db 'MYOS System' ;卷标 11个字节
db 8 ; 文件属性（卷标条目的为 08h08h ）
dw 0,0,0,0,0 ; 10 个保留字节 
dw 0,4070h ; 创建时间
dw 0;开始簇号（卷标条目的必需为 开始簇号（卷标条目的必需为 0）
dd 0 ;文件大小（也设为 0）