#!/bin/sh -e

MY_CROSS_ARCH ?= aarch64-buildroot-linux-musl
MY_CROSS_PATH ?= /opt/aarch64-buildroot-linux-musl/bin
MY_CROSS_PREFIX ?= $(MY_CROSS_PATH)/$(MY_CROSS_ARCH)-
MY_CROSS_OPENSSL_MACHINE ?= $(word 1, $(subst -, ,$(MY_CROSS_ARCH)))
MY_CROSS_OPENSSL_LONG ?= $(word 3, $(subst -, ,$(MY_CROSS_ARCH)))-$(MY_CROSS_OPENSSL_MACHINE)

OPT_CFLAGS = -ffunction-sections -fdata-sections -flto -fuse-linker-plugin -ffat-lto-objects -Os -flto=auto
OPT_LDFLAGS = -flto -flto=auto -fuse-linker-plugin -ffat-lto-objects -Wl,--gc-sections -Os -flto-partition=one

MODULE_BLACKLIST ?=

CC ?= $(MY_CROSS_PREFIX)gcc

check_cc_flag = $(if $(shell if $(CC) $(1) -Wl,--help -xc -o /dev/null /dev/null >/dev/null 2>/dev/null; then echo a; fi; ),$(1),)

OPT_CFLAGS := $(foreach cflag,$(OPT_CFLAGS),$(call check_cc_flag,$(cflag)))
OPT_LDFLAGS := $(foreach cflag,$(OPT_LDFLAGS),$(call check_cc_flag,$(cflag)))

SRC_PATH_ABS=$(shell pwd)

BUILD_DIR=build
OUTPUT_DIR=final

BUILD_DIR_ABS=$(SRC_PATH_ABS)/$(BUILD_DIR)

PY_BUILD_DIR=$(BUILD_DIR)/pybuild_$(Python_VER)
PY_BUILD_DIR_ABS=$(SRC_PATH_ABS)/$(PY_BUILD_DIR)

.PHONY: clean distclean download bla all
clean:
	-rm -rf $(BUILD_DIR) $(OUTPUT_DIR)

distclean: clean
	-rm -rf *.tar.gz *.tar.xz


# .ONESHELL:
# .SHELLFLAGS = -e


nl:=$(strip \)

define tar_xz_template =
$(1)-$$($(1)_VER)_tar_xz ?= $(1)-$$($(1)_VER).tar.xz
$(1)_build_dir ?= $(BUILD_DIR)

$$($(1)-$$($(1)_VER)_tar_xz):
	wget $$($(1)_LINK)$$($(1)-$$($(1)_VER)_tar_xz)

$$($(1)_build_dir)/$(1)-$$($(1)_VER)/ : $$($(1)-$$($(1)_VER)_tar_xz) | $$($(1)_build_dir)/
	(set -e; $(nl)
	cd $$($(1)_build_dir); $(nl)
	tar -xJf $$(SRC_PATH_ABS)/$$^; $(nl)
	)

endef

define tar_gz_template =
$(1)-$$($(1)_VER)_tar_gz ?= $(1)-$$($(1)_VER).tar.gz
$(1)_build_dir ?= $(BUILD_DIR)

$$($(1)-$$($(1)_VER)_tar_gz):
	wget $$($(1)_LINK)$$($(1)-$$($(1)_VER)_tar_gz)

$$($(1)_build_dir)/$(1)-$$($(1)_VER)/ : $$($(1)-$$($(1)_VER)_tar_gz) | $$($(1)_build_dir)/
	(set -e; $(nl)
	cd $$($(1)_build_dir); $(nl)
	tar -xzf $$(SRC_PATH_ABS)/$$^; $(nl)
	)

endef

openssl_VER ?= 1.1.1l
bzip2_VER ?= 1.0.8
libffi_VER ?= 3.4.2
ncurses_VER ?= 6.2
readline_VER ?= 8.1
gdbm_VER ?= 1.23
sqlite-autoconf_VER ?= 3380100
Python_VER ?= 3.9.7
xz_VER ?= 5.2.5
zlib_VER ?= 1.2.12
util-linux_VER ?= 2.37.4
expat_VER ?= 2.5.0
mpdecimal_VER ?= 2.5.1

