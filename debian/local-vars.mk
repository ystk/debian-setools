############################ -*- Mode: Makefile -*- ###########################
## local-vars.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
## Created On       : Sat Nov 15 10:43:00 2003
## Created On Node  : glaurung.green-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Sun Mar 30 15:26:37 2008
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 50
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : 
## 
## arch-tag: 1a76a87e-7af5-424a-a30d-61660c8f243e
## 
###############################################################################

LIBQPOL_VERSION    := $(shell egrep '^libqpol_version='    configure.ac | sed 's/.*=//')
LIBAPOL_VERSION    := $(shell egrep '^libapol_version='    configure.ac | sed 's/.*=//')
LIBSEFS_VERSION    := $(shell egrep '^libsefs_version='    configure.ac | sed 's/.*=//')
LIBPOLDIFF_VERSION := $(shell egrep '^libpoldiff_version=' configure.ac | sed 's/.*=//')
LIBSEAUDIT_VERSION := $(shell egrep '^libseaudit_version=' configure.ac | sed 's/.*=//')

LIBQPOL_SOVERSION    := $(shell egrep '^libqpol_soversion='    configure.ac | sed 's/.*=//')
LIBAPOL_SOVERSION    := $(shell egrep '^libapol_soversion='    configure.ac | sed 's/.*=//')
LIBSEFS_SOVERSION    := $(shell egrep '^libsefs_soversion='    configure.ac | sed 's/.*=//')
LIBPOLDIFF_SOVERSION := $(shell egrep '^libpoldiff_soversion=' configure.ac | sed 's/.*=//')
LIBSEAUDIT_SOVERSION := $(shell egrep '^libseaudit_soversion=' configure.ac | sed 's/.*=//')

AUTOTOOLS_FILES =  INSTALL config.guess config.sub Makefile.in aclocal.m4       \
                   apol/Makefile.in config.h.in configure depcomp install-sh    \
                   libapol/Makefile.in libapol/include/Makefile.in              \
                   libapol/include/apol/Makefile.in libapol/src/Makefile.in     \
                   libapol/swig/Makefile.in libapol/swig/java/Makefile.in       \
                   libapol/swig/python/Makefile.in libapol/swig/tcl/Makefile.in \
                   libapol/tests/Makefile.in libpoldiff/Makefile.in             \
                   libpoldiff/include/Makefile.in                               \
                   libpoldiff/include/poldiff/Makefile.in                       \
                   libpoldiff/src/Makefile.in libpoldiff/swig/Makefile.in       \
                   libpoldiff/swig/java/Makefile.in                             \
                   libpoldiff/swig/python/Makefile.in                           \
                   libpoldiff/swig/tcl/Makefile.in libpoldiff/tests/Makefile.in \
                   libqpol/Makefile.in libqpol/include/Makefile.in              \
                   libqpol/include/qpol/Makefile.in libqpol/src/Makefile.in     \
                   libqpol/swig/Makefile.in libqpol/swig/java/Makefile.in       \
                   libqpol/swig/python/Makefile.in libqpol/swig/tcl/Makefile.in \
                   libqpol/tests/Makefile.in libseaudit/Makefile.in             \
                   libseaudit/include/Makefile.in                               \
                   libseaudit/include/seaudit/Makefile.in                       \
                   libseaudit/src/Makefile.in libseaudit/swig/Makefile.in       \
                   libseaudit/swig/java/Makefile.in                             \
                   libseaudit/swig/python/Makefile.in                           \
                   libseaudit/swig/tcl/Makefile.in libseaudit/tests/Makefile.in \
                   libsefs/Makefile.in libsefs/include/Makefile.in              \
                   libsefs/include/sefs/Makefile.in libsefs/src/Makefile.in     \
                   libsefs/swig/Makefile.in libsefs/swig/java/Makefile.in       \
                   libsefs/swig/python/Makefile.in libsefs/swig/tcl/Makefile.in \
                   libsefs/tests/Makefile.in man/Makefile.in                    \
                   packages/Makefile.in packages/rpm/Makefile.in                \
                   seaudit/Makefile.in sechecker/Makefile.in secmds/Makefile.in \
                   sediff/Makefile.in ylwrap

FILES_TO_CLEAN  =  debian/files debian/substvars debian/shlibs.local                      \
                   libapol/libapol.a       libapol/libapol.so.$(LIBAPOL_VERSION)          \
                   libapol/libapol-tcl.a   libapol/libapol-tcl.so.$(LIBAPOL_VERSION)      \
                   libseaudit/libseaudit.a libseaudit/libseaudit.so.$(LIBSEAUDIT_VERSION) \
                   libsefs/libsefs.a       libsefs/libsefs.so.$(LIBSEFS_VERSION)          \
                   apol/apol.xcf           sediff/sediffx-small.xcf   seaudit/seaudit.xcf \
                   sediff/sediffx.xcf      $(AUTOTOOLS_FILES)

