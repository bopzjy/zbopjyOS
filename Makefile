# Entry point of OS
# It must have the same value with 'KernelEntryPointPhyAddr' in load.inc
ENTRYPOINT	= 0x30400

# Offset of entry point in kernel file
# It depends on ENTRYPOINT
ENTRYOFFSET	= 0x400

ASM			= nasm
DASM		= ndisasm
CC			= gcc
LD			= ld
ASMBFLAGS	= -I boot/include/
ASMKFLAGS	= -I include/ -f elf
NIMABI		= -f elf
CFLAGS		= -I include/ -m32 -c -fno-stack-protector #-fno-builtin
LDFLAGS		= -s -Ttext $(ENTRYPOINT) -m elf_i386
DASMFLAGS	= -u -o $(ENTRYPOINT) -e $(ENTRYOFFSET)

#target
OSBOOT		= boot/boot.bin boot/loader.bin
OSKERNEL	= kernel.bin
OBJS		= kernel/global.o kernel/kernel.o kernel/start.o kernel/protect.o lib/kliba.o lib/string.o lib/klib.o kernel/i8259.o
DASMOUTPUT	= kernel.bin.asm

# all phony targets
.PHONY : everything final image clean realclean disasm all buildimg

# default start positon
everything : $(OSBOOT) $(OSKERNEL)

all : realclean everything

final : all clean

image : final buildimg

clean : 
	rm -f $(OBJS)

realclean : 
	rm -f $(OBJS) $(OSBOOT) $(OSKERNEL)

all : realclean everything

disam :
	$(DASM) $(DASMFLAGS) $(OSBOOT) > $(DASMOUTPUT)

buildimg :
	dd if=boot/boot.bin of=a.img bs=512 count=1 conv=notrunc
	sudo mount -o loop a.img /mnt/floppy/
	cp -fv boot/loader.bin /mnt/floppy
	cp -fv kernel.bin /mnt/floppy
	sleep 0.08
	sudo umount /mnt/floppy
	bochs -q -f nd_bochsrc

boot/boot.bin : boot/boot.asm boot/include/load.inc boot/include/fat12hdr.inc
	$(ASM) $(ASMBFLAGS) -o $@ $<

boot/loader.bin : boot/loader.asm boot/include/load.inc boot/include/pm.inc boot/include/fat12hdr.inc
	$(ASM) $(ASMBFLAGS) -o $@ $<

$(OSKERNEL) : $(OBJS)
	$(LD) $(LDFLAGS) -o $(OSKERNEL) $(OBJS)

kernel/kernel.o : kernel/kernel.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<

kernel/start.o : kernel/start.c include/type.h include/const.h include/protect.h include/proto.h include/string.h include/global.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/i8259.o: kernel/i8259.c include/const.h include/protect.h include/proto.h include/type.h
	$(CC) $(CFLAGS) -o $@ $<

lib/kliba.o : lib/kliba.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<

lib/string.o : lib/string.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<

lib/klib.o: lib/klib.c include/const.h include/type.h include/proto.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/protect.o: kernel/protect.c include/const.h include/type.h \
	 include/protect.h include/global.h include/proto.h
	$(CC) $(CFLAGS) -o $@ $<

global.o: kernel/global.c include/type.h include/const.h \
	 include/protect.h include/proto.h include/global.h
	$(CC) $(CFLAGS) -o $@ $<
