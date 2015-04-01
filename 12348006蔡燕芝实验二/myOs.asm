;Loader程序,实现原型操作系统，可以处理3个程序的批处理
;提示输入abc, or ab, or c, or ca,最多三个字符，必须是abc,暂时没有容错能力，要保证输入正确
;按输入顺序执行代码，由于要显示结果，所以可以看出A，B，C执行的结果，并返回该程序提示是否重新
;选择程序运行,输入y则刷新屏幕重新提示输入,输入m则OS暂停，jmp $

org 9000h

main: ;主函数
	call Clear ;清屏
	call StartMsg ;
	call InitData ;初始化
	call TipDispStr1 ;显示提示字符串
	call TipDispStr2 ;
	jmp Keyin ;用户输入

;以下都是键盘输入的代码

Keyin:
    mov ah,0 	    ; 功能号
	int 16h 	    ; 调用16H号中断
	cmp al,0dh      ; 判断是否是回车，回车的 Ascii 码为 0dh(13)
	je RunUserPro     ; 开始执行用户选择的程序顺序
	cmp word[whetherToRestart],1 ;如果重置键为1
	je ifRestart    ;判断重置或者停止执行
	call showch      ; 没有回车，则显示用户键入的字符
	jmp Continue
	
showch: ; 显示键入字符
	mov ah,0eh 	    ; 功能号
	mov bl,0 		; 对文本方式置0
	int 10h 		; 调用10H号中断
	ret

ifRestart: ;继续执行判断
	cmp al,'y'
	je main
	cmp al,'n'
	retf
	call showch
	

Continue:  ; 继续执行
	inc word[num]     ; num++
	mov ah,0          ; ah 置零
	cmp word[num],4   ; 判断用户是否键入超过 3 个字符
	je main           ; 超过 3 个则进行刷新显示
	cmp word[num],2   ; 是否是输入的第二个字符
	je ReadB 		  ; 读取b
	cmp word[num],3   
	je ReadC          
	cmp word[num],1
	jmp ReadA        
ReadB:
	mov word[b],ax      ; 跳转到 I2，存储第二个字符到 b
	jmp Keyin           ; 跳转到准备接受下一个输入

ReadA: ;原理同上，但是加入对Finish判断
	mov word[a],ax
	jmp Keyin

ReadC:
	mov word[c],ax
	jmp Keyin

;重置控制
Restart:  ;重新开始的判断输入
	mov word[num],0
	jmp Keyin;

;用户程序控制的代码
RunUserPro:  
	call Clear 		;清屏
	call ExcuteStr	;一下几行显示执行信息
	mov ax, word[a]
	call showch
	mov ax, word[b]
	call showch
	mov ax,word[c]
	call showch
	call Excute    ;执行子程序

Excute: ;按指令顺序执行
	mov ax,word[index]  
	cmp ax, word[num]
	je Finish           ;当index和num一样时，结束
	inc word[index]   
	mov ax,word[index]  ;执行第index个程序
	cmp ax,1            ;ax = index
	je ExcuteA
	cmp ax,2
	je ExcuteB
	cmp ax,3
	je ExcuteC
	je main

ExcuteA:   ;执行第一个程序，按word[a]所对应的执行,如word[a] = 'a',则执行A程序
	mov ax,word[a]
	cmp ax,'a'
	je RunA
	cmp ax,'b'
	je RunB
	cmp ax,'c'
	je RunC
	ret

ExcuteB:   ;执行第2个程序，按word[a]所对应的执行,如word[a] = 'a',则执行A程序
	mov ax,word[b]
	cmp ax,'a'
	je RunA
	cmp ax,'b'
	je RunB
	cmp ax,'c'
	je RunC
	ret

ExcuteC:   ;执行第3个程序,按word[a]所对应的执行,如word[a] = 'a',则执行A程序
	mov ax,word[c]
	cmp ax,'a'
	je RunA
	cmp ax,'b'
	je RunB
	cmp ax,'c'
	je RunC
	ret

RunA:  ;执行程序A
    call LoadA;装载程序
   call dword OffSetOfUserPrg1
   jmp Excute
RunB:   ;执行程序B
   call LoadB;装载程序
   call dword OffSetOfUserPrg2
   jmp Excute
RunC:   ;执行程序C
   call LoadC;装载程序
   call dword OffSetOfUserPrg3
   jmp Excute

;清屏
Clear:  
    mov ax,0003H    ; 设置清屏属性
    int 10H         ; 功能号
	ret             ; 

;加载程序的代码

LoadA:						 ;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
	mov ax,cs                ;段地址 ; 存放数据的内存基地址
	mov es,ax                ;设置段地址（不能直接mov es,段地址）
	mov bx, OffSetOfUserPrg1  ;偏移地址; 存放数据的内存偏移地址
	mov ah,2                 ;功能号
	mov al,1                 ;扇区数
	mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov dh,0                 ;磁头号 ; 起始编号为0
	mov ch,0                 ;柱面号 ; 起始编号为0
	mov cl,4                ;起始扇区号 ; 起始编号为1
	int 13H 				; BIOS的13h功能调用：读入指定磁盘的若干扇区到指定内存区//功能号，读取内存
	ret						;用户程序A已加载到指定内存区域中

LoadB:							;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
	mov ax,cs                ;段地址 ; 存放数据的内存基地址
	mov es,ax                ;设置段地址（不能直接mov es,段地址）
	mov bx, OffSetOfUserPrg2  ;偏移地址; 存放数据的内存偏移地址
	mov ah,2                 ;功能号
	mov al,1                 ;扇区数
	mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov dh,0                 ;磁头号 ; 起始编号为0
	mov ch,0                 ;柱面号 ; 起始编号为0
	mov cl,5                ;起始扇区号 ; 起始编号为1
	int 13H 				; BIOS的13h功能调用：读入指定磁盘的若干扇区到指定内存区//功能号，读取内存
	ret						;用户程序B已加载到指定内存区域中