ifeq ($(USE_EXTERNAL_EXPAT),y)
_ADDITIONAL_PY_CONF_FLAGS += --with-system-expat
_ADDITIONAL_PY_CFLAGS +=
_ADDITIONAL_EXT_MODS += expat
endif

ifeq ($(USE_EXTERNAL_MPDECIMAL),y)
_ADDITIONAL_PY_CONF_FLAGS += --with-system-libmpdec
_ADDITIONAL_PY_CFLAGS += -fwrapv # python with gcc>=10.3 doesnt compile with fwrapv (by their mistake I think)
_ADDITIONAL_EXT_MODS += mpdecimal
endif

ifeq ($(USE_NCURSES_WIDE_CHAR), y)
_NCURSES_LIB =ncursesw
_NCURSES_EXT_CONF_FLAGS += --enable-widec
else
_NCURSES_LIB =ncurses
endif

# TODO: Add option to use wchar in ncurses: --enable-widec

_ADDITIONAL_PY_CONF_FLAGS += --with-pkg-config=no --enable-optimizations=no

_combine = $(word 1, $1).$(word 2, $1)
util-linux_SHORT_VER ?= $(call _combine, $(subst ., ,$(util-linux_VER)))

openssl_LINK ?= https://www.openssl.org/source/
bzip2_LINK ?= https://sourceware.org/pub/bzip2/
libffi_LINK ?= https://github.com/libffi/libffi/releases/download/v$(libffi_VER)/
ncurses_LINK ?= https://ftp.gnu.org/pub/gnu/ncurses/
readline_LINK ?= https://ftp.gnu.org/gnu/readline/
gdbm_LINK ?= https://ftp.gnu.org/gnu/gdbm/
sqlite-autoconf_LINK ?= https://www.sqlite.org/2022/
Python_LINK ?= https://www.python.org/ftp/python/$(Python_VER)/
xz_LINK ?= https://tukaani.org/xz/
zlib_LINK ?= https://zlib.net/fossils/
util-linux_LINK ?= https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v$(util-linux_SHORT_VER)/
expat_LINK ?= https://github.com/libexpat/libexpat/releases/download/R_$(subst .,_,$(expat_VER))/
mpdecimal_LINK ?= https://www.bytereef.org/software/mpdecimal/releases/

#bzip2-1.0.8_tar_gz = bzip2-latest.tar.gz

Python_build_dir = $(PY_BUILD_DIR)

TAR_XZ_PACKAGES = Python xz util-linux expat
TAR_GZ_PACKAGES = zlib openssl bzip2 libffi ncurses readline gdbm sqlite-autoconf mpdecimal

$(foreach package,$(TAR_XZ_PACKAGES),$(eval $(call tar_xz_template,$(package))))
$(foreach package,$(TAR_GZ_PACKAGES),$(eval $(call tar_gz_template,$(package))))

PATH_ENVS = DESTDIR="$(BUILD_DIR_ABS)/fake_root" PATH="$$PATH:$(MY_CROSS_PATH)"

download: $(foreach package,$(TAR_XZ_PACKAGES),$($(package)-$($(package)_VER)_tar_xz)) $(foreach package,$(TAR_GZ_PACKAGES),$($(package)-$($(package)_VER)_tar_gz))

$(BUILD_DIR)/ $(OUTPUT_DIR)/ $(PY_BUILD_DIR)/:
	mkdir -p $@

$(BUILD_DIR)/made_zlib-$(zlib_VER): $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	CFLAGS="$(OPT_CFLAGS)" CROSS_PREFIX=$(MY_CROSS_PREFIX) ./configure --prefix=$(BUILD_DIR_ABS)/fake_root/usr/local/; \
	$(MAKE) install; \
	)
	touch $@

$(BUILD_DIR)/made_util-linux-$(util-linux_VER): $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	$(PATH_ENVS) ./configure --host=$(MY_CROSS_ARCH) --prefix=/usr/local --disable-all-programs --enable-libuuid --without-python CFLAGS="-I$(BUILD_DIR_ABS)/fake_root/usr/local/include $(OPT_CFLAGS)" LDFLAGS="-L$(BUILD_DIR_ABS)/fake_root/usr/local/lib"; \
	$(PATH_ENVS) $(MAKE) install; \
	)
	touch $@

