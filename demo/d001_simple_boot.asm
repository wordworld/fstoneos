;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @brief	简单引导例子
;; 
;; 
;; @file	d001_simple_boot.asm
;; @author	fstone.zh@foxmail.com
;; @date	2016-12-07
;; @version	0.1.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; 使 ds es 都指向代码段 (即cs的值)
	mov	ax, cs
	mov	ds, ax
	mov	es, ax

	; 设置输出位置
	call	GotoCursor	; 跳到光标位置

	; 显示字符串后进入死循环
	;	ES:BP = 串地址
	mov	cx, BootMessage
	mov	bp, cx
	;	CX = 串长度
	mov	cx, [msglen]
	call	DispStr		; 显示字符串
	jmp	$		; while( 1 );

	; 包含显示相关函数定义
	%include	"io.asm"

; 数据
BootMessage:
	db	"Hello, I'm fstoneos-1.0!"
msglen:
	db	$-BootMessage

	; 以0填充 [ 510-已使用内存字节数 ] 个字节， 此后的内存地址为 511,512
	times 	510-($-$$)	db	0
	; magic number, 引导标志
	dw 	0xaa55
