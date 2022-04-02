#!/bin/sh -e

MY_CROSS_PREFIX=/opt/aarch64-buildroot-linux-musl/bin/aarch64-buildroot-linux-musl-
MY_CROSS_PATH=/opt/aarch64-buildroot-linux-musl/bin
MY_CROSS_ARCH=aarch64-buildroot-linux-musl
MY_CROSS_ARCH2=linux-aarch64
MY_CROSS_ARCH3=aarch64

OPT_CFLAGS = -ffunction-sections -fdata-sections -flto -fuse-linker-plugin -ffat-lto-objects -Os
OPT_LDFLAGS = -flto -fuse-linker-plugin -ffat-lto-objects -Wl,--gc-sections -Os -flto-partition=one

SRC_PATH_ABS=$(shell pwd)

BUILD_DIR=tmp/build
OUTPUT_DIR=tmp/final

BUILD_DIR_ABS=$(SRC_PATH_ABS)/$(BUILD_DIR)


$(BUILD_DIR)/ $(OUTPUT_DIR)/:
	mkdir -p $@

.PHONY: clean bla all
clean:
	-rm -rf $(BUILD_DIR) $(OUTPUT_DIR)


# .ONESHELL:
# .SHELLFLAGS = -e


nl:=$(strip \)

define tar_xz_template =
$(1)_tar_xz ?= $(1).tar.xz

$$(BUILD_DIR)/$(1)/ : $$($(1)_tar_xz) | $$(BUILD_DIR)/
	(set -e; $(nl)
	cd $$(BUILD_DIR); $(nl)
	tar -xJf $$(SRC_PATH_ABS)/$$^; $(nl)
	)

endef

define tar_gz_template =
$(1)_tar_gz ?= $(1).tar.gz

$$(BUILD_DIR)/$(1)/ : $$($(1)_tar_gz) | $$(BUILD_DIR)/
	(set -e; $(nl)
	cd $$(BUILD_DIR); $(nl)
	tar -xzf $$(SRC_PATH_ABS)/$$^; $(nl)
	)

endef

bzip2-1.0.8_tar_gz = bzip2-latest.tar.gz

TAR_XZ_PACKAGES = Python-3.9.7 xz-5.2.5 zlib-1.2.11 util-linux-2.37.4
TAR_GZ_PACKAGES = openssl-1.1.1l bzip2-1.0.8 libffi-3.4.2 ncurses-6.2 readline-8.1 gdbm-1.23 sqlite-autoconf-3380100

$(foreach package,$(TAR_XZ_PACKAGES),$(eval $(call tar_xz_template,$(package))))
$(foreach package,$(TAR_GZ_PACKAGES),$(eval $(call tar_gz_template,$(package))))

PATH_ENVS = DESTDIR="$(BUILD_DIR_ABS)/fake_root" PATH="$$PATH:$(MY_CROSS_PATH)"

$(BUILD_DIR)/made_zlib-1.2.11: $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	CFLAGS="$(OPT_CFLAGS)" CROSS_PREFIX=$(MY_CROSS_PREFIX) ./configure --prefix=$(BUILD_DIR_ABS)/fake_root/usr/local/; \
	$(MAKE) install; \
	)
	touch $@

$(BUILD_DIR)/made_util-linux-2.37.4: $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	$(PATH_ENVS) ./configure --host=$(MY_CROSS_ARCH) --prefix=/usr/local --disable-all-programs --enable-libuuid --without-python CFLAGS="-I$(BUILD_DIR_ABS)/fake_root/usr/local/include $(OPT_CFLAGS)" LDFLAGS="-L$(BUILD_DIR_ABS)/fake_root/usr/local/lib"; \
	$(PATH_ENVS) $(MAKE) install; \
	)
	touch $@

