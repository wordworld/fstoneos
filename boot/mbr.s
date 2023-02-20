// ***********************************************************
// @brief	主引导记录(Master Boot Record)程序
// 
// 
// @file	mbr.s
// @author	fstone.zh@foxmail.com
// @date	2023-02-19
// @version	0.1.0
//************************************************************
.code16
.global main
main:
	// 初始化寄存器 ds=cs,es=cs
	mov  %cs,   %ax
	mov  %ax,   %ds
	mov  %ax,   %es
	// puts(str, len, 20, 8)
	mov  $str,  %bp
	mov  $len,  %cx
	mov  $0x14, %dh # 行号 +20
	mov  $0x08, %dl # 缩进 +8 字符
	call puts
	// while(true);
	jmp  .

// void puts(void *str, int len, int row, int col)
//  @str <- %bp
//  @len <- %cx
//  @row <- %dh
//  @col <- %dl
puts:
	mov  $0x1301, %ax # 文字属性
	mov  $0xc,    %bx # 颜色
	int  $0x10        # 调用 0x10 中断
	ret

str:
	.ascii "Hello Lubanix"
	len = . - str     # str长度 = 当前地址 - str首地址

// 引导扇区结束标志 0xaa55
.org 510
magic:
	.byte 0x55, 0xaa
