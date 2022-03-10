
rominfo.bin: rominfo.asm include/bios.inc include/kernel.inc
	asm02 -b -L rominfo.asm

clean:
	-rm -f *.bin *.lst

