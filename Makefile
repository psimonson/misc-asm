CC=gcc
CFLAGS=-std=c89 -Wall -Wextra -Wno-unused-parameter
LDFLAGS=
ASM=nasm
AFLAGS=-f bin
ASRC=$(wildcard *.asm)
TARGETS=$(ASRC:%.asm=%.com)
DOSDIR=/home/philip/dos

.PHONY: all clean
all: $(TARGETS)

%.c.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.com: %.asm
	$(ASM) $(AFLAGS) -o $@ $<

copy: all
	cp $(TARGETS) $(DOSDIR)

clean:
	rm -f *~ *.o $(TARGETS)