STAMPS_TO_CLEAN = 
DIRS_TO_CLEAN   = autom4te.cache apol/apol_tcl libapol/swig/java/com libapol/swig/tcl/apol \
                  libpoldiff/swig/java/com libpoldiff/swig/tcl/poldiff                     \
                  libqpol/swig/java/com    libqpol/swig/tcl/qpol                           \
                  libseaudit/swig/java/com libseaudit/swig/tcl/seaudit                     \
                  libsefs/swig/java/com    libsefs/swig/tcl/sefs      debin/stamp          \
                  autom4te.cache

# Location of the source dir
SRCTOP    := $(shell if [ "$$PWD" != "" ]; then echo $$PWD; else pwd; fi)
TMPTOP     = $(SRCTOP)/debian/$(package)

PREFIX  = /usr
BINDIR  = $(TMPTOP)$(PREFIX)/bin
SBINDIR = $(TMPTOP)$(PREFIX)/sbin
LIBDIR  = $(TMPTOP)$(PREFIX)/lib
ETCDIR  = $(TMPTOP)/etc
INCLUDE = $(PREFIX)/include
INCDIR  = $(INCLUDE)/selinux
SHAREDIR= $(TMPTOP)$(PREFIX)/share

MENUDIR    = $(SHAREDIR)/menu/
LINTIANDIR = $(SHAREDIR)/lintian/overrides

MANDIR  = $(SHAREDIR)/man
MAN1DIR = $(MANDIR)/man1
MAN3DIR = $(MANDIR)/man3
MAN5DIR = $(MANDIR)/man5
MAN7DIR = $(MANDIR)/man7
MAN8DIR = $(MANDIR)/man8

INFODIR = $(SHAREDIR)/info
DOCTOP  = $(SHAREDIR)/doc
DOCDIR  = $(DOCTOP)/$(package)
PKGDOCDIR = $(PREFIX)/share/doc/$(package)

SETOOLS_DIR  := $(shell egrep '^setoolsdir=' configure.ac | sed 's/.*=//')
prefix=$(PREFIX)

# Not all architectures have a java compiler
HAVE_JAVAC:=$(shell if which javac >/dev/null 2>&1; then echo Yes; fi)
ifneq (,$(strip $(HAVE_JAVAC)))
JAVA_CONF_OPTION:=--enable-swig-java 
else
JAVA_CONF_OPTION:=
endif

TCLVER         =8.4 

COMMA   = ,
PY_VERSIONS    =>= 2.3
PYDEFAULT      =$(strip $(shell pyversions -vd))
ALL_PY_VERSIONS=$(sort $(shell pyversions -vr))
MIN_PY_VERSIONS=$(firstword $(sort $(shell pyversions -vr)))
MAX_PY_VERSIONS=$(lastword  $(sort $(shell pyversions -vr)))
PY_VIRTUALS    :=$(patsubst %,%-setools$(strip $(COMMA)),$(sort $(shell pyversions -r)))
PY_PROVIDES    :=$(strip $(shell pyversions -r |              \
        perl -ple 's/(\d) p/$$1-setools, p/g; s/$$/-setools/'))

PYTHON_VERSION =$(PYDEFAULT)
#STOP_VERSION   :=$(shell perl -e '$$ARGV[0] =~ m/^(\d)\.(\d)/;$$maj=$$1;$$min=$$2 +1; print "$$maj.$$min\n";' $(MAX_PY_VERSIONS))
STOP_VERSION   :=$(shell perl -e '$$ARGV[0] =~ m/^(\d)\.(\d)/;$$maj=$$1;$$min=$$2 +1; print "$$maj.$$min\n";' $(PYTHON_VERSION))


PDIR=$(LIBDIR)/python$(PYTHON_VERSION)

confflags    = --with-tcl=$(PREFIX)/lib/tcl$(TCLVER) --with-tk=$(PREFIX)/lib/tk$(TCLVER) --with-tkinclude=$(PREFIX)/include/tcl$(TCLVER)
BUILD_FLAGS  = 


MODULES_DIR    =$(TMPTOP)$(PREFIX)/share/python-support/$(package)
EXTENSIONS_DIR =$(TMPTOP)$(PREFIX)/lib/python-support/$(package)
PYTHONLIBDIRTOP=$(PREFIX)/lib/python-support/$(package)/

LIB_PATH=./debian/libsefs4/usr/lib:./debian/libseaudit4/usr/lib:./debian/libapol4/usr/lib:./debian/libqpol1/usr/lib:./debian/libpoldiff1/usr/lib

define checkdir
	@test -f debian/rules -a -f libapol/src/libapol.map || \
          (echo Not in correct source directory; exit 1)
endef

define checkroot
	@test $$(id -u) = 0 || (echo need root priviledges; exit 1)
endef
