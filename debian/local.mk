############################ -*- Mode: Makefile -*- ###########################
## local.mk --- 
## Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
## Created On       : Sat Nov 15 10:42:10 2003
## Created On Node  : glaurung.green-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Wed Sep  2 01:51:11 2009
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 170
## Status           : Unknown, Use with caution!
## HISTORY          : 
## Description      : 
## 
## arch-tag: b07b1015-30ba-4b46-915f-78c776a808f4
## 
###############################################################################

testdir:
	$(testdir)

debian/stamp/pre-config-common:    debian/stamp/conf/setools

debian/stamp/BUILD/setools:        debian/stamp/build/setools
debian/stamp/INST/setools:         debian/stamp/install/setools
debian/stamp/BIN/setools:          debian/stamp/binary/setools

debian/stamp/INST/libsefs4:        debian/stamp/install/libsefs4
debian/stamp/BIN/libsefs4:         debian/stamp/binary/libsefs4

debian/stamp/INST/libsefs-dev:     debian/stamp/install/libsefs-dev
debian/stamp/BIN/libsefs-dev:      debian/stamp/binary/libsefs-dev

debian/stamp/INST/libseaudit4:     debian/stamp/install/libseaudit4
debian/stamp/BIN/libseaudit4:      debian/stamp/binary/libseaudit4

debian/stamp/INST/libseaudit-dev:  debian/stamp/install/libseaudit-dev
debian/stamp/BIN/libseaudit-dev:   debian/stamp/binary/libseaudit-dev


debian/stamp/INST/libapol4: 	   debian/stamp/install/libapol4
debian/stamp/BIN/libapol4:  	   debian/stamp/binary/libapol4

debian/stamp/INST/libapol-dev:     debian/stamp/install/libapol-dev
debian/stamp/BIN/libapol-dev:      debian/stamp/binary/libapol-dev

debian/stamp/INST/libpoldiff1:     debian/stamp/install/libpoldiff1
debian/stamp/BIN/libpoldiff1:      debian/stamp/binary/libpoldiff1

debian/stamp/INST/libpoldiff-dev:  debian/stamp/install/libpoldiff-dev
debian/stamp/BIN/libpoldiff-dev:   debian/stamp/binary/libpoldiff-dev


debian/stamp/INST/libqpol1: 	   debian/stamp/install/libqpol1
debian/stamp/BIN/libqpol1:  	   debian/stamp/binary/libqpol1

debian/stamp/INST/libqpol-dev:     debian/stamp/install/libqpol-dev
debian/stamp/BIN/libqpol-dev:      debian/stamp/binary/libqpol-dev


ifneq (,$(strip $(HAVE_JAVAC)))
debian/stamp/INST/libsetools-java: debian/stamp/install/libsetools-java
debian/stamp/BIN/libsetools-java:  debian/stamp/binary/libsetools-java


debian/stamp/INST/libsetools-jni:  debian/stamp/install/libsetools-jni
debian/stamp/BIN/libsetools-jni:   debian/stamp/binary/libsetools-jni
endif


debian/stamp/INST/libsetools-tcl:  debian/stamp/install/libsetools-tcl
debian/stamp/BIN/libsetools-tcl:   debian/stamp/binary/libsetools-tcl


debian/stamp/INST/python-setools:  debian/stamp/install/python-setools
debian/stamp/BIN/python-setools:   debian/stamp/binary/python-setools

check:
	@echo LIBSEFS_VERSION = $(LIBSEFS_VERSION)
	@echo LIBSEFS_SOVERSION = $(LIBSEFS_SOVERSION)
	$(eval SPATH=$(SETOOLS_DIR))
	@echo SETOOLS_DIR = $(SPATH)

CLN-common::
	$(REASON)
	-test ! -f Makefile || $(MAKE) distclean

CLEAN/setools::
	-rm -rf $(TMPTOP)

CLEAN/libsefs4:: 
	-rm -rf $(TMPTOP)

CLEAN/libsefs-dev::
	-rm -rf $(TMPTOP)

CLEAN/libseaudit4::
	-rm -rf $(TMPTOP)

CLEAN/libseaudit-dev::
	-rm -rf $(TMPTOP)

CLEAN/libapol4:: 
	-rm -rf $(TMPTOP)

CLEAN/libapol-dev::
	-rm -rf $(TMPTOP)

CLEAN/libpoldiff1::
	-rm -rf $(TMPTOP)

CLEAN/libpoldiff-dev::
	-rm -rf $(TMPTOP)

CLEAN/libqpol1:: 
	-rm -rf $(TMPTOP)

CLEAN/libqpol-dev::
	-rm -rf $(TMPTOP)

CLEAN/libsetools-jni::
	-rm -rf $(TMPTOP)

CLEAN/libsetools-java:: 
	-rm -rf $(TMPTOP)

CLEAN/libsetools-tcl::
	-rm -rf $(TMPTOP)

CLEAN/python-setools::
	-rm -rf $(TMPTOP)


