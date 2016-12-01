# config file
SYSCFG	= system.mk
include $(SYSCFG)

# Code & Build result
MAIN	= boot.asm

# Compile & Link
ASM 	= nasm

all:$(BOOT)
	
BOOT_FROM_FD:$(EXE) $(FD)
	dd if=$(EXE) of=$(FD) bs=512 count=1 conv=notrunc
$(FD):
	$(MKFD) $(FD)

BOOT_FROM_CD:$(EXE) 
	mkdir -p $(CDROOT)
	cp $(EXE) $(CDROOT)
	$(MKCD) -input-charset=utf-8 -r -o $(CD) $(CDROOT)
	$(MKCD) -input-charset=utf-8 -R -b $(EXE) -no-emul-boot -boot-load-seg $(LOADADDR) -o $(CD) $(CDROOT)

$(EXE):$(MAIN) $(SYSCFG)
	$(ASM) -D$(BOOT) $< -o $@

clean:
	rm -f $(EXE) $(FD) $(CD) $(HD)
	if [ -d $(CDROOT) ];then rm -r $(CDROOT);fi
run:
	$(RUN) $($(BOOT))
