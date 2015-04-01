; ³ÌÐòÔ´´úÂë£¨stone.asm£©
; By Ling Yingbiao 2013/12/28 
; »¹ÓÐbugs  ÒÑÐÞ¸´Ç¡ºÃµ½´ïËÄ¸ö½ÇÂäÖ®ºóÆÁÄ»ÉÏÊ§È¥Ð¡ÇòµÄbugs by ²ÌÑàÖ¥ 2014Äê4ÔÂ1ÈÕ
; ±¾³ÌÐòÔÚÎÄ±¾·½Ê½ÏÔÊ¾Æ÷ÉÏ´Ó×ó±ßÉä³öÒ»¸ö*ºÅ,ÒÔ45¶ÈÏòÓÒÏÂÔË¶¯£¬×²µ½±ß¿òºó·´Éä,Èç´ËÀàÍÆ.
Dn_Rt equ 1                  ;D-Down,U-Up,R-right,L-Left
Up_Rt equ 2                  ;°Ñ_Rt¶¨ÒåÎª1,2,3,4
Up_Lt equ 3                  ;
Dn_Lt equ 4                  ; 
delay equ 10000					; ¼ÆÊ±Æ÷ÑÓ³Ù¼ÆÊý,ÓÃÓÚ¿ØÖÆ»­¿òµÄËÙ¶È
ddelay equ 1000					; ¼ÆÊ±Æ÷ÑÓ³Ù¼ÆÊý,ÓÃÓÚ¿ØÖÆ»­¿òµÄËÙ¶È

org 7e00h					; ³ÌÐò¼ÓÔØµ½100h£¬¿ÉÓÃÓÚÉú³ÉCOM
start:
	;xor ax,ax					; AX = 0   ³ÌÐò¼ÓÔØµ½0000£º100h²ÅÄÜÕýÈ·Ö´ÐÐ
	; ÉèÖÃÊ±ÖÓÖÐ¶ÏÏòÁ¿£¨08h£©£¬³õÊ¼»¯¶Î¼Ä´æÆ÷
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
	mov	bp, Message ; BP=µ±Ç°´®µÄÆ«ÒÆµØÖ·
	mov	ax, ds			    ; ES:BP = ´®µØÖ·
	mov	es, ax			    ; ÖÃES=DS 
	mov	 cx, MessageLength        	; CX = ´®³¤£¨=10£©
	mov	 ax, 1301h	 
	; AH = 13h£¨¹¦ÄÜºÅ£©¡¢AL = 01h£¨¹â±êÖÃÓÚ´®Î²£©
	mov	 bx, 0007h
	; Ò³ºÅÎª0(BH = 0) ºÚµ×°××Ö(BL = 07h)
	mov  dh, 0	; ÐÐºÅ=10
	mov	 dl, 0		; ÁÐºÅ=10
	int	10h		; BIOSµÄ10h¹¦ÄÜ£ºÏÔÊ¾Ò»ÐÐ×Ö·û
	
	xor ax,ax						; AX = 0
	mov es,ax					; ES = 0
	mov ax, word[es:24h]
	push ax
	mov word[es:24h],OUCHOUCH	; ÉèÖÃ¼üÅÌÖÐ¶ÏÏòÁ¿µÄÆ«ÒÆµØÖ·,ÇÃ»÷¼üÅÌÔò Á½¸öÐ¡ÇòÏÔÊ¾OUCH£¡
	mov ax, [es:26h]
	push ax
	mov ax,cs 
	mov [es:26h],ax				; ÉèÖÃ¼üÅÌÖÐ¶ÏÏòÁ¿µÄ¶ÎµØÖ·=CS
	
	xor ax,ax						; AX = 0
	mov es,ax					; ES = 0
	mov ax, word[es:20h]
	push ax
	mov word[es:20h],AnotherShow		; ÉèÖÃÊ±ÖÓÖÐ¶ÏÏòÁ¿µÄÆ«ÒÆµØÖ·,ÏÔÊ¾Á½¸öÐ¡ÇòµÄÔË¶¯£
	mov ax, [es:22h]
	push ax
	mov ax,cs 
	mov [es:22h],ax				; ÉèÖÃÊ±ÖÓÖÐ¶ÏÏòÁ¿µÄ¶ÎµØÖ·=CS

	mov ds,ax					; DS = CS
	mov es,ax					; ES = CS

	mov	ax,0B800h				; ÎÄ±¾´°¿ÚÏÔ´æÆðÊ¼µØÖ·
	mov	gs,ax					; GS = B800h
    mov byte[char],'A'
	mov byte[char@],'B'
	mov word[Flag], 0
loopp1:
	cmp word[Flag], 1
	je Exit
	jmp loopp1