debian/stamp/conf/setools:
	$(checkdir)
	$(REASON)
	@test -d debian/stamp/conf || mkdir -p debian/stamp/conf
	WARNINGS=none autoreconf -f -i  --warnings=none
	PYTHON_VERSION=$(PYTHON_VERSION)  \
               bash ./configure    --verbose --prefix=$(PREFIX)  \
	       --sysconfdir=/etc   --enable-dependency-tracking  \
               $(JAVA_CONF_OPTION) --enable-swig-python          \
               --enable-swig-tcl   --disable-bwidget-check       \
               $(confflags)
	cat debian/*.shlibs | grep -v '#' > debian/shlibs.local
	@echo done > $@

debian/stamp/build/setools:
	$(checkdir)
	$(REASON)
	@test -d debian/stamp/build || mkdir -p debian/stamp/build
	bash -n debian/postinst
	bash -n debian/postrm
	bash -n debian/python_postinst
	bash -n debian/python_prerm
	$(MAKE) $(BUILD_FLAGS) all
ifeq (,$(strip $(filter nocheck,$(DEB_BUILD_OPTIONS))))
  ifeq ($(DEB_BUILD_GNU_TYPE),$(DEB_HOST_GNU_TYPE))
	@echo Checking libs
	extra=$$($(SHELL) debian/common/checklibs); \
         if [ -n "$$extra" ]; then                  \
           echo "Extra libraries: $$extra";         \
         fi
	$(SHELL) debian/common/get_shlib_ver
  endif
endif
	@echo done > $@

debian/stamp/install/setools:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/install || mkdir -p debian/stamp/install
	rm -rf               $(TMPTOP)
	$(make_directory)    $(TMPTOP)
	$(make_directory)    $(DOCDIR)/examples
	$(make_directory)    $(BINDIR)
	$(make_directory)    $(SBINDIR)
	$(make_directory)    $(MAN1DIR)
	$(make_directory)    $(MAN8DIR)
	$(make_directory)    $(MENUDIR)
	$(MAKE)              DESTDIR=$(TMPTOP)     install-logwatch
	$(MAKE)              DESTDIR=$(TMPTOP) -C apol      install
	$(MAKE)              DESTDIR=$(TMPTOP) -C seaudit   install
	$(MAKE)              DESTDIR=$(TMPTOP) -C sechecker install
	$(MAKE)              DESTDIR=$(TMPTOP) -C secmds    install
	$(MAKE)              DESTDIR=$(TMPTOP) -C sediff    install
	$(MAKE)              DESTDIR=$(TMPTOP) -C man       install
	$(install_file)      debian/changelog            $(DOCDIR)/changelog.Debian
	$(install_file)      ChangeLog                   $(DOCDIR)/changelog
	$(install_file)      README NEWS TODO KNOWN-BUGS $(DOCDIR)/
	gzip -9frq           $(DOCDIR)/
	chmod 0755           $(SHAREDIR)/setools/3.3/seaudit-report-service
# Make sure the copyright file is not compressed
	$(install_file)      debian/copyright            $(DOCDIR)/copyright
	$(install_script)    debian/example_apol_usage_with_modular_policy.sh           \
                             $(DOCDIR)/examples
	$(install_file)      debian/menuentry             $(MENUDIR)/$(package)
	gzip -9fqr           $(MANDIR)/
	chmod 0644 	     $(LIBDIR)/setools/*/pkgIndex.tcl
	$(strip-exec)
	$(strip-lib)
	@echo done > $@

