TOPDIR ?= $(realpath $(CURDIR)/../../ )
SRCDIR = $(TOPDIR)/tools/fio

EXAMPLESDIR=	/usr/share/doc/storpool/examples/fio

all:
	echo "Nothing to build for repsync"

install:
	set -e; find . -type d | while read d; do mkdir -p "${DESTDIR}${EXAMPLESDIR}/$$d"; done
	set -e; find . -type f \! -perm /111 \! -name '*Makefile*' | while read f; do ${INSTALL_DATA}   "$$f" "${DESTDIR}${EXAMPLESDIR}/$$f"; done
	set -e; find . -type f    -perm /111 \! -name '*Makefile*' | while read f; do ${INSTALL_SCRIPT} "$$f" "${DESTDIR}${EXAMPLESDIR}/$$f"; done

include $(TOPDIR)/mk/install.mk