$(BUILD_DIR)/made_sqlite-autoconf-3380100: $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/ $(BUILD_DIR)/made_zlib-1.2.11
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	$(PATH_ENVS) ./configure --host=$(MY_CROSS_ARCH) CFLAGS="-DSQLITE_OMIT_COMPILEOPTION_DIAGS -I$(BUILD_DIR_ABS)/fake_root/usr/local/include $(OPT_CFLAGS)" LDFLAGS="-L$(BUILD_DIR_ABS)/fake_root/usr/local/lib"; \
	$(PATH_ENVS) $(MAKE) install; \
	)
	touch $@

$(BUILD_DIR)/made_ncurses-6.2: $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	PATH="$$PATH:$(MY_CROSS_PATH)" CFLAGS="$(OPT_CFLAGS)" ./configure --host=$(MY_CROSS_ARCH) INSTALL="/usr/bin/install -c --strip-program=$(MY_CROSS_PREFIX)strip" --with-shared --disable-database --disable-termcap --with-fallbacks="dumb,vt100,linux,xterm-256color,vt400,xterm,putty,xterm-16color,xterm-88color,rxvt,putty-256color,konsole,screen" --prefix=/usr/local --disable-db-install --without-manpages --without-progs --without-tack --without-tests; \
	PATH="$$PATH:$(MY_CROSS_PATH)" $(MAKE) all DESTDIR="$(BUILD_DIR_ABS)/fake_root"; \
	PATH="$$PATH:$(MY_CROSS_PATH)" $(MAKE) install DESTDIR="$(BUILD_DIR_ABS)/fake_root"; \
	)
	touch $@

$(BUILD_DIR)/made_readline-8.1: $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/ $(BUILD_DIR)/made_ncurses-6.2
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	PATH="$$PATH:$(MY_CROSS_PATH)" ./configure --host=$(MY_CROSS_ARCH) CFLAGS="-I$(BUILD_DIR_ABS)/fake_root/usr/local/include $(OPT_CFLAGS)" LDFLAGS="-L$(BUILD_DIR_ABS)/fake_root/usr/local/lib"; \
	PATH="$$PATH:$(MY_CROSS_PATH)" $(MAKE) install DESTDIR="$(BUILD_DIR_ABS)/fake_root" MFLAGS="SHLIB_LIBS=\"-L$(BUILD_DIR_ABS)/fake_root/usr/local/lib -lncurses\""; \
	)
	touch $@

$(BUILD_DIR)/made_gdbm-1.23: $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	$(PATH_ENVS) ./configure --host=$(MY_CROSS_ARCH) --enable-libgdbm-compat CFLAGS="-Wno-builtin-macro-redefined -U__DATE__ -U__TIME__ -I$(BUILD_DIR_ABS)/fake_root/usr/local/include $(OPT_CFLAGS)" LDFLAGS="-L$(BUILD_DIR_ABS)/fake_root/usr/local/lib"; \
	$(PATH_ENVS) $(MAKE) install; \
	)
	touch $@

$(BUILD_DIR)/made_xz-5.2.5: $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	CFLAGS="$(OPT_CFLAGS)" PATH="$$PATH:$(MY_CROSS_PATH)" ./configure --host=$(MY_CROSS_ARCH) --prefix="$(BUILD_DIR_ABS)/fake_root/usr/local"; \
	PATH="$$PATH:$(MY_CROSS_PATH)" $(MAKE) install; \
	)
	touch $@

$(BUILD_DIR)/made_bzip2-1.0.8: $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/
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

$(BUILD_DIR)/made_libffi-3.4.2: $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	CFLAGS="$(OPT_CFLAGS)" PATH="$$PATH:$(MY_CROSS_PATH)" ./configure --host=$(MY_CROSS_ARCH) --prefix=$(BUILD_DIR_ABS)/fake_root/usr/local --disable-multi-os-directory; \
	PATH="$$PATH:$(MY_CROSS_PATH)" $(MAKE) install; \
	)
	touch $@