debian/stamp/install/libsefs4:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/install || mkdir -p debian/stamp/install
	rm -rf               $(TMPTOP)
	$(make_directory)    $(TMPTOP)
	$(make_directory)    $(LIBDIR)
	$(make_directory)    $(DOCDIR)
	$(MAKE)              DESTDIR=$(TMPTOP) -C libsefs install
	rm -f                $(LIBDIR)/*.a
	test ! -L            $(LIBDIR)/libsefs.so    || rm -f  $(LIBDIR)/libsefs.so
# remove the tcl bindings
	test ! -d            $(LIBDIR)/setools       || rm -rf $(LIBDIR)/setools
# and the include files
	test ! -d            $(TMPTOP)$(INCLUDE)     || rm -rf $(TMPTOP)$(INCLUDE)
# and the python stuff
	test ! -d            $(PDIR)                 || rm -rf $(PDIR)
# And java
	test ! -d            $(SHAREDIR)/java        || rm -rf $(SHAREDIR)/java 
	test ! -d            $(SHAREDIR)/setools     || rm -rf $(SHAREDIR)/setools
	rm -f                $(LIBDIR)/libj*
	$(install_file)      debian/changelog            $(DOCDIR)/changelog.Debian
	$(install_file)      ChangeLog                   $(DOCDIR)/changelog
	$(install_file)      README NEWS TODO KNOWN-BUGS $(DOCDIR)/
	gzip -9frq           $(DOCDIR)/
# Make sure the copyright file is not compressed
	$(install_file)      debian/copyright       $(DOCDIR)/copyright
	chmod 0644 	     $(LIBDIR)/*.so.*
	$(strip-lib)
	@echo done > $@

debian/stamp/install/libsefs-dev:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/install || mkdir -p debian/stamp/install
	rm -rf            $(TMPTOP)
	$(make_directory) $(TMPTOP)
	$(make_directory) $(LIBDIR)
	$(make_directory) $(DOCDIR)
	$(MAKE)           DESTDIR=$(TMPTOP) -C libsefs install
	test ! -e         $(LIBDIR)/libsefs.so.$(LIBSEFS_VERSION)   || rm -f $(LIBDIR)/libsefs.so.$(LIBSEFS_VERSION)
	test ! -L         $(LIBDIR)/libsefs.so.$(LIBSEFS_SOVERSION) || rm -f $(LIBDIR)/libsefs.so.$(LIBSEFS_SOVERSION)
# remove the tcl bindings
	test ! -d         $(LIBDIR)/setools       || rm -rf $(LIBDIR)/setools
# and the python stuff
	test ! -d         $(PDIR)                 || rm -rf $(PDIR)
# And java
	test ! -d         $(SHAREDIR)/java        || rm -rf $(SHAREDIR)/java 
	test ! -d         $(SHAREDIR)/setools     || rm -rf $(SHAREDIR)/setools
	rm -f             $(LIBDIR)/libj*
	$(install_file)      debian/changelog            $(DOCDIR)/changelog.Debian
	$(install_file)      ChangeLog                   $(DOCDIR)/changelog
	$(install_file)      README NEWS TODO KNOWN-BUGS $(DOCDIR)/
	gzip -9frq        $(DOCDIR)/
# Make sure the copyright file is not compressed
	$(install_file)   debian/copyright              $(DOCDIR)/copyright
	$(strip-lib)
	@echo done > $@


debian/stamp/install/libseaudit4:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/install || mkdir -p debian/stamp/install
	rm -rf               $(TMPTOP)
	$(make_directory)    $(TMPTOP)
	$(make_directory)    $(LIBDIR)
	$(make_directory)    $(DOCDIR)
	$(MAKE)              DESTDIR=$(TMPTOP) -C libseaudit install
	rm -f                $(LIBDIR)/*.a
	test ! -L            $(LIBDIR)/libseaudit.so || rm -f $(LIBDIR)/libseaudit.so
# remove the tcl bindings
	test ! -d            $(LIBDIR)/setools       || rm -rf $(LIBDIR)/setools
# and the include files
	test ! -d            $(TMPTOP)$(INCLUDE)     || rm -rf $(TMPTOP)$(INCLUDE)
# and the python stuff
	test ! -d            $(PDIR)                 || rm -rf $(PDIR)
# And java
	test ! -d            $(SHAREDIR)/java        || rm -rf $(SHAREDIR)/java 
	test ! -d            $(SHAREDIR)/setools     || rm -rf $(SHAREDIR)/setools
	rm -f                $(LIBDIR)/libj*
	$(install_file)      debian/changelog            $(DOCDIR)/changelog.Debian
	$(install_file)      ChangeLog                   $(DOCDIR)/changelog
	$(install_file)      README NEWS TODO KNOWN-BUGS $(DOCDIR)/
	gzip -9frq           $(DOCDIR)/
# Make sure the copyright file is not compressed
	$(install_file)      debian/copyright       $(DOCDIR)/copyright
	chmod 0644 	     $(LIBDIR)/*.so.*
	$(strip-lib)
	@echo done > $@

debian/stamp/install/libseaudit-dev:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/install || mkdir -p debian/stamp/install
	rm -rf            $(TMPTOP)
	$(make_directory) $(TMPTOP)
	$(make_directory) $(LIBDIR)
	$(make_directory) $(DOCDIR)
	$(MAKE)           DESTDIR=$(TMPTOP) -C libseaudit install
	test ! -f         $(LIBDIR)/libseaudit.so.$(LIBSEAUDIT_VERSION)   || rm -f $(LIBDIR)/libseaudit.so.$(LIBSEAUDIT_VERSION)
	test ! -L         $(LIBDIR)/libseaudit.so.$(LIBSEAUDIT_SOVERSION) || rm -f $(LIBDIR)/libseaudit.so.$(LIBSEAUDIT_SOVERSION)
# remove the tcl bindings
	test ! -d         $(LIBDIR)/setools       || rm -rf $(LIBDIR)/setools
# and the python stuff
	test ! -d         $(PDIR)                 || rm -rf $(PDIR)
# And java
	test ! -d         $(SHAREDIR)/java        || rm -rf $(SHAREDIR)/java 
	test ! -d         $(SHAREDIR)/setools     || rm -rf $(SHAREDIR)/setools
	rm -f             $(LIBDIR)/libj*
	$(install_file)      debian/changelog            $(DOCDIR)/changelog.Debian
	$(install_file)      ChangeLog                   $(DOCDIR)/changelog
	$(install_file)      README NEWS TODO KNOWN-BUGS $(DOCDIR)/
	gzip -9frq        $(DOCDIR)/
# Make sure the copyright file is not compressed
	$(install_file)   debian/copyright              $(DOCDIR)/copyright
	$(strip-lib)
	@echo done > $@


debian/stamp/install/libapol4:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/install || mkdir -p debian/stamp/install
	rm -rf               $(TMPTOP)
	$(make_directory)    $(TMPTOP)
	$(make_directory)    $(LIBDIR)
	$(make_directory)    $(DOCDIR)
	$(MAKE)              DESTDIR=$(TMPTOP) -C libapol install
	rm -f                $(LIBDIR)/*.a
	test ! -L            $(LIBDIR)/libapol.so    || rm -f $(LIBDIR)/libapol.so
# remove the tcl bindings
	test ! -d            $(LIBDIR)/setools       || rm -rf $(LIBDIR)/setools
# and the include files
	test ! -d            $(TMPTOP)$(INCLUDE)     || rm -rf $(TMPTOP)$(INCLUDE)
# and the python stuff
	test ! -d            $(PDIR)                 || rm -rf $(PDIR)
# And java
	test ! -d            $(SHAREDIR)/java        || rm -rf $(SHAREDIR)/java 
	test ! -d            $(SHAREDIR)/setools     || rm -rf $(SHAREDIR)/setools
	rm -f                $(LIBDIR)/libj*
	$(install_file)      debian/changelog            $(DOCDIR)/changelog.Debian
	$(install_file)      ChangeLog                   $(DOCDIR)/changelog
	$(install_file)      README NEWS TODO KNOWN-BUGS $(DOCDIR)/
	gzip -9frq           $(DOCDIR)/
# Make sure the copyright file is not compressed
	$(install_file)      debian/copyright       $(DOCDIR)/copyright
	chmod 0644 	     $(LIBDIR)/*.so.*
	$(strip-lib)
	@echo done > $@

debian/stamp/install/libapol-dev:
	$(checkdir)
	$(REASON)
	rm -rf            $(TMPTOP)
	$(TESTROOT)
	@test -d debian/stamp/install || mkdir -p debian/stamp/install
	$(make_directory) $(TMPTOP)
	$(make_directory) $(LIBDIR)
	$(make_directory) $(DOCDIR)
	$(MAKE)           DESTDIR=$(TMPTOP) -C libapol install
	test ! -f         $(LIBDIR)/libapol.so.$(LIBAPOL_VERSION)   || rm -f $(LIBDIR)/libapol.so.$(LIBAPOL_VERSION)
	test ! -L         $(LIBDIR)/libapol.so.$(LIBAPOL_SOVERSION) || rm -f $(LIBDIR)/libapol.so.$(LIBAPOL_SOVERSION)
# remove the tcl bindings
	test ! -d         $(LIBDIR)/setools       || rm -rf $(LIBDIR)/setools
# and the python stuff
	test ! -d         $(PDIR)                 || rm -rf $(PDIR)
# And java
	test ! -d         $(SHAREDIR)/java        || rm -rf $(SHAREDIR)/java 
	test ! -d         $(SHAREDIR)/setools     || rm -rf $(SHAREDIR)/setools
	rm -f             $(LIBDIR)/libj*
	$(install_file)      debian/changelog            $(DOCDIR)/changelog.Debian
	$(install_file)      ChangeLog                   $(DOCDIR)/changelog
	$(install_file)      README NEWS TODO KNOWN-BUGS $(DOCDIR)/
	gzip -9frq        $(DOCDIR)/
# Make sure the copyright file is not compressed
	$(install_file)   debian/copyright              $(DOCDIR)/copyright
	$(strip-lib)
	@echo done > $@

debian/stamp/install/libpoldiff1:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/install || mkdir -p debian/stamp/install
	rm -rf               $(TMPTOP)
	$(make_directory)    $(TMPTOP)
	$(make_directory)    $(LIBDIR)
	$(make_directory)    $(DOCDIR)
	$(MAKE)              DESTDIR=$(TMPTOP) -C libpoldiff install
	rm -f                $(LIBDIR)/*.a
	test ! -L            $(LIBDIR)/libpoldiff.so    || rm -f $(LIBDIR)/libpoldiff.so
# remove the tcl bindings
	test ! -d            $(LIBDIR)/setools       || rm -rf $(LIBDIR)/setools
# and the include files
	test ! -d            $(TMPTOP)$(INCLUDE)     || rm -rf $(TMPTOP)$(INCLUDE)
# and the python stuff
	test ! -d            $(PDIR)                 || rm -rf $(PDIR)
# And java
	test ! -d            $(SHAREDIR)/java        || rm -rf $(SHAREDIR)/java 
	test ! -d            $(SHAREDIR)/setools     || rm -rf $(SHAREDIR)/setools
	rm -f                $(LIBDIR)/libj*
	$(install_file)      debian/changelog            $(DOCDIR)/changelog.Debian
	$(install_file)      ChangeLog                   $(DOCDIR)/changelog
	$(install_file)      README NEWS TODO KNOWN-BUGS $(DOCDIR)/
	gzip -9frq           $(DOCDIR)/
# Make sure the copyright file is not compressed
	$(install_file)      debian/copyright       $(DOCDIR)/copyright
	chmod 0644 	     $(LIBDIR)/*.so.*
	$(strip-lib)
	@echo done > $@

debian/stamp/install/libpoldiff-dev:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/install || mkdir -p debian/stamp/install
	rm -rf            $(TMPTOP)
	$(make_directory) $(TMPTOP)
	$(make_directory) $(LIBDIR)
	$(make_directory) $(DOCDIR)
	$(MAKE)           DESTDIR=$(TMPTOP) -C libpoldiff install
	test ! -f         $(LIBDIR)/libpoldiff.so.$(LIBPOLDIFF_VERSION)   || rm -f $(LIBDIR)/libpoldiff.so.$(LIBPOLDIFF_VERSION)
	test ! -L         $(LIBDIR)/libpoldiff.so.$(LIBPOLDIFF_SOVERSION) || rm -f $(LIBDIR)/libpoldiff.so.$(LIBPOLDIFF_SOVERSION)
# remove the tcl bindings
	test ! -d         $(LIBDIR)/setools       || rm -rf $(LIBDIR)/setools
# and the python stuff
	test ! -d         $(PDIR)                 || rm -rf $(PDIR)
# And java
	test ! -d         $(SHAREDIR)/java        || rm -rf $(SHAREDIR)/java 
	test ! -d         $(SHAREDIR)/setools     || rm -rf $(SHAREDIR)/setools
	rm -f             $(LIBDIR)/libj*
	$(install_file)      debian/changelog            $(DOCDIR)/changelog.Debian
	$(install_file)      ChangeLog                   $(DOCDIR)/changelog
	$(install_file)      README NEWS TODO KNOWN-BUGS $(DOCDIR)/
	gzip -9frq        $(DOCDIR)/
# Make sure the copyright file is not compressed
	$(install_file)   debian/copyright              $(DOCDIR)/copyright
	$(strip-lib)
	@echo done > $@

debian/stamp/install/libqpol1:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/install || mkdir -p debian/stamp/install
	rm -rf               $(TMPTOP)
	$(make_directory)    $(TMPTOP)
	$(make_directory)    $(LIBDIR)
	$(make_directory)    $(DOCDIR)
	$(MAKE)              DESTDIR=$(TMPTOP) -C libqpol install
	rm -f                $(LIBDIR)/*.a
	test ! -L            $(LIBDIR)/libqpol.so    || rm -f $(LIBDIR)/libqpol.so
# remove the tcl bindings
	test ! -d            $(LIBDIR)/setools       || rm -rf $(LIBDIR)/setools
# and the include files
	test ! -d            $(TMPTOP)$(INCLUDE)     || rm -rf $(TMPTOP)$(INCLUDE)
# and the python stuff
	test ! -d            $(PDIR)                 || rm -rf $(PDIR)
# And java
	test ! -d            $(SHAREDIR)/java        || rm -rf $(SHAREDIR)/java 
	test ! -d            $(SHAREDIR)/setools     || rm -rf $(SHAREDIR)/setools
	rm -f                $(LIBDIR)/libj*
	$(install_file)      debian/changelog            $(DOCDIR)/changelog.Debian
	$(install_file)      ChangeLog                   $(DOCDIR)/changelog
	$(install_file)      README NEWS TODO KNOWN-BUGS $(DOCDIR)/
	gzip -9frq           $(DOCDIR)/
# Make sure the copyright file is not compressed
	$(install_file)      debian/copyright       $(DOCDIR)/copyright
	chmod 0644 	     $(LIBDIR)/*.so.*
	$(strip-lib)
	@echo done > $@

debian/stamp/install/libqpol-dev:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/install || mkdir -p debian/stamp/install
	rm -rf            $(TMPTOP)
	$(make_directory) $(TMPTOP)
	$(make_directory) $(LIBDIR)
	$(make_directory) $(DOCDIR)
	$(MAKE)           DESTDIR=$(TMPTOP) -C libqpol install
	test ! -f         $(LIBDIR)/libqpol.so.$(LIBQPOL_VERSION)   || rm -f $(LIBDIR)/libqpol.so.$(LIBQPOL_VERSION)
	test ! -L         $(LIBDIR)/libqpol.so.$(LIBQPOL_SOVERSION) || rm -f $(LIBDIR)/libqpol.so.$(LIBQPOL_SOVERSION)
# remove the tcl bindings
	test ! -d         $(LIBDIR)/setools       || rm -rf $(LIBDIR)/setools
# and the python stuff
	test ! -d         $(PDIR)                 || rm -rf $(PDIR)
# And java
	test ! -d         $(SHAREDIR)/java        || rm -rf $(SHAREDIR)/java 
	test ! -d         $(SHAREDIR)/setools     || rm -rf $(SHAREDIR)/setools
	rm -f             $(LIBDIR)/libj*
	$(install_file)      debian/changelog            $(DOCDIR)/changelog.Debian
	$(install_file)      ChangeLog                   $(DOCDIR)/changelog
	$(install_file)      README NEWS TODO KNOWN-BUGS $(DOCDIR)/
	gzip -9frq           $(DOCDIR)/
	gzip -9frq        $(DOCDIR)/
# Make sure the copyright file is not compressed
	$(install_file)   debian/copyright              $(DOCDIR)/copyright
	$(strip-lib)
	@echo done > $@

debian/stamp/install/libsetools-jni:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/install || mkdir -p debian/stamp/install
	rm -rf               $(TMPTOP)
	$(make_directory)    $(TMPTOP)
	$(make_directory)    $(LIBDIR)/jni
	$(make_directory)    $(DOCDIR)
	$(MAKE)              DESTDIR=$(TMPTOP) -C libapol     install
	$(MAKE)              DESTDIR=$(TMPTOP) -C libpoldiff  install
	$(MAKE)              DESTDIR=$(TMPTOP) -C libqpol     install
	$(MAKE)              DESTDIR=$(TMPTOP) -C libseaudit  install
	$(MAKE)              DESTDIR=$(TMPTOP) -C libsefs     install
	mv                   $(LIBDIR)/libj*         $(LIBDIR)/jni
	rm -f                $(LIBDIR)/*.a
	rm -f                $(LIBDIR)/*.so*
# remove the tcl bindings
	test ! -d            $(LIBDIR)/setools       || rm -rf $(LIBDIR)/setools
# and the include files
	test ! -d            $(TMPTOP)$(INCLUDE)     || rm -rf $(TMPTOP)$(INCLUDE)
# and the python stuff
	test ! -d            $(PDIR)                 || rm -rf $(PDIR)
# And java
	test ! -d            $(SHAREDIR)/java         || rm -rf $(SHAREDIR)/java 
	test ! -d            $(SHAREDIR)/setools     || rm -rf $(SHAREDIR)/setools
	$(install_file)      debian/changelog            $(DOCDIR)/changelog.Debian
	$(install_file)      ChangeLog                   $(DOCDIR)/changelog
	$(install_file)      README NEWS TODO KNOWN-BUGS $(DOCDIR)/
	gzip -9frq           $(DOCDIR)/
# Make sure the copyright file is not compressed
	$(install_file)      debian/copyright       $(DOCDIR)/copyright
	$(strip-lib)
	@echo done > $@

debian/stamp/install/libsetools-java:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/install || mkdir -p debian/stamp/install
	rm -rf               $(TMPTOP)
	$(make_directory)    $(TMPTOP)
	$(make_directory)    $(LIBDIR)
	$(make_directory)    $(DOCDIR)
	$(MAKE)              DESTDIR=$(TMPTOP) -C libapol     install
	$(MAKE)              DESTDIR=$(TMPTOP) -C libpoldiff  install
	$(MAKE)              DESTDIR=$(TMPTOP) -C libqpol     install
	$(MAKE)              DESTDIR=$(TMPTOP) -C libseaudit  install
	$(MAKE)              DESTDIR=$(TMPTOP) -C libsefs     install
	rm -rf               $(LIBDIR)
# remove the include files
	test ! -d            $(TMPTOP)$(INCLUDE)     || rm -rf $(TMPTOP)$(INCLUDE)
	$(install_file)      debian/changelog            $(DOCDIR)/changelog.Debian
	$(install_file)      ChangeLog                   $(DOCDIR)/changelog
	$(install_file)      README NEWS TODO KNOWN-BUGS $(DOCDIR)/
	gzip -9frq           $(DOCDIR)/
	(cd  $(SHAREDIR)/java; ln -sf ../setools/3.3/apol.jar)
	(cd  $(SHAREDIR)/java; ln -sf ../setools/3.3/poldiff.jar)
	(cd  $(SHAREDIR)/java; ln -sf ../setools/3.3/qpol.jar)
	(cd  $(SHAREDIR)/java; ln -sf ../setools/3.3/seaudit.jar)
	(cd  $(SHAREDIR)/java; ln -sf ../setools/3.3/sefs.jar)
# Make sure the copyright file is not compressed
	$(install_file)      debian/copyright       $(DOCDIR)/copyright
	@echo done > $@


debian/stamp/install/libsetools-tcl:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/install || mkdir -p debian/stamp/install
	rm -rf               $(TMPTOP)
	$(make_directory)    $(TMPTOP)
	$(make_directory)    $(LIBDIR)
	$(make_directory)    $(DOCDIR)
	$(MAKE)              DESTDIR=$(TMPTOP) -C libapol     install
	$(MAKE)              DESTDIR=$(TMPTOP) -C libpoldiff  install
	$(MAKE)              DESTDIR=$(TMPTOP) -C libqpol     install
	$(MAKE)              DESTDIR=$(TMPTOP) -C libseaudit  install
	$(MAKE)              DESTDIR=$(TMPTOP) -C libsefs     install
	rm -fr               $(BINDIR)
	rm -f                $(LIBDIR)/lib*
# and the include files
	test ! -d            $(TMPTOP)$(INCLUDE)     || rm -rf $(TMPTOP)$(INCLUDE)
# and the python stuff
	test ! -d            $(PDIR)                 || rm -rf $(PDIR)
# And java
	test ! -d            $(SHAREDIR)/java        || rm -rf $(SHAREDIR)/java 
	test ! -d            $(SHAREDIR)/setools     || rm -rf $(SHAREDIR)/setools
	$(install_file)      debian/changelog            $(DOCDIR)/changelog.Debian
	$(install_file)      ChangeLog                   $(DOCDIR)/changelog
	$(install_file)      README NEWS TODO KNOWN-BUGS $(DOCDIR)/
	gzip -9frq           $(DOCDIR)/
# Make sure the copyright file is not compressed
	$(install_file)      debian/copyright       $(DOCDIR)/copyright
	chmod 0644 	     $(LIBDIR)/setools/*/pkgIndex.tcl
	$(strip-lib)
	@echo done > $@


