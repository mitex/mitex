#
# Adapted from NCSA Xmosaic Makefile

# ----------------------------------------------------------------------------
# For normal machines with normal compilers:
CC = cc
# For testing:
# CC = gcc
# For Sun's and other non-at-least-pseudo-ANSI-C platforms:
# CC = gcc
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# For SGI's:
CFLAGS = -g -cckr  -DXMOSAIC
# For testing:
# CFLAGS = -g -Wall -DXMOSAIC
# For HP's:
# CFLAGS = -g -DXMOSAIC -I/usr/include/Motif1.1 -I/usr/include/X11R4
# For everyone else:
# CFLAGS = -g -DXMOSAIC
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# For SGI's:
RANLIB = /bin/true
# For everyone else:
# RANLIB = ranlib
# ----------------------------------------------------------------------------

# You shouldn't need to edit below here.

EXETARGET = html2latex
LIBTARGET = libhtmlp.a
DOCTARGET = html2latex.tex

all: $(LIBTARGET) $(EXETARGET) $(DOCTARGET)

CFILES = HTMLparse.c HTMLplist.c

OBJS = $(CFILES:.c=.o)

$(LIBTARGET): $(OBJS)
	-rm -f $(LIBTARGET)
	ar rv $(LIBTARGET) $(OBJS)
	$(RANLIB) $(LIBTARGET)

$(EXETARGET): $(LIBTARGET) $(EXETARGET).c
	$(CC) $(CFLAGS) -o $(EXETARGET) $(EXETARGET).c $(LIBTARGET)

$(DOCTARGET): $(EXETARGET) html2latex.html
	./$(EXETARGET) html2latex.html

$(OBJS): HTMLparse.h

clean:
	-rm $(EXETARGET) $(OBJS) $(LIBTARGET) $(DOCTARGET)
