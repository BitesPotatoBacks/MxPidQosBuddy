
CC=clang
CFLAGS=-fobjc-arc -arch arm64

PROGS= mxpidcpur_cpures

all: $(PROGS)

mxpidcpur_cpures: *.m ; $(CC) $(CFLAGS) -o $@ $^
    
clean: ; rm -rf ${PROGS} *.o
