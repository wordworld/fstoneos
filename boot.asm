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

; demo_001 简单引导示例
%ifdef D001_SIMPLE_BOOT
	%include "d001_simple_boot.asm"
%endif

; demo_002 进入保护模式
%ifdef D002_ENTER_PM
	%include "d002_enter_pm.asm"
%endif