$(BUILD_DIR)/made_sqlite-autoconf-$(sqlite-autoconf_VER): $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/ $(BUILD_DIR)/made_zlib-$(zlib_VER)
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	$(PATH_ENVS) ./configure --host=$(MY_CROSS_ARCH) CFLAGS="-DSQLITE_OMIT_COMPILEOPTION_DIAGS -I$(BUILD_DIR_ABS)/fake_root/usr/local/include $(OPT_CFLAGS)" LDFLAGS="-L$(BUILD_DIR_ABS)/fake_root/usr/local/lib"; \
	$(PATH_ENVS) $(MAKE) install; \
	)
	touch $@

$(BUILD_DIR)/made_ncurses-$(ncurses_VER): $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	PATH="$$PATH:$(MY_CROSS_PATH)" CFLAGS="$(OPT_CFLAGS)" LDFLAGS="-fPIC" ./configure --host=$(MY_CROSS_ARCH) INSTALL="/usr/bin/install -c --strip-program=$(MY_CROSS_PREFIX)strip" --with-shared --disable-database --disable-termcap --with-fallbacks="dumb,vt100,linux,xterm-256color,vt400,xterm,putty,xterm-16color,xterm-88color,rxvt,putty-256color,konsole,screen" --prefix=/usr/local --disable-db-install --without-manpages --without-progs --without-tack --without-tests $(_NCURSES_EXT_CONF_FLAGS); \
	PATH="$$PATH:$(MY_CROSS_PATH)" $(MAKE) all DESTDIR="$(BUILD_DIR_ABS)/fake_root"; \
	PATH="$$PATH:$(MY_CROSS_PATH)" $(MAKE) install DESTDIR="$(BUILD_DIR_ABS)/fake_root"; \
	)
	touch $@

$(BUILD_DIR)/made_readline-$(readline_VER): $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/ $(BUILD_DIR)/made_ncurses-$(ncurses_VER)
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	PATH="$$PATH:$(MY_CROSS_PATH)" ./configure --host=$(MY_CROSS_ARCH) CFLAGS="-I$(BUILD_DIR_ABS)/fake_root/usr/local/include $(OPT_CFLAGS)" LDFLAGS="-L$(BUILD_DIR_ABS)/fake_root/usr/local/lib -fPIC"; \
	PATH="$$PATH:$(MY_CROSS_PATH)" $(MAKE) install DESTDIR="$(BUILD_DIR_ABS)/fake_root" MFLAGS="SHLIB_LIBS=\"-L$(BUILD_DIR_ABS)/fake_root/usr/local/lib -l$(_NCURSES_LIB)\""; \
	)
	touch $@

$(BUILD_DIR)/made_gdbm-$(gdbm_VER): $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	$(PATH_ENVS) ./configure --host=$(MY_CROSS_ARCH) --enable-libgdbm-compat COMPATINCLUDEDIR=/usr/local/include/gdbm CFLAGS="-Wno-builtin-macro-redefined -U__DATE__ -U__TIME__ -I$(BUILD_DIR_ABS)/fake_root/usr/local/include $(OPT_CFLAGS)" LDFLAGS="-L$(BUILD_DIR_ABS)/fake_root/usr/local/lib"; \
	sed -i 's/hardcode_into_libs=yes/hardcode_into_libs=no/g' ./libtool; \
	sed -i 's/hardcode_automatic=no/hardcode_automatic=yes/g' ./libtool; \
	$(PATH_ENVS) $(MAKE) install; \
	)
	touch $@

$(BUILD_DIR)/made_xz-$(xz_VER): $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	CFLAGS="$(OPT_CFLAGS)" PATH="$$PATH:$(MY_CROSS_PATH)" ./configure --host=$(MY_CROSS_ARCH) --prefix="$(BUILD_DIR_ABS)/fake_root/usr/local"; \
	PATH="$$PATH:$(MY_CROSS_PATH)" $(MAKE) install; \
	)
	touch $@

$(BUILD_DIR)/made_expat-$(expat_VER): $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	$(PATH_ENVS) CFLAGS="$(OPT_CFLAGS)" ./configure --host=$(MY_CROSS_ARCH); \
	$(PATH_ENVS) $(MAKE) install; \
	)
	touch $@

