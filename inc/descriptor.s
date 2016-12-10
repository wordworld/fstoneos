;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @brief	描述符相关结构
;; 
;; 
;; @file	descriptor.s
;; @author	fstone.zh@foxmail.com
;; @date	2016-12-09
;; @version	0.1.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%ifndef __DESCRIPTOR_S__
%define __DESCRIPTOR_S__


; 描述符结构 ( 8 字节 )
; ┌─────────┬─────────┬─────────┬─────────┬─────────┬─────────┬─────────┬─────────┐
; │0        │1        │2        │3        │4        │5        │6        │7        │
; ├─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
; │0   |4   │8   |12  │16  |20  │24  |28  │32  |36  │40  |44  │48  |52  │56  |60  │
; ├─────────┴─────────┼─────────┴─────────┴─────────┼─────────┼─────────┼─────────┤
; │        lmt1       │            base1            │   att1  │lmt2|att2│  base2  │
; └───────────────────┴─────────────────────────────┴─────────┴─────────┴─────────┘
;                                                   /                   \
;  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─                     ─ ─ ─ ─ ─ 
; /                                                                               \
; ┌───────────────────┬────┬─────────┬────┬───────────────────┬────┬────┬────┬────┐
; │40   41   42   43  │44  │45   46  │47  │48   49   50   51  │52  │53  │54  │55  │
; ├───────────────────┼────┼─────────┼────┼───────────────────┼────┼────┼────┼────┤
; │        type       │  S │   DPL   │  P │       lmt2        │ AVL│    │ D/B│  G │
; └───────────────────┴────┴─────────┴────┴───────────────────┴────┴────┴────┴────┘
; │                   │    │特权级0~3│段在│                   │保留│    │    │0/1 │
; │                   └┐   └─────────┴────┤                   └────┘    │    │B/4k│
; │                    │   0    /   1     │    ┌────────────────────────┘    └────┤
; │                    │ 系统段 / 代码段  │    │ [可执行] [代码段]                │
; │                    │   门   / 数据段  │    │      D addr operand              │
; │                    └──────────────────┤    │      1 32b  32/8b                │
; │                                       │    │      0 16b  16/8b                │
; ├─────────┬─────────┬─────────┬─────────┤    │ [向下扩展] [数据段]              │
; │   40    │    41   │   42    │   43    │    │  段上界  = (B==1) ? 4G : 64k     │
; ├─────────┼─────────┼─────────┼─────────┤    │ [描述堆栈段] push pop call 时,   │
; │  已访问 │   可写  │ 向下扩展│执行/一致│    │  堆栈指针寄存器 = (B==1) ? ESP:SP│
; └─────────┴─────────┴─────────┴─────────┘    └──────────────────────────────────┘

; 描述符
; usage: Descriptor Base, Limit, Attr
; @param 1	段基址(segment base address)	4B	xxxx xxxx
; @param 2	段界限(segment limit)		2.5B	  xx xxxx
; @param 3	段属性(segment attribute)	2B	     x0xx
%macro Descriptor 3
	dw   0FFFFh & (%2)			; lmt1 ( 0-15,2B)
	dd 0FFFFFFh & (%1)     | (%3)<<24	; base1(16-39,3B) | attr1(40-47,1B)
	db      0Fh & (%2)>>16 | (%3)>>8 & 0F0h	; lmt2 (48-51,4b) | attr2(52-55,4b)
	db     0FFh & (%1)>>24			; base2(56-63,1B)
%endmacro 
; 位运算优先级(降序) [<<][>>] [&] [^] [|]

; 属性attr2 (高4位)
DESC_G		EQU	8000H	; 粒度
DESC_DB		EQU	4000H	; D/B
;DESC_0		EQU	2000H
DESC_AVL	EQU	1000H	; AVL

; 属性attr1 (低8位)
DESC_P		EQU	0080H	; P位(Present): 1,段在内存; 0,段不在内存
DESC_DPL_3	EQU	0060H	; 描述符特权级 Descriptor Privilege Level,DPL-3
DESC_DPL_2	EQU	0040H	; DPL-2
DESC_DPL_1	EQU	0020H	; DPL-1
DESC_DPL_0	EQU	0000H	; DPL-0
DESC_S		EQU	0010H	; S位: 1,代码-数据段; 0,系统段-门
; type
DESC_EXECUTABLE	EQU	0008H	; 1000b 可执行
DESC_EXPAND_DOWN EQU	0004H	; 0100b 向下扩充
DESC_WRITE	EQU	0002H	; 0010b 写
DESC_ACCESSED	EQU	0001H	; 0001b 已访问
;DESC_READ	EQU	0000H	; 0000b 读
DESC_CONFORMING	EQU	000CH	; 1100b 一致代码段



; 门
; usage: Gate Selector, Offset, DCount, Attr
;        Selector:  dw
;        Offset:    dd
;        DCount:    db
;        Attr:      db
%macro Gate 4
	dw	(%2) & 0FFFFh				; 偏移1
	dw	(%1)					; 选择子
	dw	(%3) & 1Fh) | (((%4) << 8) & 0FF00h	; 属性
	dw	((%2) >> 16) & 0FFFFh			; 偏移2
%endmacro ; 共 8 字节

; 描述符类型
;DA_32		EQU	DESC_DB	; 32 位段
; 存储段描述符类型
;DA_DRW		EQU	DESC_P|DESC_S|DESC_WRITE 	; 92h 存在的可读写数据段属性值
;DA_C		EQU	DESC_P|DESC_S|DESC_EXECUTABLE	; 98h 存在的只执行代码段属性值


%endif ;  __DESCRIPTOR_S__

