ASM 	= nasm

DEFINES	+= -D_DEBUG 

CFLAGS	+= -Wall -g -pthread

LDFLAGS	+= 

INCLUDES += -I$(DIR_DEVLIBS)/include

vpath %.a $(DIR_DEVLIBS)/lib

SRC	= 
MAIN	= boot.asm
OBJS	= $(MAIN:.cpp=.o) $(SRC:.cpp=.o)
EXE	= $(MAIN:.asm=.bin)
ISO	= fos.iso
CDROOT	= cdroot
LOADADDR= 0x1000

all:$(EXE)
	mkdir -p $(CDROOT)
	cp $(EXE) $(CDROOT)
	mkisofs -input-charset=utf-8 -r -o $(ISO) $(CDROOT)
	mkisofs -input-charset=utf-8 -R -b $(EXE) -no-emul-boot -boot-load-seg $(LOADADDR) -o $(ISO) $(CDROOT)

$(EXE):$(MAIN)
	$(ASM) $< -o $@

.c.o:
	$(CC) -c $(DEFINES) $(INCLUDES) $(CFLAGS) $< -o $@

.cpp.o:
	$(CPP) -c $(DEFINES) $(INCLUDES) $(CFLAGS) $< -o $@

clean:
	rm -f $(EXE) $(ISO)
	if [ -d $(CDROOT) ];then rm -r $(CDROOT);fi

run:
	bochs

