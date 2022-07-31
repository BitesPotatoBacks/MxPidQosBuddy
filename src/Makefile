
CC=clang
CFLAGS=-fobjc-arc -arch arm64

PROGS= mxpidqosbud_cpures

all: $(PROGS)

mxpidqosbud_cpures: *.m ; $(CC) $(CFLAGS) -o $@ $^
    
clean: ; rm -rf ${PROGS} *.o
