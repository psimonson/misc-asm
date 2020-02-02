CC=gcc
CFLAGS=-std=c89 -Wall -Wextra -Wno-unused-parameter
LDFLAGS=
ASM=nasm
AFLAGS=-f bin
ASRC=$(wildcard *.asm)
TARGETS=$(ASRC:%.asm=%.com)

.PHONY: all clean
all: $(TARGETS)
	cd fun8 && $(MAKE)
	cd fun9 && $(MAKE)

%.c.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.com: %.asm
	$(ASM) $(AFLAGS) -o $@ $<

copy: all
	@[ -d "${HOME}/dos" ] && mkdir ${HOME}/dos || echo "${HOME}/dos exists."
	cp $(TARGETS) ${HOME}/dos
	cd fun8 && $(MAKE) copy
	cd fun9 && $(MAKE) copy

clean:
	rm -f *~ *.o $(TARGETS)
	cd fun8 && $(MAKE) clean
	cd fun9 && $(MAKE) clean