LoadC:							;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
	mov ax,cs                ;段地址 ; 存放数据的内存基地址
	mov es,ax                ;设置段地址（不能直接mov es,段地址）
	mov bx, OffSetOfUserPrg3  ;偏移地址; 存放数据的内存偏移地址
	mov ah,2                 ;功能号
	mov al,1                 ;扇区数
	mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov dh,0                 ;磁头号 ; 起始编号为0
	mov ch,0                 ;柱面号 ; 起始编号为0
	mov cl,6                ;起始扇区号 ; 起始编号为1
	int 13H 				; BIOS的13h功能调用：读入指定磁盘的若干扇区到指定内存区//功能号，读取内存
	ret						;用户程序C已加载到指定内存区域中

;下面都是输出的字符
StartMsg:
	mov	ax, cs	; 置其他段寄存器值与CS相同
	mov	ds, ax	; 数据段
	mov	bp, Message		    ; BP=当前串的偏移地址
	mov	ax, ds			    ; ES:BP = 串地址
	mov	es, ax			    ; 置ES=DS
	mov	cx, MessageLength 	; CX = 串长（=9）
	mov	ax, 1300h			; AH = 13h（功能号）、AL = 01h（光标置于串尾）
	mov	bx, 0007h		    ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, 0			    ; 行号=0
	mov	dl, 0			    ; 列号=0
	int	10h				    ; BIOS的10h功能：显示一行字符
	ret

ExcuteStr:;执行中的提示信息
	mov ah,13h 	; BIOS中断的功能号（显示字符串）
	mov al,1 		; 
	mov bh,0 		; 页号=0
	mov bl,0ch 	; 字符颜色=不闪（0）黑底（000）亮红字（1100）
	mov cx,ExcuteMsgLen		;
	mov dx,0100h 		; 显示串的起始位置（0，0）：DH=行号、DL=列号
	mov bp,ExcuteMsg; ES:BP=串地址
	mov dh, 0			    ; 行号=0
	mov	dl, 0			    ; 列号=0
	int 10h 		; 调用10H号显示中断
	ret				; 从例程返回

TipDispStr1:	;显示提示符1
	mov ah,13h 	; BIOS中断的功能号（显示字符串）
	mov al,0 		; 
	mov bh,0 		; 页号=0
	mov bl,0ch 	; 字符颜色=不闪（0）黑底（000）亮红字（1100）
	mov cx,TipMsg1Len 		; 串长=16
	mov dx,0100h 		; 显示串的起始位置（0，0）：DH=行号、DL=列号
	mov bp,TipMsg1; ES:BP=串地址
	mov dh, 1			    ; 行号=0
	mov	dl, 0			    ; 列号=0
	int 10h 		; 调用10H号显示中断
	ret				; 从例程返回

TipDispStr2: ;显示提示符2
	mov ah,13h 	; BIOS中断的功能号（显示字符串）
	mov al,1 		; 光标置于行尾
	mov bh,0 		; 页号=0
	mov bl,0ch 	; 字符颜色=不闪（0）黑底（000）亮红字（1100）
	mov cx,TipMsg2Len 		; 串长=16
	mov dx,0100h 		; 显示串的起始位置（0，0）：DH=行号、DL=列号
	mov bp,TipMsg2; ES:BP=串地址
	mov dh, 2			    ; 行号=0
	mov	dl, 0			    ; 列号=0
	int 10h 		; 调用10H号显示中断
	ret				; 从例程返回

Finish:
	mov ax,cs
	mov ds,ax	
	mov	bp, Message12		    ; BP=当前串的偏移地址
	mov	ax, ds			    ; ES:BP = 串地址
	mov	es, ax			    ; 置ES=DS
	mov	cx, Message12Length ; CX = 串长（=9）
	mov	ax, 1301h			; AH = 13h（功能号）、AL = 01h（光标置于串尾）
	mov	bx, 0007h		    ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, 5			    ; 行号=0
	mov	dl, 0			    ; 列号=0
	int	10h				    ; 
	mov word[whetherToRestart],1
	jmp Restart
	ret

Message:
    db 'Hello, Here is my OS Version 1 (C)Yanzhi Cai, 2014'
MessageLength  equ ($-Message)

Message12:
	db 'Hello, MyOs is finish excute user programs!!!type y to restart:'
Message12Length equ ($-Message12)

ExcuteMsg:
	db 'Excuting '
ExcuteMsgLen equ ($-ExcuteMsg)

TipMsg1:
	db 'we have three programs,you can run them in order as you want,such as abc or ca'
TipMsg1Len equ ($-TipMsg1)

TipMsg2:
	db 'input the order(no space, could not stand mistake): '
TipMsg2Len equ ($-TipMsg2)

InitData: ;初始化数据
	mov ax,0
	mov word[a],ax
	mov word[b],ax
	mov word[c],ax
	mov word[num],ax
	mov word[index],ax
	mov word[whetherToRestart],ax
	ret

Data: ;数据区
a dw 0
b dw 0
c dw 0
index dw 0
num dw 0 ;a, b, c为用户键入的第一二三个字符,num为总共的字符数
whetherToRestart dw 0
OffSetOfUserPrg1 equ 8100h
OffSetOfUserPrg2 equ 8300h
OffSetOfUserPrg3 equ 8500h
times 1024-($-$$) db 0 ; 用0填充剩余部分
					   ; （$=当前地址、$$=当前节地址）

