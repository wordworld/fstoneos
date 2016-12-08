############################################################
##! @brief	引导程序 Makefile
##! 
##! 
##! @file	Makefile
##! @author	fstone.zh@foxmail.com
##! @date	2016-12-07
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
DEFINES	= -D$(BOOT) -D$(DEMO)

# Code & Build result
MAIN	= boot.asm
SRC	= demo/$(DEMO_LOWER).asm

all:$(BOOT)

cd:BOOT_FROM_CD
BOOT_FROM_CD:$(EXE) $(CD)
	cp $(EXE) $(CDROOT)/$(DBOOT)
	$(FILLCD) -b $(DBOOT)/$(EXE) -c $(DBOOT)/$(EXE:.mac=.catalog) -o $(CD) $(CDROOT)
$(CD):
	mkdir -p $(CDROOT)/$(DBOOT)
	$(MKCD) -o $(CD) $(CDROOT)
	
fd:BOOT_FROM_FD
BOOT_FROM_FD:$(EXE) $(FD)
	$(FILLFD) if=$(EXE) of=$(FD) 
$(FD):
	$(MKFD) $(FD)


$(EXE):$(MAIN) $(SYSCFG) $(SRC)
	$(ASM) $(DEFINES) $(INCLUDES) $(ASFLAGS) $< -o $@


clean:
	rm -f $(EXE)

cleanall:clean
	rm -f $(FD) $(CD) $(HD)
	if [ -d $(CDROOT) ];then rm -r $(CDROOT);fi

run:
	$(BOCHS) -f $($(BOOT))

burn:
	sudo dd if=$(CD) of=/dev/sdb
