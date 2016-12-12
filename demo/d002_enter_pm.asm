;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @brief	进入保护模式
;; 
;; 
;; @file	d002_enter_pm.asm
;; @author	fstone.zh@foxmail.com
;; @date	2016-12-12
;; @version	0.1.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; 使 ds es 都指向代码段 (即cs的值)
%include "descriptor.s"
	jmp	LABEL_BEGIN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GDT 数据段
[SECTION .gdt]

; 全局描述符表 GDT,GlobalDescriptorTable 段基址, 段界限,	段属性
; 	0 空描述符
LABEL_GDT:		STRUCT_DESCRIPTOR 0,	0,		0
; 	1 非一致32位代码段
LABEL_DESC_CODE32:	STRUCT_DESCRIPTOR 0,	SegCode32Len-1,	DESC_P|DESC_S|DESC_EXECUTABLE|DESC_DB
; 	2 显存数据段
LABEL_DESC_VIDEO:	STRUCT_DESCRIPTOR 0B8000h, 0ffffh,	DESC_P|DESC_S|DESC_WRITE

	GdtLen	equ	$ - LABEL_GDT	; GDT 长度
gdtr_data:	dw	GdtLen - 1	; GDT 界限
		dd	0		; GDT 基址

; GDT 选择子
SELECTOR( SelectorCode32,	1, SELECTOR_GDT | SELECTOR_RPL_0 )	; 32位代码段
SELECTOR( SelectorVideo,	2, SELECTOR_GDT | SELECTOR_RPL_0 )	; 显存数据段

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 16 位代码段 (CPU工作于实模式)
[SECTION .s16]
[BITS	16]

LABEL_BEGIN:
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, 0100h

	; 初始化 32 位代码段描述符
	; 获取 GDT 基址 base (段:偏移)
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4			; base = cs(low28b) : 0000b
	add	eax, LABEL_SEG_CODE32	; 	+ offset
	; [DESC+2] base1-low16	= base[ 0, 15]
	mov	word [LABEL_DESC_CODE32 + 2], ax
	; [DESC+4] base1-hig8	= base[16, 23]
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE32 + 4], al
	; [DESC+7] bae2		= base[24, 31]
	mov	byte [LABEL_DESC_CODE32 + 7], ah

; 寄存器 gdtr 结构
;┌─────────┬─────────┬─────────┬─────────┬─────────┬─────────┐
;│0        │1        │2        │3        │4        │5        │ 
;├─────────┴─────────┼─────────┴─────────┴─────────┴─────────┤
;│      GDT 界限     │                GDT 基址               │
;└───────────────────┴───────────────────────────────────────┘
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4				; gdtbase = ds << 4
	add	eax, LABEL_GDT			;           + GDT_offset
	mov	dword [gdtr_data + 2], eax	; gdtr[2] = gdtbase
	lgdt	[gdtr_data]			; 加载 gdtr_data 到 gdtr寄存器

	; 关中断
	cli
	; 打开地址线 A20
	in	al, 92h
	or	al, 00000010b
	out	92h, al
	
; 寄存器 cr0 结构
;┌────┬────┬────┬────┬────┬────┬─────────┬────┬────┬────┬─────────┬────┬────┬────┐
;│0   │1   │2   │3   │4   │5   │6  ... 15│16  │17  │18  │19 ... 28│29  │30  │31  │ 
;├────┼────┼────┼────┼────┼────┼─────────┼────┼────┼────┼─────────┼────┼────┼────┤
;│ PE │ MP │ EM │ TS │ ET │ NE │    -    │ WP │ -  │ AM │    -    │ NW │ CD │ PG │
;└────┴────┴────┴────┴────┴────┴─────────┴────┴────┴────┴─────────┴────┴────┴────┘
; PE位：0,实模式；1,保护模式

	; 准备切换到保护模式
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax

	; 真正进入保护模式
	jmp	dword SelectorCode32:0	; 执行这一句会把 SelectorCode32 装入 cs,
					; 并跳转到 Code32Selector:0  处

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 32 位代码段 (由实模式跳入)
; 保护模式下，分段式内存管理 “段号:偏移” 中的段号将被 选择子 代替
[SECTION .s32]
[BITS	32]

LABEL_SEG_CODE32:
	mov	ax, SelectorVideo
	mov	gs, ax			; 加载 显存数据段选择子 到 gs

	mov	edi, (80 * 11 + 79) * 2	; 屏幕第 11 行, 第 79 列。
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, 'P'
	mov	[gs:edi], ax

	; 到此停止
	jmp	$

SegCode32Len	equ	$ - LABEL_SEG_CODE32

