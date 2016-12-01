# config file
SYSCFG	= system.mk
include $(SYSCFG)

# Code & Build result
MAIN	= boot.asm

# Compile & Link
ASM 	= nasm

all:$(BOOT)
	
BOOT_FROM_FD:$(EXE) $(FD)
	$(WRITE) if=$(EXE) of=$(FD) 

$(FD):
	$(MKFD) $(FD)

BOOT_FROM_CD:$(EXE) 
	mkdir -p $(CDROOT)
	cp $(EXE) $(CDROOT)
	$(MKCD) -r -o $(CD) $(CDROOT)
	$(MKCD) -R -no-emul-boot -boot-load-seg $(LOADADDR) -b $(EXE) -o $(CD) $(CDROOT)

$(EXE):$(MAIN) $(SYSCFG)
	$(ASM) -D$(BOOT) $< -o $@

clean:
	rm -f $(EXE) $(FD) $(CD) $(HD)
	if [ -d $(CDROOT) ];then rm -r $(CDROOT);fi
run:
	$(RUN) $($(BOOT))