$(BUILD_DIR)/made_openssl-1.1.1l: $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	CFLAGS="$(OPT_CFLAGS)" CROSS_COMPILE=$(MY_CROSS_PREFIX) MACHINE=$(MY_CROSS_ARCH3) RELEASE=5.1 SYSTEM=Linux BUILD=build ./config; \
	echo "" > crypto/buildinf.h; \
	echo "#define PLATFORM \"platform: \"" >> crypto/buildinf.h; \
	echo "#define DATE \"built on: \"" >> crypto/buildinf.h; \
	echo "static const char compiler_flags[] = \"compiler: \";" >> crypto/buildinf.h; \
	echo "" >> crypto/buildinf.h; \
	$(MAKE) all DESTDIR=$(BUILD_DIR_ABS)/fake_root; \
	$(MAKE) install_sw DESTDIR=$(BUILD_DIR_ABS)/fake_root; \
	)
	touch $@

$(BUILD_DIR)/made_host_Python-3.9.7: $(BUILD_DIR)/made_host_%: %.tar.xz | $(BUILD_DIR)/
	(set -e; \
	mkdir -p $(BUILD_DIR_ABS)/host/; \
	cd $(BUILD_DIR_ABS)/host/; \
	tar -xJf $(SRC_PATH_ABS)/$^; \
	cd $*; \
	./configure; \
	DESTDIR=$(BUILD_DIR_ABS)/pyfakeroot/ $(MAKE) altinstall; \
	)
	touch $@

$(BUILD_DIR)/modules_to_add: Python-3.9.7.tar.xz get_setup_modules.py $(BUILD_DIR)/made_host_Python-3.9.7 $(BUILD_DIR)/made_openssl-1.1.1l $(BUILD_DIR)/made_libffi-3.4.2 $(BUILD_DIR)/made_bzip2-1.0.8 $(BUILD_DIR)/made_xz-5.2.5 $(BUILD_DIR)/made_gdbm-1.23 $(BUILD_DIR)/made_readline-8.1 $(BUILD_DIR)/made_ncurses-6.2 $(BUILD_DIR)/made_sqlite-autoconf-3380100 $(BUILD_DIR)/made_util-linux-2.37.4 $(BUILD_DIR)/made_zlib-1.2.11
	(set -e; \
	mkdir -p $(BUILD_DIR_ABS)/dyn/; \
	cd $(BUILD_DIR_ABS)/dyn/; \
	tar -xJf $(SRC_PATH_ABS)/Python-3.9.7.tar.xz; \
	cd Python-*; \
	LDFLAGS="-L$(BUILD_DIR_ABS)/fake_root/usr/local/lib" PATH="$(BUILD_DIR_ABS)/pyfakeroot/usr/local/bin:$$PATH:$(MY_CROSS_PATH)" ./configure --host=$(MY_CROSS_ARCH) --build=x86_64-pc-linux-gnu --enable-ipv6 --with-system-ffi --with-ensurepip=no --with-openssl=$(BUILD_DIR_ABS)/fake_root/usr/local ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no LIBFFI_INCLUDEDIR=$(BUILD_DIR_ABS)/fake_root/usr/local/include CPPFLAGS="-I$(BUILD_DIR_ABS)/fake_root/usr/local/include -I$(BUILD_DIR_ABS)/fake_root/usr/local/include/ncurses -I$(BUILD_DIR_ABS)/fake_root/usr/local/include/uuid"; \
	mv setup.py setup2.py; \
	cp $(SRC_PATH_ABS)/get_setup_modules.py setup.py; \
	DESTDIR=$(BUILD_DIR_ABS)/pyfakeroot/ PATH="$(BUILD_DIR_ABS)/pyfakeroot/usr/local/bin:$$PATH:$(MY_CROSS_PATH)" $(MAKE) sharedmods; \
	cp modules_to_add $(BUILD_DIR_ABS)/modules_to_add; \
	)

