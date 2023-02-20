############################################################
##! @brief	引导程序 Makefile
##! 
##! 
##! @file	Makefile
##! @author	fstone.zh@foxmail.com
##! @date	2023-02-19
##! @version	0.1.0
############################################################
# config file
SYSCFG	= system.mk
include $(SYSCFG)


# Compile & Link
ASM 	= nasm
ASFLAGS	= 
INCLUDES= -Iinc/ -Idemo/

# defines
DEFINES	= -D$(BOOT) -D$(DEMO)=$(DEMO)

# Pre include
PINCS	= -Pprepro.s

# Code & Build result
MAIN	= boot/mbr.s
SRC	= 

vpath	d%.asm	demo

CMD_CLEAN_DIR := if [ -d $(CDROOT) ];then rm -r $(CDROOT);fi

all:$(BOOT)

cd:BOOT_FROM_CD
BOOT_FROM_CD:$(EXE) $(CD)
	cp $(EXE) $(CDROOT)/$(dir $(EXE))
	$(FILLCD) -b $(EXE) -c $(EXE:.bin=.catalog) -o $(CD) $(CDROOT)

$(CD):
	mkdir -p $(CDROOT)/$(dir $(EXE))
	$(MKCD) -o $(CD) $(CDROOT)
	
fd:BOOT_FROM_FD
BOOT_FROM_FD:$(EXE) $(FD)
	$(FILLFD) if=$(EXE) of=$(FD) 
$(FD):
	$(MKFD) $(FD)


$(EXE):$(MAIN:.s=.o) $(SYSCFG) $(SRC)
	ld -e main --Ttext-segment=0 --oformat=binary -o $(EXE) $<

.s.o:
	as -o $@ $<

clean:
	rm -f $(EXE) $(MAIN:.s=.o)

clear:clean
	rm -f $(EXE) $(FD) $(CD) $(HD) *.mac *.bin *.exe
	$(CMD_CLEAN_DIR)

run:
	$(BOCHS) -f $($(BOOT))

burn:
	sudo dd if=$(CD) of=/dev/sdb
