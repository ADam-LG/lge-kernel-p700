# Makefile for mkbootimg

CC = gcc
STRIP = strip
RM = rm -f

TARGETS = mkbootimg mkbootfs unpackbootimg
OBJS = $(addsuffix .o, $(TARGETS))

all: $(TARGETS)

mkbootimg: mkbootimg.o rsa.o sha.o
	$(CC) $(CFLAGS) -o mkbootimg mkbootimg.o rsa.o sha.o
	$(STRIP) mkbootimg

mkbootfs:
	$(CC) $(CFLAGS) -o mkbootfs mkbootfs.c
	$(STRIP) mkbootfs

unpackbootimg:
	$(CC) $(CFLAGS) -o unpackbootimg unpackbootimg.c
	$(STRIP) unpackbootimg

$(OBJS): %.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^

.PHONY: clean

clean:
	$(RM) $(TARGETS) *.o
