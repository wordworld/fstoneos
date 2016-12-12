;;************************************************************
;; @brief	预处理相关
;; 
;; 
;; @file	prepro.s
;; @author	fstone.zh@foxmail.com
;; @date	2016-12-12
;; @version	0.1.0
;;************************************************************

%ifndef __PREPRO_S__
%define __PREPRO_S__

; 代码加载到指定内存位置
%ifdef		BOOT_FROM_CD
	org	0000h		; 光盘启动, 代码加载到 0x0000
%elifdef	BOOT_FROM_FD
	org	7c00h		; 软盘启动, 代码加载到 0x7c00
%endif


%endif ; __PREPRO_S__