debian/stamp/install/python-setools:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/install || mkdir -p debian/stamp/install
	rm -rf               $(TMPTOP)
	$(make_directory)    $(TMPTOP)
	$(make_directory)    $(LIBDIR)
	$(make_directory)    $(DOCDIR)
	$(make_directory)    $(MODULES_DIR)/
	$(make_directory)    $(EXTENSIONS_DIR)/python$$PYTHON_VERSION/
	$(MAKE)              DESTDIR=$(TMPTOP) -C libapol     install
	$(MAKE)              DESTDIR=$(TMPTOP) -C libpoldiff  install
	$(MAKE)              DESTDIR=$(TMPTOP) -C libqpol     install
	$(MAKE)              DESTDIR=$(TMPTOP) -C libseaudit  install
	$(MAKE)              DESTDIR=$(TMPTOP) -C libsefs     install
	rm -f                $(LIBDIR)/lib*
# remove the tcl bindings
	test ! -d            $(LIBDIR)/setools       || rm -rf $(LIBDIR)/setools
# and the include files
	test ! -d            $(TMPTOP)$(INCLUDE)     || rm -rf $(TMPTOP)$(INCLUDE)
# And java
	test ! -d            $(SHAREDIR)/java         || rm -rf $(SHAREDIR)/java 
	test ! -d            $(SHAREDIR)/setools     || rm -rf $(SHAREDIR)/setools
	$(install_file)      debian/changelog            $(DOCDIR)/changelog.Debian
	$(install_file)      ChangeLog                   $(DOCDIR)/changelog
	$(install_file)      README NEWS TODO KNOWN-BUGS $(DOCDIR)/
	gzip -9frq           $(DOCDIR)/