$(BUILD_DIR)/made_mpdecimal-$(mpdecimal_VER): $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	$(PATH_ENVS) CFLAGS="$(OPT_CFLAGS) -fwrapv" ./configure --host=$(MY_CROSS_ARCH); \
	$(PATH_ENVS) $(MAKE) LDFLAGS="-fPIC" install; \
	)
	touch $@

$(BUILD_DIR)/made_bzip2-$(bzip2_VER): $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	echo "" >> Makefile; \
	echo "" >> Makefile; \
	echo "CFLAGS += $(OPT_CFLAGS)" >> Makefile; \
	echo "" >> Makefile; \
	$(MAKE) install PREFIX=$(BUILD_DIR_ABS)/fake_root/usr/local CC=$(MY_CROSS_PREFIX)gcc AR=$(MY_CROSS_PREFIX)ar RANLIB=$(MY_CROSS_PREFIX)ranlib; \
	$(MAKE) clean; \
	$(MAKE) -f Makefile-libbz2_so all CC=$(MY_CROSS_PREFIX)gcc AR=$(MY_CROSS_PREFIX)ar RANLIB=$(MY_CROSS_PREFIX)ranlib; \
	cp -d libbz2.so* $(BUILD_DIR_ABS)/fake_root/usr/local/lib; \
	ln -s libbz2.so.?.?.? $(BUILD_DIR_ABS)/fake_root/usr/local/lib/libbz2.so; \
	)
	touch $@

$(BUILD_DIR)/made_libffi-$(libffi_VER): $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	CFLAGS="$(OPT_CFLAGS)" PATH="$$PATH:$(MY_CROSS_PATH)" ./configure --host=$(MY_CROSS_ARCH) --prefix=$(BUILD_DIR_ABS)/fake_root/usr/local --disable-multi-os-directory; \
	PATH="$$PATH:$(MY_CROSS_PATH)" $(MAKE) install; \
	)
	touch $@

$(BUILD_DIR)/made_openssl-$(openssl_VER): $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	CFLAGS="$(OPT_CFLAGS)" CROSS_COMPILE=$(MY_CROSS_PREFIX) CC=gcc MACHINE=$(MY_CROSS_OPENSSL_MACHINE) RELEASE=5.1 SYSTEM=Linux BUILD=build ./config; \
	echo "" > crypto/buildinf.h; \
	echo "#define PLATFORM \"platform: \"" >> crypto/buildinf.h; \
	echo "#define DATE \"built on: \"" >> crypto/buildinf.h; \
	echo "static const char compiler_flags[] = \"compiler: \";" >> crypto/buildinf.h; \
	echo "" >> crypto/buildinf.h; \
	$(MAKE) all DESTDIR=$(BUILD_DIR_ABS)/fake_root; \
	$(MAKE) install_sw DESTDIR=$(BUILD_DIR_ABS)/fake_root; \
	)
	touch $@



$(PY_BUILD_DIR)/made_host_Python-$(Python_VER): $(PY_BUILD_DIR)/made_host_%: %.tar.xz | $(PY_BUILD_DIR)/
	(set -e; \
	mkdir -p $(PY_BUILD_DIR_ABS)/host/; \
	cd $(PY_BUILD_DIR_ABS)/host/; \
	tar -xJf $(SRC_PATH_ABS)/$^; \
	cd $*; \
	./configure; \
	DESTDIR=$(PY_BUILD_DIR_ABS)/pyfakeroot/ $(MAKE) altinstall bininstall; \
	)
	touch $@

