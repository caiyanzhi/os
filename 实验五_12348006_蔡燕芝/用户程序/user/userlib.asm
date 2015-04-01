
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;                              userlib.asm
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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
;*  void _myShowOuch()                   *
;**************** *******************
; 

public _myShowOuch
_myShowOuch proc
	push ax
	mov ah, 0
	int 33
	pop ax
	ret
_myShowOuch endp

;*************** ********************
;*  void _myUpper(char *pChars)                 *
;**************** *******************
; 

public _myUpper
_myUpper proc
push bp
mov bp,sp
	push dx
	push ax
	mov ax, ds
	mov es, ax
	mov dx, [bp+4]
	mov ah, 1
	int 33
	pop ax
	pop dx
pop bp
ret
_myUpper endp

;*************** ********************
;*  void _myLowwer(char *pChars)               *
;**************** *******************
; 

public _myLowwer
_myLowwer proc
push bp
mov bp,sp
	push ax
	push dx
	mov ax, ds
	mov es, ax
	mov ah, 2
	mov dx, [bp+4]
	int 33
	pop dx
	pop ax
pop bp
ret
_myLowwer endp

;*************** ********************
;*  int _myChars2Int(char *pChars)                   *
;**************** *******************
; 

public _myChars2Int
_myChars2Int proc
push bp
mov bp,sp
	push dx
	mov ax, ds
	mov es, ax
	mov ah, 3
	mov dx, [bp+4]
	int 33
	pop dx
pop bp
ret
_myChars2Int endp

;*************** ********************
;*  void _myInt2Chars(int num, char *pChars)                   *
;**************** *******************
; 

public _myInt2Chars
_myInt2Chars proc
push bp
mov bp,sp
	push dx
	push bx
	push ax
	mov ax, ds
	mov es, ax
	mov ah, 4
	mov bx, [bp+4]
	mov dx, [bp+6]
	int 33
	pop ax
	pop bx
	pop dx
pop bp
ret
_myInt2Chars endp

;*************** ********************
;*  void myPrintCharsInPosition(int row,int col, char *pChars)        *
;**************** *******************
; 

public _myPrintCharsInPosition
_myPrintCharsInPosition proc
push bp
mov bp,sp
	push ax
	push dx
	push cx
	mov ax, ds
	mov es, ax
	mov ah, 5
	mov ch, [bp+4]
	mov cl, [bp+6]
	mov dx, [bp+8]
	int 33
	pop cx
	pop dx
	pop ax
pop bp
ret
_myPrintCharsInPosition endp

;*************** ********************
;*  char myGetChar()               *
;**************** *******************
; 

public _myGetChar
_myGetChar proc
push bp
	mov ah, 7
	int 33
pop bp
ret
_myGetChar endp

;*************** ********************
;*  int myGetChars(char *pChars)               *
;**************** *******************
; 

public _myGetChars
_myGetChars proc
push bp
mov bp,sp
	push dx
	mov ax, ds
	mov es, ax
	mov dx, [bp+4]
	mov ah, 6
	int 33
	pop dx
pop bp
ret
_myGetChars endp

;*************** ********************
;* void myShowTime()               *
;**************** *******************
; 

public _myShowTime
_myShowTime proc
push bp
mov bp,sp
	push ax
	mov ah, 8
	int 33
	pop ax
pop bp
ret
_myShowTime endp

;*************** ********************
;* void myprintf()             *
;**************** *******************
; 

public _myprintf
_myprintf proc
push bp
mov bp,sp
	push ax
	push dx
	mov ax, ds
	mov es, ax
	mov ah, 9
	mov dx, [bp+4]
	int 33
	pop dx
	pop ax
pop bp
	ret
_myprintf endp