# Make sure the copyright file is not compressed
	$(install_file)      debian/copyright       $(DOCDIR)/copyright
	mv -f                $(PDIR)/*-packages/setools/*.py $(MODULES_DIR)/;
	mv -f                $(PDIR)/*-packages/setools/*    $(EXTENSIONS_DIR)/python$$PYTHON_VERSION/;
	rm -rf               $(PDIR)
	$(strip-lib)
	@echo done > $@


debian/stamp/binary/setools:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/binary || mkdir -p debian/stamp/binary
	$(make_directory)    $(TMPTOP)/DEBIAN
	$(install_file)      debian/conffiles        $(TMPTOP)/DEBIAN/
	$(install_script)    debian/setools.postrm   $(TMPTOP)/DEBIAN/postrm
	$(install_script)    debian/setools.postinst $(TMPTOP)/DEBIAN/postinst
	k=`find $(TMPTOP) -type f | ( while read i; do          \
            if file -b $$i | egrep -q "^ELF.*executable.*dynamically linked" ; then   \
                j="$$j $$i";                                     \
            fi;                                                  \
         done; echo $$j; )`; if [ -n "$$k" ]; then               \
           if [ -z "$$LD_LIBRARY_PATH" ]; then                    \
            LD_LIBRARY_PATH=$(LIB_PATH) dpkg-shlibdeps $$k;      \
            else                                                 \
              LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:$(LIB_PATH) dpkg-shlibdeps $$k; \
            fi;                                                  \
         fi
	dpkg-gencontrol      -p$(package) -isp      -P$(TMPTOP)
	$(create_md5sum)     $(TMPTOP)
	chown -R root:root   $(TMPTOP)
	chmod -R u+w,go=rX   $(TMPTOP)
	dpkg --build         $(TMPTOP) ..
	@echo done > $@

debian/stamp/binary/libsefs4:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/binary || mkdir -p debian/stamp/binary
	$(make_directory)                                       $(TMPTOP)/DEBIAN
	$(install_file)	                 debian/libsefs4.shlibs $(TMPTOP)/DEBIAN/shlibs 
	sed -e 's/%REPLACEME%/$(package)/g' < debian/postrm   > $(TMPTOP)/DEBIAN/postrm
	sed -e 's/%REPLACEME%/$(package)/g' < debian/postinst > $(TMPTOP)/DEBIAN/postinst
	chmod 0755                                              $(TMPTOP)/DEBIAN/postrm
	chmod 0755                                              $(TMPTOP)/DEBIAN/postinst
	dpkg-gensymbols      -p$(package)            -P$(TMPTOP) -c4
	k=`find $(TMPTOP) -type f | ( while read i; do		 \
	    if file -b $$i | egrep -q "^ELF.*shared object"; then	 \
	      j="$$j $$i";					 \
	    fi;							 \
	   done; echo $$j; )`; if [ -n "$$k" ]; then                   \
           if [ -z "$$LD_LIBRARY_PATH" ]; then                    \
            LD_LIBRARY_PATH=$(LIB_PATH) dpkg-shlibdeps $$k;      \
            else                                                 \
              LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:$(LIB_PATH) dpkg-shlibdeps $$k; \
            fi;                                                  \
         fi
	dpkg-gencontrol	     -p$(package) -isp	     -P$(TMPTOP)
	$(create_md5sum)     $(TMPTOP)
	chown -R root:root   $(TMPTOP)
	chmod -R u+w,go=rX   $(TMPTOP)
	dpkg --build	     $(TMPTOP) ..
	@echo done > $@

debian/stamp/binary/libsefs-dev:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/binary || mkdir -p debian/stamp/binary
	$(make_directory)    $(TMPTOP)/DEBIAN
	dpkg-gencontrol	     -p$(package) -isp	     -P$(TMPTOP)
	$(create_md5sum)     $(TMPTOP)
	chown -R root:root   $(TMPTOP)
	chmod -R u+w,go=rX   $(TMPTOP)
	dpkg --build	     $(TMPTOP) ..
	@echo done > $@


debian/stamp/binary/libseaudit4:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/binary || mkdir -p debian/stamp/binary
	$(make_directory)                                       $(TMPTOP)/DEBIAN
	$(install_file)	              debian/libseaudit4.shlibs $(TMPTOP)/DEBIAN/shlibs
	sed -e 's/%REPLACEME%/$(package)/g' < debian/postrm   > $(TMPTOP)/DEBIAN/postrm
	sed -e 's/%REPLACEME%/$(package)/g' < debian/postinst > $(TMPTOP)/DEBIAN/postinst
	chmod 0755                                              $(TMPTOP)/DEBIAN/postrm
	chmod 0755                                              $(TMPTOP)/DEBIAN/postinst
	dpkg-gensymbols      -p$(package)            -P$(TMPTOP) -c4
	k=`find $(TMPTOP) -type f | ( while read i; do		 \
	    if file -b $$i | egrep -q "^ELF.*shared object"; then	 \
	      j="$$j $$i";					 \
	    fi;							 \
	   done; echo $$j; )`; if [ -n "$$k" ]; then                   \
           if [ -z "$$LD_LIBRARY_PATH" ]; then                    \
            LD_LIBRARY_PATH=$(LIB_PATH) dpkg-shlibdeps $$k;      \
            else                                                 \
              LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:$(LIB_PATH) dpkg-shlibdeps $$k; \
            fi;                                                  \
         fi
	dpkg-gencontrol	     -p$(package) -isp	     -P$(TMPTOP)
	$(create_md5sum)     $(TMPTOP)
	chown -R root:root   $(TMPTOP)
	chmod -R u+w,go=rX   $(TMPTOP)
	dpkg --build	     $(TMPTOP) ..
	@echo done > $@

debian/stamp/binary/libseaudit-dev:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/binary || mkdir -p debian/stamp/binary
	$(make_directory)    $(TMPTOP)/DEBIAN
	dpkg-gencontrol	     -p$(package) -isp	     -P$(TMPTOP)
	$(create_md5sum)     $(TMPTOP)
	chown -R root:root   $(TMPTOP)
	chmod -R u+w,go=rX   $(TMPTOP)
	dpkg --build	     $(TMPTOP) ..
	@echo done > $@

debian/stamp/binary/libapol4:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/binary || mkdir -p debian/stamp/binary
	$(make_directory)                                       $(TMPTOP)/DEBIAN
	$(install_file)	                 debian/libapol4.shlibs $(TMPTOP)/DEBIAN/shlibs
	sed -e 's/%REPLACEME%/$(package)/g' < debian/postrm   > $(TMPTOP)/DEBIAN/postrm
	sed -e 's/%REPLACEME%/$(package)/g' < debian/postinst > $(TMPTOP)/DEBIAN/postinst
	chmod 0755                                              $(TMPTOP)/DEBIAN/postrm
	chmod 0755                                              $(TMPTOP)/DEBIAN/postinst
	dpkg-gensymbols      -p$(package)            -P$(TMPTOP) -c4
	k=`find $(TMPTOP) -type f | ( while read i; do		 \
	    if file -b $$i | egrep -q "^ELF.*shared object"; then	 \
	      j="$$j $$i";					 \
	    fi;							 \
	   done; echo $$j; )`; if [ -n "$$k" ]; then                   \
           if [ -z "$$LD_LIBRARY_PATH" ]; then                    \
            LD_LIBRARY_PATH=$(LIB_PATH) dpkg-shlibdeps $$k;      \
            else                                                 \
              LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:$(LIB_PATH) dpkg-shlibdeps $$k; \
            fi;                                                  \
         fi
	dpkg-gencontrol	     -p$(package) -isp	     -P$(TMPTOP)
	$(create_md5sum)     $(TMPTOP)
	chown -R root:root   $(TMPTOP)
	chmod -R u+w,go=rX   $(TMPTOP)
	dpkg --build	     $(TMPTOP) ..
	@echo done > $@

debian/stamp/binary/libapol-dev:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/binary || mkdir -p debian/stamp/binary
	$(make_directory)    $(TMPTOP)/DEBIAN
	dpkg-gencontrol	     -p$(package) -isp	     -P$(TMPTOP)
	$(create_md5sum)     $(TMPTOP)
	chown -R root:root   $(TMPTOP)
	chmod -R u+w,go=rX   $(TMPTOP)
	dpkg --build	     $(TMPTOP) ..
	@echo done > $@


debian/stamp/binary/libpoldiff1:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/binary || mkdir -p debian/stamp/binary
	$(make_directory)                                       $(TMPTOP)/DEBIAN
	$(install_file)	              debian/libpoldiff1.shlibs $(TMPTOP)/DEBIAN/shlibs
	sed -e 's/%REPLACEME%/$(package)/g' < debian/postrm   > $(TMPTOP)/DEBIAN/postrm
	sed -e 's/%REPLACEME%/$(package)/g' < debian/postinst > $(TMPTOP)/DEBIAN/postinst
	chmod 0755                                              $(TMPTOP)/DEBIAN/postrm
	chmod 0755                                              $(TMPTOP)/DEBIAN/postinst
	dpkg-gensymbols      -p$(package)            -P$(TMPTOP) -c4
	k=`find $(TMPTOP) -type f | ( while read i; do		 \
	    if file -b $$i | egrep -q "^ELF.*shared object"; then	 \
	      j="$$j $$i";					 \
	    fi;							 \
	   done; echo $$j; )`; if [ -n "$$k" ]; then                   \
           if [ -z "$$LD_LIBRARY_PATH" ]; then                    \
            LD_LIBRARY_PATH=$(LIB_PATH) dpkg-shlibdeps $$k;      \
            else                                                 \
              LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:$(LIB_PATH) dpkg-shlibdeps $$k; \
            fi;                                                  \
         fi
	dpkg-gencontrol	     -p$(package) -isp	     -P$(TMPTOP)
	$(create_md5sum)     $(TMPTOP)
	chown -R root:root   $(TMPTOP)
	chmod -R u+w,go=rX   $(TMPTOP)
	dpkg --build	     $(TMPTOP) ..
	@echo done > $@

debian/stamp/binary/libpoldiff-dev:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/binary || mkdir -p debian/stamp/binary
	$(make_directory)    $(TMPTOP)/DEBIAN
	dpkg-gencontrol	     -p$(package) -isp	     -P$(TMPTOP)
	$(create_md5sum)     $(TMPTOP)
	chown -R root:root   $(TMPTOP)
	chmod -R u+w,go=rX   $(TMPTOP)
	dpkg --build	     $(TMPTOP) ..
	@echo done > $@


debian/stamp/binary/libqpol1:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/binary || mkdir -p debian/stamp/binary
	$(make_directory)                                       $(TMPTOP)/DEBIAN
	$(install_file)	                 debian/libqpol1.shlibs $(TMPTOP)/DEBIAN/shlibs
	sed -e 's/%REPLACEME%/$(package)/g' < debian/postrm   > $(TMPTOP)/DEBIAN/postrm
	sed -e 's/%REPLACEME%/$(package)/g' < debian/postinst > $(TMPTOP)/DEBIAN/postinst
	chmod 0755                                              $(TMPTOP)/DEBIAN/postrm
	chmod 0755                                              $(TMPTOP)/DEBIAN/postinst
	dpkg-gensymbols      -p$(package)            -P$(TMPTOP) -c4
	k=`find $(TMPTOP) -type f | ( while read i; do		 \
	    if file -b $$i | egrep -q "^ELF.*shared object"; then	 \
	      j="$$j $$i";					 \
	    fi;							 \
	   done; echo $$j; )`; if [ -n "$$k" ]; then                    \
           if [ -z "$$LD_LIBRARY_PATH" ]; then                    \
            LD_LIBRARY_PATH=$(LIB_PATH) dpkg-shlibdeps $$k;      \
            else                                                 \
              LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:$(LIB_PATH) dpkg-shlibdeps $$k; \
            fi;                                                  \
         fi
	dpkg-gencontrol	     -p$(package) -isp	     -P$(TMPTOP)
	$(create_md5sum)     $(TMPTOP)
	chown -R root:root   $(TMPTOP)
	chmod -R u+w,go=rX   $(TMPTOP)
	dpkg --build	     $(TMPTOP) ..
	@echo done > $@

debian/stamp/binary/libqpol-dev:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/binary || mkdir -p debian/stamp/binary
	$(make_directory)    $(TMPTOP)/DEBIAN
	dpkg-gencontrol	     -p$(package) -isp	     -P$(TMPTOP)
	$(create_md5sum)     $(TMPTOP)
	chown -R root:root   $(TMPTOP)
	chmod -R u+w,go=rX   $(TMPTOP)
	dpkg --build	     $(TMPTOP) ..
	@echo done > $@


debian/stamp/binary/libsetools-jni:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/binary || mkdir -p debian/stamp/binary
	$(make_directory)    $(TMPTOP)/DEBIAN
	$(get-shlib-deps)
	dpkg-gencontrol      -p$(package) -isp      -P$(TMPTOP)
	$(create_md5sum)     $(TMPTOP)
	chown -R root:root   $(TMPTOP)
	chmod -R u+w,go=rX   $(TMPTOP)
	dpkg --build         $(TMPTOP) ..
	@echo done > $@

debian/stamp/binary/libsetools-java:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/binary || mkdir -p debian/stamp/binary
	$(make_directory)    $(TMPTOP)/DEBIAN
	dpkg-gencontrol      -p$(package) -isp      -P$(TMPTOP)
	$(create_md5sum)     $(TMPTOP)
	chown -R root:root   $(TMPTOP)
	chmod -R u+w,go=rX   $(TMPTOP)
	dpkg --build         $(TMPTOP) ..
	@echo done > $@

debian/stamp/binary/libsetools-tcl:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/binary || mkdir -p debian/stamp/binary
	$(make_directory)    $(TMPTOP)/DEBIAN
	k=`find $(TMPTOP) -type f | ( while read i; do          \
            if file -b $$i | egrep -q "^ELF.*executable.*dynamically linked" ; then   \
                j="$$j $$i";                                     \
            fi;                                                  \
         done; echo $$j; )`; if [ -n "$$k" ]; then                    \
           if [ -z "$$LD_LIBRARY_PATH" ]; then                    \
            LD_LIBRARY_PATH=$(LIB_PATH) dpkg-shlibdeps $$k;      \
            else                                                 \
              LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:$(LIB_PATH) dpkg-shlibdeps $$k; \
            fi;                                                  \
         fi
	dpkg-gencontrol      -p$(package) -isp      -P$(TMPTOP)
	$(create_md5sum)     $(TMPTOP)
	chown -R root:root   $(TMPTOP)
	chmod -R u+w,go=rX   $(TMPTOP)
	dpkg --build         $(TMPTOP) ..
	@echo done > $@

debian/stamp/binary/python-setools:
	$(checkdir)
	$(REASON)
	$(TESTROOT)
	@test -d debian/stamp/binary || mkdir -p debian/stamp/binary
	$(make_directory)    $(TMPTOP)/DEBIAN
	$(install_script)    debian/python_prerm             $(TMPTOP)/DEBIAN/prerm
	$(install_script)    debian/python_postinst          $(TMPTOP)/DEBIAN/postinst
	echo 'python:Depends=python (>= $(PYTHON_VERSION)), python (<< $(STOP_VERSION))' > \
                             debian/substvars;
	echo 'python:Provides=python$(PYTHON_VERSION)-setools' >> debian/substvars
	find $(EXTENSIONS_DIR) -type f \( -name \*\.pyc -o -name \*\.pyo \) -exec rm {} \;
	k=`find $(TMPTOP) -type f | ( while read i; do          \
            if file -b $$i | egrep -q "^ELF.*shared object" ; then   \
                j="$$j $$i";                                     \
            fi;                                                  \
         done; echo $$j; )`; if [ -n "$$k" ]; then                    \
           if [ -z "$$LD_LIBRARY_PATH" ]; then                    \
              LD_LIBRARY_PATH=$(LIB_PATH) dpkg-shlibdeps $$k;      \
            else                                                 \
              LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:$(LIB_PATH) dpkg-shlibdeps $$k; \
            fi;                                                  \
         fi
	dpkg-gencontrol      -p$(package) -isp      -P$(TMPTOP)
	$(create_md5sum)     $(TMPTOP)
	chown -R root:root   $(TMPTOP)
	chmod -R u+w,go=rX   $(TMPTOP)
	dpkg --build         $(TMPTOP) ..
	@echo done > $@
