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

# Code & Build result
MAIN	= boot.asm

# Compile & Link
ASM 	= nasm
AFLAGS	= -D$(BOOT) -Iinc/


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


$(EXE):$(MAIN) $(SYSCFG)
	$(ASM) $(AFLAGS) $< -o $@


clean:
	rm -f $(EXE) $(FD) $(CD) $(HD)
	if [ -d $(CDROOT) ];then rm -r $(CDROOT);fi

run:
	$(RUN) $($(BOOT))

burn:
	sudo dd if=$(CD) of=/dev/sdb