$(PY_BUILD_DIR)/modules_to_add: Python-$(Python_VER).tar.xz get_setup_modules.py $(PY_BUILD_DIR)/made_host_Python-$(Python_VER) $(foreach package, openssl bzip2 libffi ncurses readline gdbm sqlite-autoconf xz zlib util-linux $(_ADDITIONAL_EXT_MODS), $(BUILD_DIR)/made_$(package)-$($(package)_VER))
	(set -e; \
	mkdir -p $(PY_BUILD_DIR_ABS)/dyn/; \
	cd $(PY_BUILD_DIR_ABS)/dyn/; \
	tar -xJf $(SRC_PATH_ABS)/Python-$(Python_VER).tar.xz; \
	cd Python-*; \
	LDFLAGS="-L$(BUILD_DIR_ABS)/fake_root/usr/local/lib -Wl,-rpath-link,$(BUILD_DIR_ABS)/fake_root/usr/local/lib" PATH="$(PY_BUILD_DIR_ABS)/pyfakeroot/usr/local/bin:$$PATH:$(MY_CROSS_PATH)" ./configure --host=$(MY_CROSS_ARCH) --build=x86_64-pc-linux-gnu --enable-ipv6 --with-system-ffi $(_ADDITIONAL_PY_CONF_FLAGS) --with-dbmliborder=gdbm --with-ensurepip=no --with-build-python=yes --with-openssl=$(BUILD_DIR_ABS)/fake_root/usr/local ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no LIBFFI_INCLUDEDIR=$(BUILD_DIR_ABS)/fake_root/usr/local/include CPPFLAGS="-I$(BUILD_DIR_ABS)/fake_root/usr/local/include -I$(BUILD_DIR_ABS)/fake_root/usr/local/include/$(_NCURSES_LIB) -I$(BUILD_DIR_ABS)/fake_root/usr/local/include/uuid"; \
	[ ! -f setup.py ] || (mv setup.py setup2.py && cp $(SRC_PATH_ABS)/get_setup_modules.py setup.py); \
	MODULE_BLACKLIST="$(MODULE_BLACKLIST)" DESTDIR=$(PY_BUILD_DIR_ABS)/pyfakeroot/ PATH="$(PY_BUILD_DIR_ABS)/pyfakeroot/usr/local/bin:$$PATH:$(MY_CROSS_PATH)" $(MAKE) sharedmods; \
	[ -f modules_to_add ] || (echo "*disabled*" > modules_to_add && echo "$(MODULE_BLACKLIST)" >> modules_to_add); \
	cp modules_to_add $(SRC_PATH_ABS)/$@; \
	)

$(PY_BUILD_DIR)/made_Python-$(Python_VER): $(PY_BUILD_DIR)/made_%: $(PY_BUILD_DIR)/%/ $(PY_BUILD_DIR)/modules_to_add
	(set -e; \
	cd $(PY_BUILD_DIR)/$*; \
	rm -f Modules/Setup.local; \
	cp $(PY_BUILD_DIR_ABS)/modules_to_add Modules/Setup.local; \
	[ ! -f Modules/Setup.stdlib.in ] || sed -i 's/^\*shared\*$$/*disabled*/g' Modules/Setup.stdlib.in; \
	\
	MODULE_BUILDTYPE=static LINKFORSHARED=" " CCSHARED=" " LDFLAGS="-L$(BUILD_DIR_ABS)/fake_root/usr/local/lib -Wl,-rpath-link,$(BUILD_DIR_ABS)/fake_root/usr/local/lib" PATH="$(PY_BUILD_DIR_ABS)/pyfakeroot/usr/local/bin:$$PATH:$(MY_CROSS_PATH)" ./configure --host=$(MY_CROSS_ARCH) --build=x86_64-pc-linux-gnu --enable-ipv6 --enable-optimizations --with-lto --with-system-ffi $(_ADDITIONAL_PY_CONF_FLAGS) --with-dbmliborder=gdbm --with-ensurepip=no --disable-shared --with-tzpath="" --with-build-python=yes --with-openssl=$(BUILD_DIR_ABS)/fake_root/usr/local ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no LIBFFI_INCLUDEDIR=$(BUILD_DIR_ABS)/fake_root/usr/local/include CPPFLAGS="-I$(BUILD_DIR_ABS)/fake_root/usr/local/include -I$(BUILD_DIR_ABS)/fake_root/usr/local/include/$(_NCURSES_LIB) -I$(BUILD_DIR_ABS)/fake_root/usr/local/include/uuid"; \
	\
	echo "" >> Modules/errnomodule.c; \
	echo "" >> Modules/errnomodule.c; \
	echo "#include <stdlib.h>" >> Modules/errnomodule.c; \
	echo "" >> Modules/errnomodule.c; \
	echo "static void __attribute__((constructor)) my_pythonhome_ctor(void) {" >> Modules/errnomodule.c; \
	echo "	if (getenv(\"PYTHONHOME\") == NULL) {" >> Modules/errnomodule.c; \
	echo "		putenv(\"PYTHONHOME=/proc/self/exe\");" >> Modules/errnomodule.c; \
	echo "	}" >> Modules/errnomodule.c; \
	echo "}" >> Modules/errnomodule.c; \
	echo "" >> Modules/errnomodule.c; \
	echo "" >> Modules/errnomodule.c; \
	if [ -f ./Lib/plat-generic/regen ]; then \
	echo "#!/bin/sh" > ./Lib/plat-generic/regen; \
	echo "" > ./Lib/plat-generic/regen; \
	fi; \
	mkdir $(PY_BUILD_DIR_ABS)/pyfakeroot2/ || true; \
	echo "" >> Makefile; \
	echo "LDFLAGS += -Wl,--whole-archive -lpthread -Wl,--no-whole-archive -static $(OPT_LDFLAGS) $(_ADDITIONAL_PY_LDFLAGS)" >> Makefile; \
	echo "" >> Makefile; \
	DESTDIR=$(PY_BUILD_DIR_ABS)/pyfakeroot2/ PATH="$(PY_BUILD_DIR_ABS)/pyfakeroot/usr/local/bin:$$PATH:$(MY_CROSS_PATH)" EXTRA_CFLAGS="-DCOMPILER=\\\"\\\" -Wno-builtin-macro-redefined -U__DATE__ -U__TIME__ $(OPT_CFLAGS) $(_ADDITIONAL_PY_CFLAGS)" $(MAKE) libinstall; \
	)
	touch $@

