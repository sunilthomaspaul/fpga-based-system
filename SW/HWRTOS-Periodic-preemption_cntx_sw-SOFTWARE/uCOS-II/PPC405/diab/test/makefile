#----------------------------------------------------------------------
# Makefile for the ucos-ii port on Walnut (PPC405GP)
# Uses the Diab compiler (Rel 4.3 Rev f PowerPC)
#----------------------------------------------------------------------

# Path to this port
PPCDIR = ..

# Set the path to where the ucos-ii processor independent files exist.
UCOSDIR = $(PPCDIR)

#----------------------------------------------------------------------
#    List all the objects
#----------------------------------------------------------------------
CFILES = $(UCOSDIR)/ucos_ii.c \
       $(PPCDIR)/source/os_cpu_c.c \
       $(PPCDIR)/source/uart_init.c \
       $(PPCDIR)/source/uart_tx.c \
       $(PPCDIR)/source/interrupts.c  \
       $(PPCDIR)/test/multit.c

AFILES = $(PPCDIR)/source/os_cpu_a.s \
       $(PPCDIR)/source/iolib.s \
       $(PPCDIR)/source/ppclib.s \
       $(PPCDIR)/source/ppcmal.s \
       $(PPCDIR)/source/ppcuic.s

DCOBJECTS=$(CFILES:.c=.o)
DAOBJECTS=$(AFILES:.s=.o)

OBJS = $(PPCDIR)/test/crt0.o $(DCOBJECTS) $(DAOBJECTS)

#----------------------------------------------------------------------
#   Includes and defines
#----------------------------------------------------------------------
DEF =
INC = -I$(PPCDIR)/include -I$(PPCDIR)/source -I$(PPCDIR)/kernel
CFLAGS = $(INC) -g $(DEF)

#----------------------------------------------------------------------
#   Compiler
#----------------------------------------------------------------------
# original compiler command line
#CC = $(DIABPATH)/bin/dcc -H -tPPC405ES:simple -Xlint

# added -Xsmall-const=0,
# per Diab tech support
CC = $(DIABPATH)/bin/dcc -tPPC405ES:simple -Xlint -Xsmall-const=0
CCDEP = gcc

#----------------------------------------------------------------------
#   Assembler
#----------------------------------------------------------------------
AS = $(DIABPATH)/bin/das -tPPC405ES:simple $(INC)

#----------------------------------------------------------------------
#   Linker 
#----------------------------------------------------------------------
LD=$(DIABPATH)/bin/dld
LD_OPTIONS = -e _start

#----------------------------------------------------------------------
#   Lint
#----------------------------------------------------------------------
LINT = gcc -ansi -c -fsyntax-only
LINTFLAGS = -Wall -Wpointer-arith -Wid-clash-32 -Wcast-align \
            -Waggregate-return -Wshadow -Wcast-qual -Wmissing-prototypes
# -Wstrict-prototypes should be included
# (should -Wtraditional warning be incorporated?)

#----------------------------------------------------------------------
#   Make Rules
#----------------------------------------------------------------------
.c.o :
	$(CC) $(CFLAGS) -c -o $*.o $<

.s.o :
	$(AS) -o $*.o $<

#----------------------------------------------------------------------
#   Final image
#----------------------------------------------------------------------
EXE = ucosppc

#----------------------------------------------------------------------
#   make all rule
#----------------------------------------------------------------------
all: $(EXE)

include .depend
#----------------------------------------------------------------------
#   This section builds a ram image suitable for use with VisionIce
#----------------------------------------------------------------------
$(EXE): $(OBJS) .depend
	$(LD) -lc $(OBJS) $(LD_OPTIONS) -o $(EXE).elf walnut.dld -m2 > $(EXE).map
	mkevimg $(EXE).elf $(EXE).img

.depend: $(CFILES) $(AFILES)
	@echo "Making dependencies .."
	$(CCDEP) $(CFLAGS) -MM $^ > .depend || rm -f .depend

clean:
	rm $(OBJS) $(EXE).* .depend

#----------------------------------------------------------------------
# End of Makefile.
#----------------------------------------------------------------------
# Notes:
# - OBJECTS     Put crt0.o first so dld will link it first.
# - dld         -lc: link libc.a from directory selected by -tMC68060FN:rtasim.
# - dcc         Add -g for debugging, -XO for highly optimized code.
# - das         Add -g for debugging.
# DO NOT DELETE
