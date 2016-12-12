;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @brief	输入输出
;; 
;; 
;; @file	io.asm
;; @author	fstone.zh@foxmail.com
;; @date	2016-12-12
;; @version	0.1.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

; 显示字符串
;	输出位置由 DH(行),DL(列) 提供
;	字符串首地址由 ES:BP 给出
;	字符串长度由 CX 给出
DispStr:
	; ISR( int 10h ) AH = 13h : 显示字符串
	; 	AL = 1 : BL表示属性
	;	参考	INT 10H ( https://en.wikipedia.org/wiki/INT_10H )
	;		和 BIOS 颜色属性 ( https://en.wikipedia.org/wiki/BIOS_color_attributes )
	mov	ax, 1301h
	;	BL = 6 (0110b) : 棕色. BH = 页号
	mov	bx, 0006h
	int	10h
	ret
