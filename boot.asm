;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @brief	引导程序
;; 
;; 
;; @file	boot.asm
;; @author	fstone.zh@foxmail.com
;; @date	2016-12-07
;; @version	0.1.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%ifdef		BOOT_FROM_CD
	org	0000h		; 光盘启动, 代码加载到 0x0000
%elifdef	BOOT_FROM_FD
	org	7c00h		; 软盘启动, 代码加载到 0x7c00
%endif
	; 使 ds es 都指向代码段 (即cs的值)
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	; 设置输出位置
%ifdef		BOOT_FROM_CD
	call	GotoCursor	; 跳到光标位置
%elifdef	BOOT_FROM_FD
	call	Clrscr		; 清屏 
%endif
	; 显示串后进入死循环
	call	DispStr		; 显示字符串
	jmp	$		; while( 1 );
	;hlt

; 跳转到当前光标位置
GotoCursor:
	; 中断服务程序(Interrupt Service Routine, ISR) ( INT 10h ) AH = 3 : 读光标位置到 DH(行),DL(列)
	mov	ah, 3
	; 调用 ISR( INT 10H )
	int	10h
	ret

; 清屏
Clrscr:
	; ISR( INT 10H ) AH = 0 : 设定显示模式
	;	AL=3 : 字符模式, 80列*25行, 16位颜色
	mov	ax, 0003h
	int	10h
	ret

; 显示字符串(输出位置由 DH(行),DL(列) 提供)
DispStr:
	; ISR( int 10h ) AH = 13h : 显示字符串
	; 	AL = 1 : BL表示属性
	mov	ax, 1301h

	;	BL = 6 (0110b) : 棕色. BH = 页号
	mov	bx, 0006h

	;	ES:BP = 串地址
	mov	cx, BootMessage
	mov	bp, cx

	;	CX = 串长度
	mov	cx, [strlen]


	int	10h
	ret

BootMessage:		db	"Hello, I'm fstoneos-1.0!"
strlen:			db	$-BootMessage
times 	510-($-$$)	db	0	; 定义 [ 510-已使用内存字节数 ] 个字节0， 此后的内存地址为 511,512
dw 	0xaa55				; magic number, 引导标志
