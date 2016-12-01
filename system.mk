# Distribute
LOGO	= fstoneos
VERSION	= 1.0
SIGN	= $(LOGO)-$(VERSION)

# dd, tool to write floppy
WRITE	= dd bs=512 count=1 conv=notrunc 

# FD, Floppy Disc
FD	= $(SIGN).img
FSIZE	= 1.44M
MKFD	= bximage -mode=create -fd=$(FSIZE) -q

# CD, Compact Disc
CDROOT	= $(SIGN)
CD	= $(CDROOT).iso 
LOADADDR= 0x7c00
MKCD	= mkisofs -input-charset=utf-8 -q

# HD, Hard Disk

# boot options
BOOT_FROM_FD	= bochsrc_fd
BOOT_FROM_CD	= bochsrc_cd
BOOT_FROM_HD	= bochsrc_hd
# BOOT		= BOOT_FROM_FD
BOOT		= BOOT_FROM_CD
# BOOT		= BOOT_FROM_HD

# debug & run
EXE		= $(subst .asm,.mac,$(filter %.asm,$(MAIN))) $(subst .c,.bin,$(filter %.c,$(MAIN))) $(subst .cpp,.exe,$(filter %.cpp,$(MAIN)))
DEBUG_SCRIPT_FILE= bochs_debug
RUN		= bochs -q -rc $(DEBUG_SCRIPT_FILE) -f
