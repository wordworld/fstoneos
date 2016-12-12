;;************************************************************
;; @brief	简单引导例子
;; 
;; 
;; @file	d001_simple_boot.asm
;; @author	fstone.zh@foxmail.com
;; @date	2016-12-12
;; @version	0.1.0
;;************************************************************

	; 使 ds es 都指向代码段 (即cs的值)
	mov	ax, cs	; 获取  代码段 基址
	mov	ds, ax	; 代码段 用作 数据段
	mov	es, ax	; 代码段 用作 扩展段 

	; 跳到光标当前位置
	call	GotoCursor
	; 显示启动信息字符串
	;	ES:BP = 串地址
	mov	cx, bootmsg
	mov	bp, cx
	; 	CX = 串长度
	mov	cx, [msglen]
	;	调用显示过程
	call	DispStr	

	; 进入死循环
	jmp	$

	; 包含显示相关过程定义
	%include	"io.asm"

; 启动信息
bootmsg:db	"Hello, I'm an os booting program!"
msglen:	db	$ - bootmsg

	; 以0填充 [ 510-已使用内存字节数 ] 个字节， 此后的内存地址为 511,512
	times	510 - ($-$$)	db	0
	; magic number, 引导标志
	dw 	0xaa55