;¼üÅÌÖÐ¶Ï³ÌÐò
OUCHOUCH:
	call showOUCH				;ÏÔÊ¾ouch
	in al , 0x60 				;²»¶ÁÈ¡¼üÅÌÖÐ¶ÏÎÞ·¨ÔÙ´ÎÏìÓ¦
	cmp al, 1
	je setFlag
endd:							;´ÓÖÐ¶Ï·µ»Ø
	mov al,20h					; AL = EOI
	out 20h,al						; ·¢ËÍEOIµ½Ö÷8529A
	out 0A0h,al					; ·¢ËÍEOIµ½´Ó8529A
	iret							; ´ÓÖÐ¶Ï·µ»Ø
	
setFlag:
	mov word[Flag], 1
	jmp endd
		
;	Ê±ÖÓÖÐ¶Ï³ÌÐò
AnotherShow:
	dec byte[counttime]				; µÝ¼õ¼ÆÊý±äÁ¿
	jnz endd						; >0£ºÌø×ª
	mov byte[counttime],delaytime			; ÖØÖÃ¼ÆÊý±äÁ¿=³õÖµdelay
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
    xor ax,ax                 ; ¼ÆËãÏÔ´æµØÖ·
    mov ax,word[x@]
	mov bx,80
	mul bx
	add ax,word[y@]
	mov bx,2
	mul bx
	mov bp,ax
	mov ah,0Fh				;  0000£ººÚµ×¡¢1111£ºÁÁ°××Ö£¨Ä¬ÈÏÖµÎª07h£©
	mov al,byte[char@]			;  AL = ÏÔÊ¾×Ö·ûÖµ£¨Ä¬ÈÏÖµÎª20h=¿Õ¸ñ·û£©
	mov word[gs:bp],ax  		;  ÏÔÊ¾×Ö·ûµÄASCIIÂëÖµ
	loop22@:
	dec word[count@]				; µÝ¼õ¼ÆÊý±äÁ¿
	jnz loop22@					; >0£ºÌø×ª;
	mov word[count@],delay
	dec word[dcount@]				; µÝ¼õ¼ÆÊý±äÁ¿
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
    xor ax,ax                 ; ¼ÆËãÏÔ´æµØÖ·
    mov ax,word[x]
	mov bx,80
	mul bx
	add ax,word[y]
	mov bx,2
	mul bx
	mov bp,ax
	mov ah,0Fh				;  0000£ººÚµ×¡¢1111£ºÁÁ°××Ö£¨Ä¬ÈÏÖµÎª07h£©
	mov al,byte[char]			;  AL = ÏÔÊ¾×Ö·ûÖµ£¨Ä¬ÈÏÖµÎª20h=¿Õ¸ñ·û£©
	mov word[gs:bp],ax  		;  ÏÔÊ¾×Ö·ûµÄASCIIÂëÖµ
loop22:
	dec word[count]				; µÝ¼õ¼ÆÊý±äÁ¿
	jnz loop22					; >0£ºÌø×ª;
	mov word[count],delay
	dec word[dcount]				; µÝ¼õ¼ÆÊý±äÁ¿
    jnz loop22
	mov word[count],delay
	mov word[dcount],ddelay
	mov al, ' '
	mov word[gs:bp],ax
	ret

;ÏÔÊ¾ouch£¡
showOUCH:
;ÏÔÊ¾Ð¡ÇòAµÄouch
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
;ÏÔÊ¾Ð¡ÇòBµÄouch
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
;ÑÓÊ±²Ù×÷£¬È»ºóÇå¿Õ¸Õ²ÅÏÔÊ¾µÄouch£¡
loop2:
	dec word[count]				; µÝ¼õ¼ÆÊý±äÁ¿
	jnz loop2					; >0£ºÌø×ª;
	mov word[count],delay
	dec word[dcount]				; µÝ¼õ¼ÆÊý±äÁ¿
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
    rdul db Dn_Rt         ; ÏòÓÒÏÂÔË¶¯
    x dw 2
	y dw -1
	char db 'A'
	count@ dw delay
	dcount@ dw ddelay
    rdul@ db Dn_Lt         ; Ïò×óÏÂÔË¶¯
    x@ dw 0
	y@ dw 80
	char@ db 'B'
	delaytime equ 3					; ¼ÆÊ±Æ÷ÑÓ³Ù¼ÆÊý
	counttime db delaytime					; ¼ÆÊ±Æ÷¼ÆÊý±äÁ¿£¬³õÖµ=delay
	Message db 'Here is the stone.asm, you can input Esc to exit...'
	MessageLength equ ($-Message)
	Flag dw 0
