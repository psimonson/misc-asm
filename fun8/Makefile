CC=gcc
CFLAGS=-std=c89 -Wall -Wextra -pedantic -Wno-unused-parameter
LDFLAGS=
ASM=nasm
AFLAGS=-f bin
TARGETS=fun8.com fun8gen

.PHONY: all clean
all: $(TARGETS)

%.c.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

fun8.com: fun8build fun8.asm
	$(ASM) $(AFLAGS) -o $@ fun8.asm

fun8gen: fun8gen.c.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

fun8build: fun8gen
	./fun8gen virii.dat > data.inc

copy: fun8gen fun8.com
	cp fun8.com ${HOME}/dos

clean:
	rm -f *~ *.o data.inc $(TARGETS)
