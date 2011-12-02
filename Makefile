#
# NOTE: only compilable with x86 cross compile tools
#

DEFINES=

TARGETS=scc_bios.bin

all: $(TARGETS)

scc_bios.bin: scc_bios.o
	$(CROSS_COMPILE)ld --oformat binary -Ttext 0 -melf_i386 -o $@ $<
	chmod a-x $@

%.o: %.S
	$(CROSS_COMPILE)gcc $(DEFINES) -m32 -c -o $@ $<

clean:
	rm -f $(TARGETS) *.o *~