$(BUILD_DIR)/made_Python-3.9.7: $(BUILD_DIR)/made_%: $(BUILD_DIR)/%/ $(BUILD_DIR)/modules_to_add
	(set -e; \
	cd $(BUILD_DIR)/$*; \
	rm -f Modules/Setup.local; \
	cp $(BUILD_DIR_ABS)/modules_to_add Modules/Setup.local; \
	\
	LINKFORSHARED=" " LDFLAGS="-L$(BUILD_DIR_ABS)/fake_root/usr/local/lib" PATH="$(BUILD_DIR_ABS)/pyfakeroot/usr/local/bin:$$PATH:$(MY_CROSS_PATH)" ./configure --host=$(MY_CROSS_ARCH) --build=x86_64-pc-linux-gnu --enable-ipv6 --enable-optimizations --with-lto --with-system-ffi --with-ensurepip=no --disable-shared --with-tzpath="" --with-openssl=$(BUILD_DIR_ABS)/fake_root/usr/local ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no LIBFFI_INCLUDEDIR=$(BUILD_DIR_ABS)/fake_root/usr/local/include CPPFLAGS="-I$(BUILD_DIR_ABS)/fake_root/usr/local/include -I$(BUILD_DIR_ABS)/fake_root/usr/local/include/ncurses -I$(BUILD_DIR_ABS)/fake_root/usr/local/include/uuid"; \
	\
	echo "" >> Modules/errnomodule.c; \
	echo "" >> Modules/errnomodule.c; \
	echo "#include <stdlib.h>" >> Modules/errnomodule.c; \
	echo "" >> Modules/errnomodule.c; \
	echo "static void __attribute__((constructor)) my_pythonhome_ctor() {" >> Modules/errnomodule.c; \
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
	mkdir $(BUILD_DIR_ABS)/pyfakeroot2/ || true; \
	echo "" >> Makefile; \
	echo "LDFLAGS += -Wl,--whole-archive -lpthread -Wl,--no-whole-archive -static $(OPT_LDFLAGS)" >> Makefile; \
	echo "" >> Makefile; \
	DESTDIR=$(BUILD_DIR_ABS)/pyfakeroot2/ PATH="$(BUILD_DIR_ABS)/pyfakeroot/usr/local/bin:$$PATH:$(MY_CROSS_PATH)" EXTRA_CFLAGS="-DCOMPILER=\\\"\\\" -Wno-builtin-macro-redefined -U__DATE__ -U__TIME__ $(OPT_CFLAGS)" $(MAKE) libinstall; \
	)
	touch $@

$(BUILD_DIR)/python-stripped: $(BUILD_DIR)/made_Python-3.9.7
	$(MY_CROSS_PREFIX)objcopy -R .comment -R '.comment.*' -R .note -R '.note.*' -S $(BUILD_DIR)/Python-3.9.7/python $(BUILD_DIR)/python-stripped

$(BUILD_DIR)/python_lib.zip: $(BUILD_DIR)/made_Python-3.9.7
	(set -e; cd $(BUILD_DIR_ABS)/pyfakeroot2/; make -f $(BUILD_DIR_ABS)/Python-3.9.7/Makefile pycremoval)
	(set -e; \
	cd $(BUILD_DIR_ABS)/pyfakeroot2/usr/local/*/*; \
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
	sed -i 's/pythonapi = PyDLL(None)/pythonapi = None/g' $(BUILD_DIR_ABS)/pyfakeroot2/usr/local/*/*/ctypes/__init__.py || true
	PYTHONHOME=$(BUILD_DIR_ABS)/pyfakeroot/usr/local $(BUILD_DIR_ABS)/pyfakeroot/usr/local/bin/python?.? $(SRC_PATH_ABS)/zipper.py $(BUILD_DIR_ABS)/pyfakeroot2/usr/local $(BUILD_DIR_ABS)/python_lib.zip

$(BUILD_DIR)/static_python: $(BUILD_DIR)/python-stripped $(BUILD_DIR)/python_lib.zip
	cat $(BUILD_DIR)/python-stripped $(BUILD_DIR)/python_lib.zip > $@
	chmod u+x $@

$(OUTPUT_DIR)/static_python: $(BUILD_DIR)/static_python | $(OUTPUT_DIR)/
	cp $^ $@


all: $(OUTPUT_DIR)/static_python

