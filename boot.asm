	; 将代码加载到合适的内存位置
%ifdef		BOOT_FROM_CD
	org	0000h
%elifdef	BOOT_FROM_FD
	org	7c00h
%endif
	; 使 ds es 都指向代码段 (即cs的值)
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	; 光标跳到输出位置
	call	GotoCursor
	; 调用显示字符串例程
	call	DispStr
	; 无限循环
	jmp	$

GotoCursor:
	mov	ah, 03h
	int	10h
	ret

DispStr:
	; ES:BP = 串地址
	mov	ax, BootMessage
	mov	bp, ax
	; CX = 串长度
	mov	cx, [strlen]
	; AH = 13,  AL = 01h
	mov	ax, 1301h
	; 页号为0(BH = 0) 黑底红字(BL = 0Ch,高亮)
	mov	bx, 000ch
	mov	dl, 0
	; 10h 号中断
	int	10h
	ret

BootMessage:		db	"Hello, I'm fstoneos-1.0!"
strlen:			db	$-BootMessage
times 	510-($-$$)	db	0	; 填充剩下的空间，使生成的二进制代码恰好为512字节
dw 	0xaa55				; magic number, 引导标志