$(PY_BUILD_DIR)/python-stripped: $(PY_BUILD_DIR)/made_Python-$(Python_VER)
	$(MY_CROSS_PREFIX)objcopy -R .comment -R '.comment.*' -R .note -R '.note.*' -S $(PY_BUILD_DIR)/Python-$(Python_VER)/python $(SRC_PATH_ABS)/$@

$(PY_BUILD_DIR)/python_lib.zip: $(PY_BUILD_DIR)/made_Python-$(Python_VER) zipper.py
	(set -e; cd $(PY_BUILD_DIR_ABS)/pyfakeroot2/; make -f $(PY_BUILD_DIR_ABS)/Python-$(Python_VER)/Makefile pycremoval)
	(set -e; \
	cd $(PY_BUILD_DIR_ABS)/pyfakeroot2/usr/local/*/*; \
	rm -r test/ || true; \
	rm -r lib2to3/tests/ || true; \
	rm -r unittest/test/ || true; \
	rm -r ctypes/test/ || true; \
	rm -r distutils/tests/ || true; \
	rm -r tkinter/test/ || true; \
	rm -r idlelib/idle_test/ || true; \
	rm -r sqlite3/test/ || true; \
	rm -r ensurepip/ || true; \
	rm -r email/test || true; \
	rm -r json/tests || true; \
	rm -r bsddb/test || true; \
	rm -r lib-tk/test || true; \
	rm lib2to3/*Grammar*.pickle || true; \
	if [ -f _sysconfigdata*.py ]; then \
	echo "# system configuration generated and used by the sysconfig module" > $$(echo _sysconfigdata*.py); \
	echo "build_time_vars = {'TZPATH': ''}" >> $$(echo _sysconfigdata*.py); \
	fi; \
	)
	# fixup ctypes to load
	sed -i 's/pythonapi = PyDLL(None)/pythonapi = None/g' $(PY_BUILD_DIR_ABS)/pyfakeroot2/usr/local/*/*/ctypes/__init__.py || true
	PYTHONHOME=$(PY_BUILD_DIR_ABS)/pyfakeroot/usr/local $(PY_BUILD_DIR_ABS)/pyfakeroot/usr/local/bin/python[0-9] $(SRC_PATH_ABS)/zipper.py $(PY_BUILD_DIR_ABS)/pyfakeroot2/usr/local $(SRC_PATH_ABS)/$@

$(PY_BUILD_DIR)/static_python: $(PY_BUILD_DIR)/python-stripped $(PY_BUILD_DIR)/python_lib.zip
	cat $(PY_BUILD_DIR)/python-stripped $(PY_BUILD_DIR)/python_lib.zip > $@
	chmod u+x $@

$(OUTPUT_DIR)/static_python: $(PY_BUILD_DIR)/static_python | $(OUTPUT_DIR)/
	cp $^ $@



all: $(OUTPUT_DIR)/static_python

