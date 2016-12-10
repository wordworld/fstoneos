;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @brief	进入保护模式
;; 
;; 
;; @file	d002_enter_pm.asm
;; @author	fstone.zh@foxmail.com
;; @date	2016-12-08
;; @version	0.1.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; 使 ds es 都指向代码段 (即cs的值)
%include "descriptor.s"
	jmp	LABEL_BEGIN
[SECTION .gdt]
; 全局描述符表 (Global Descriptor Table,GDT) 段基址, 段界限, 属性
LABEL_GDT: 		; [0] 空描述符
	STRUCT_DESCRIPTOR 0,	0,		0
LABEL_DESC_CODE32:	; [1] 非一致代码段
	STRUCT_DESCRIPTOR 0,	SegCode32Len-1,	DESC_P|DESC_S|DESC_EXECUTABLE | DESC_DB
LABEL_DESC_VIDEO:	; [2] 显存
	STRUCT_DESCRIPTOR 0B8000h, 0ffffh,	DESC_P|DESC_S|DESC_WRITE

	GdtLen	equ	$ - LABEL_GDT	; GDT长度
GdtLoader:
		dw	GdtLen - 1	; GDT界限
		dd	0		; GDT基地址

; GDT 选择子
SELECTOR( SelectorCode32,1, SELECTOR_GDT | SELECTOR_RPL_0 )
SELECTOR( SelectorVideo, 2, SELECTOR_GDT | SELECTOR_RPL_0 )

; END of [SECTION .gdt]
[SECTION .s16]
[BITS	16]
LABEL_BEGIN:
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, 0100h

	; 初始化 32 位代码段描述符
	; eax = cs(28b) : offset (4b)
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_SEG_CODE32
	; base1-low16 = cs-low12 : offset(4)
	mov	word [LABEL_DESC_CODE32 + 2], ax
	shr	eax, 16
	; base1-hig8 = cs-13,20
	mov	byte [LABEL_DESC_CODE32 + 4], al
	; base2 = cs-21,28
	mov	byte [LABEL_DESC_CODE32 + 7], ah

	; 为加载 GDTR 作准备
	; eax = ds(28b) : GTD offset(4b)
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_GDT		; eax <- gdt 基地址
	; 保存 ds:offset 形式的 GDT 基地址
	mov	dword [GdtLoader+2], eax; [GdtLoader + 2] <- gdt 基地址

	; 加载 GDTR
	; TODO
	lgdt	[GdtLoader]

	; 关中断
	cli

	; 打开地址线A20
	in	al, 92h
	or	al, 00000010b
	out	92h, al

	; 准备切换到保护模式
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax

	; 真正进入保护模式
	jmp	dword SelectorCode32:0	; 执行这一句会把 SelectorCode32 装入 cs,
					; 并跳转到 Code32Selector:0  处
; END of [SECTION .s16]


[SECTION .s32]; 32 位代码段. 由实模式跳入.
[BITS	32]

LABEL_SEG_CODE32:
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子(目的)

	mov	edi, (80 * 11 + 79) * 2	; 屏幕第 11 行, 第 79 列。
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, 'P'
	mov	[gs:edi], ax

	; 到此停止
	jmp	$

SegCode32Len	equ	$ - LABEL_SEG_CODE32
; END of [SECTION .s32]

