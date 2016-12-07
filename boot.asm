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
	call	GotoCursor	; 跳到光标位置
	; 显示串后进入死循环
	call	DispStr		; 显示字符串
	jmp	$		; while( 1 );

%include	"io.asm"

BootMessage:		db	"Hello, I'm fstoneos-1.0!"
strlen:			db	$-BootMessage
times 	510-($-$$)	db	0	; 以0填充 [ 510-已使用内存字节数 ] 个字节， 此后的内存地址为 511,512
dw 	0xaa55				; magic number, 引导标志
