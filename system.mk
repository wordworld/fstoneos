# Distribute
LOGO	= fstoneos
VERSION	= 1.0
SIGN	= $(LOGO)-$(VERSION)

# executable file extension
EXE		= $(subst .s,.bin,$(filter %.s,$(MAIN)))$(subst .c,.bin,$(filter %.c,$(MAIN)))$(subst .cpp,.exe,$(filter %.cpp,$(MAIN)))

# dd, tool to write floppy
DD	= dd bs=512 count=1 conv=notrunc

# FD, Floppy Disc
FD	= $(SIGN).img
FSIZE	= 1.44M
MKFD	= bximage -func=create -fd=$(FSIZE) -q
FILLFD	= $(DD)

# CD, Compact Disc
CDROOT	= $(SIGN)
CD	= $(CDROOT).iso 
LOADADDR= 0x7c00
MKCD	= mkisofs -r -q -input-charset=utf-8 
FILLCD	= mkisofs -R -q -input-charset=utf-8 -no-emul-boot -boot-load-seg $(LOADADDR)

# HD, Hard Disk

# boot bochs config
DBOCHSRC	= bochs
BOCHS_SCRIPT= $(DBOCHSRC)/bochs_debug
BOCHS		= bochs -q -rc $(BOCHS_SCRIPT)

# boot option
BOOT_FROM_FD	= $(DBOCHSRC)/bochsrc_fd
BOOT_FROM_CD	= $(DBOCHSRC)/bochsrc_cd
BOOT_FROM_HD	= $(DBOCHSRC)/bochsrc_hd
# BOOT		= BOOT_FROM_FD
BOOT		= BOOT_FROM_CD
# BOOT		= BOOT_FROM_HD


# module
DEMO_LOWER	= $(shell echo "$(DEMO)" | tr "[A-Z]" "[a-z]")
# DEMO		= D001_SIMPLE_BOOT
# DEMO		= D002_ENTER_PM
DEMO		= D003_PM2RM

