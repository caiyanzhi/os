; ����Դ���루stone.asm��
; By Ling Yingbiao 2013/12/28 
; ����bugs  ���޸�ǡ�õ����ĸ�����֮����Ļ��ʧȥС���bugs by ����֥ 2014��4��1��
; ���������ı���ʽ��ʾ���ϴ�������һ��*��,��45���������˶���ײ���߿����,�������.
Dn_Rt equ 1                  ;D-Down,U-Up,R-right,L-Left
Up_Rt equ 2                  ;��_Rt����Ϊ1,2,3,4
Up_Lt equ 3                  ;
Dn_Lt equ 4                  ; 
delay equ 10000					; ��ʱ���ӳټ���,���ڿ��ƻ�����ٶ�
ddelay equ 1000					; ��ʱ���ӳټ���,���ڿ��ƻ�����ٶ�

org 7e00h					; ������ص�100h������������COM
start:
	;xor ax,ax					; AX = 0   ������ص�0000��100h������ȷִ��
	; ����ʱ���ж�������08h������ʼ���μĴ���
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
	mov	bp, Message ; BP=��ǰ����ƫ�Ƶ�ַ
	mov	ax, ds			    ; ES:BP = ����ַ
	mov	es, ax			    ; ��ES=DS 
	mov	 cx, MessageLength        	; CX = ������=10��
	mov	 ax, 1301h	 
	; AH = 13h�����ܺţ���AL = 01h��������ڴ�β��
	mov	 bx, 0007h
	; ҳ��Ϊ0(BH = 0) �ڵװ���(BL = 07h)
	mov  dh, 0	; �к�=10
	mov	 dl, 0		; �к�=10
	int	10h		; BIOS��10h���ܣ���ʾһ���ַ�
	
	xor ax,ax						; AX = 0
	mov es,ax					; ES = 0
	mov ax, word[es:24h]
	push ax
	mov word[es:24h],OUCHOUCH	; ���ü����ж�������ƫ�Ƶ�ַ,�û������� ����С����ʾOUCH��
	mov ax, [es:26h]
	push ax
	mov ax,cs 
	mov [es:26h],ax				; ���ü����ж������Ķε�ַ=CS
	
	xor ax,ax						; AX = 0
	mov es,ax					; ES = 0
	mov ax, word[es:20h]
	push ax
	mov word[es:20h],AnotherShow		; ����ʱ���ж�������ƫ�Ƶ�ַ,��ʾ����С����˶��
	mov ax, [es:22h]
	push ax
	mov ax,cs 
	mov [es:22h],ax				; ����ʱ���ж������Ķε�ַ=CS

	mov ds,ax					; DS = CS
	mov es,ax					; ES = CS

	mov	ax,0B800h				; �ı������Դ���ʼ��ַ
	mov	gs,ax					; GS = B800h
    mov byte[char],'A'
	mov byte[char@],'B'
	mov word[Flag], 0
loopp1:
	cmp word[Flag], 1
	je Exit
	jmp loopp1

;�����жϳ���
OUCHOUCH:
	call showOUCH				;��ʾouch
	in al , 0x60 				;����ȡ�����ж��޷��ٴ���Ӧ
	cmp al, 1
	je setFlag
endd:							;���жϷ���
	mov al,20h					; AL = EOI
	out 20h,al						; ����EOI����8529A
	out 0A0h,al					; ����EOI����8529A
	iret							; ���жϷ���
	
setFlag:
	mov word[Flag], 1
	jmp endd
		
;	ʱ���жϳ���
AnotherShow:
	dec byte[counttime]				; �ݼ���������
	jnz endd						; >0����ת
	mov byte[counttime],delaytime			; ���ü�������=��ֵdelay
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
    xor ax,ax                 ; �����Դ��ַ
    mov ax,word[x@]
	mov bx,80
	mul bx
	add ax,word[y@]
	mov bx,2
	mul bx
	mov bp,ax
	mov ah,0Fh				;  0000���ڵס�1111�������֣�Ĭ��ֵΪ07h��
	mov al,byte[char@]			;  AL = ��ʾ�ַ�ֵ��Ĭ��ֵΪ20h=�ո����
	mov word[gs:bp],ax  		;  ��ʾ�ַ���ASCII��ֵ
	loop22@:
	dec word[count@]				; �ݼ���������
	jnz loop22@					; >0����ת;
	mov word[count@],delay
	dec word[dcount@]				; �ݼ���������
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
    xor ax,ax                 ; �����Դ��ַ
    mov ax,word[x]
	mov bx,80
	mul bx
	add ax,word[y]
	mov bx,2
	mul bx
	mov bp,ax
	mov ah,0Fh				;  0000���ڵס�1111�������֣�Ĭ��ֵΪ07h��
	mov al,byte[char]			;  AL = ��ʾ�ַ�ֵ��Ĭ��ֵΪ20h=�ո����
	mov word[gs:bp],ax  		;  ��ʾ�ַ���ASCII��ֵ
loop22:
	dec word[count]				; �ݼ���������
	jnz loop22					; >0����ת;
	mov word[count],delay
	dec word[dcount]				; �ݼ���������
    jnz loop22
	mov word[count],delay
	mov word[dcount],ddelay
	mov al, ' '
	mov word[gs:bp],ax
	ret

;��ʾouch��
showOUCH:
;��ʾС��A��ouch
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
;��ʾС��B��ouch
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
;��ʱ������Ȼ����ող���ʾ��ouch��
loop2:
	dec word[count]				; �ݼ���������
	jnz loop2					; >0����ת;
	mov word[count],delay
	dec word[dcount]				; �ݼ���������
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
    rdul db Dn_Rt         ; �������˶�
    x dw 2
	y dw -1
	char db 'A'
	count@ dw delay
	dcount@ dw ddelay
    rdul@ db Dn_Lt         ; �������˶�
    x@ dw 0
	y@ dw 80
	char@ db 'B'
	delaytime equ 3					; ��ʱ���ӳټ���
	counttime db delaytime					; ��ʱ��������������ֵ=delay
	Message db 'Here is the stone.asm, you can input Esc to exit...'
	MessageLength equ ($-Message)
	Flag dw 0
