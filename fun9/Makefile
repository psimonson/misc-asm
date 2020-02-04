CC=gcc
CFLAGS=-std=c89 -Wall -Wextra -pedantic -Wno-unused-parameter
LDFLAGS=
ASM=nasm
AFLAGS=-f bin
TARGETS=fun9.com fun9gen

.PHONY: all clean
all: $(TARGETS)

%.c.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

fun9.com: fun9build fun9.asm
	$(ASM) $(AFLAGS) -o $@ fun9.asm

fun9gen: fun9gen.c.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

fun9build: fun9gen
	./fun9gen message.dat close.dat version.dat help.dat > data.inc

copy: fun9gen fun9.com
	cp fun9.com ${HOME}/dos

clean:
	rm -f *~ *.o data.inc $(TARGETS)
