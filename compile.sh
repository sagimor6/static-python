#!/bin/sh -e

MY_CROSS_PREFIX=/opt/aarch64-buildroot-linux-musl/bin/aarch64-buildroot-linux-musl-
MY_CROSS_PATH=/opt/aarch64-buildroot-linux-musl/bin
MY_CROSS_ARCH=aarch64-buildroot-linux-musl
MY_CROSS_ARCH2=linux-aarch64
MY_CROSS_ARCH3=aarch64

OPT_CFLAGS="-ffunction-sections -fdata-sections -flto -fuse-linker-plugin -ffat-lto-objects -Os"
OPT_LDFLAGS="-flto -fuse-linker-plugin -ffat-lto-objects -Wl,--gc-sections -Os -flto-partition=one"


SRC_PATH=$(pwd)


rm -rf final
mkdir final

rm -rf build
mkdir build

cd build

BUILD_DIR=$(pwd)

#tar -xJf $SRC_PATH/Python-3.9.7.tar.xz
tar -xJf $SRC_PATH/Python-2.7.18.tar.xz
tar -xJf $SRC_PATH/xz-5.2.5.tar.xz
tar -xJf $SRC_PATH/zlib-1.2.11.tar.xz
tar -xzf $SRC_PATH/openssl-1.1.1l.tar.gz
tar -xzf $SRC_PATH/bzip2-latest.tar.gz
tar -xzf $SRC_PATH/libffi-3.4.2.tar.gz
tar -xzf $SRC_PATH/ncurses-6.2.tar.gz
tar -xzf $SRC_PATH/readline-8.1.tar.gz
tar -xzf $SRC_PATH/gdbm-1.23.tar.gz
tar -xzf $SRC_PATH/sqlite-autoconf-3380100.tar.gz
tar -xJf $SRC_PATH/util-linux-2.37.4.tar.xz
# tar -xzf $SRC_PATH/tcl8.6.12-src.tar.gz
# tar -xzf $SRC_PATH/tk8.6.12-src.tar.gz

mkdir fake_root
mkdir pyfakeroot

cd zlib-1.2.11/
make distclean

CFLAGS="${OPT_CFLAGS}" CROSS_PREFIX=${MY_CROSS_PREFIX} ./configure --prefix=${BUILD_DIR}/fake_root/usr/local/

make clean
make all -j8
make install

cd ..

cd util-linux-2.37.4

PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=$MY_CROSS_ARCH --prefix=/usr/local --disable-all-programs --enable-libuuid --without-python CFLAGS="-I${BUILD_DIR}/fake_root/usr/local/include ${OPT_CFLAGS}" LDFLAGS="-L${BUILD_DIR}/fake_root/usr/local/lib"

DESTDIR="${BUILD_DIR}/fake_root" PATH="$PATH:${MY_CROSS_PATH}" make -j8 all
DESTDIR="${BUILD_DIR}/fake_root" PATH="$PATH:${MY_CROSS_PATH}" make install

cd ..

# cd tcl8.6.12/unix
# 
# PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=$MY_CROSS_ARCH --with-system-sqlite --without-tzdata CFLAGS="-I${BUILD_DIR}/fake_root/usr/local/include ${OPT_CFLAGS}" LDFLAGS="-L${BUILD_DIR}/fake_root/usr/local/lib"
# 
# DESTDIR="${BUILD_DIR}/fake_root" PATH="$PATH:${MY_CROSS_PATH}" make -j8 install-binaries
# 
# cd ../..
# 
# cd tk8.6.12/unix
# 
# PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=$MY_CROSS_ARCH --with-tcl="${BUILD_DIR}/fake_root/usr/local/lib" CFLAGS="-I${BUILD_DIR}/fake_root/usr/local/include ${OPT_CFLAGS}" LDFLAGS="-L${BUILD_DIR}/fake_root/usr/local/lib"
# 
# DESTDIR="${BUILD_DIR}/fake_root" PATH="$PATH:${MY_CROSS_PATH}" make -j8 install-binaries
# 
# cd ../../
# 
# cd tcl8.6.12/unix
# 
# make distclean
# 
# PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=$MY_CROSS_ARCH --disable-shared --with-system-sqlite --without-tzdata CFLAGS="-I${BUILD_DIR}/fake_root/usr/local/include ${OPT_CFLAGS}" LDFLAGS="-L${BUILD_DIR}/fake_root/usr/local/lib"
# 
# DESTDIR="${BUILD_DIR}/fake_root" PATH="$PATH:${MY_CROSS_PATH}" make -j8 install-binaries install-headers
# 
# cd ../..
# 
# cd tk8.6.12/unix
# 
# make distclean
# 
# PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=$MY_CROSS_ARCH  --disable-shared --with-tcl="{BUILD_DIR}/fake_root/usr/local/lib" CFLAGS="-I${BUILD_DIR}/fake_root/usr/local/include ${OPT_CFLAGS}" LDFLAGS="-L${BUILD_DIR}/fake_root/usr/local/lib"
# 
# DESTDIR="${BUILD_DIR}/fake_root" PATH="$PATH:${MY_CROSS_PATH}" make -j8 install-binaries install-headers
# 
# cd ../..

cd sqlite-autoconf-3380100

PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=$MY_CROSS_ARCH CFLAGS="-DSQLITE_OMIT_COMPILEOPTION_DIAGS -I${BUILD_DIR}/fake_root/usr/local/include ${OPT_CFLAGS}" LDFLAGS="-L${BUILD_DIR}/fake_root/usr/local/lib"

DESTDIR="${BUILD_DIR}/fake_root" PATH="$PATH:${MY_CROSS_PATH}" make -j8 all
DESTDIR="${BUILD_DIR}/fake_root" PATH="$PATH:${MY_CROSS_PATH}" make install

cd ..

cd ncurses-6.2/

PATH="$PATH:${MY_CROSS_PATH}" CFLAGS="${OPT_CFLAGS}" ./configure --host=$MY_CROSS_ARCH INSTALL="/usr/bin/install -c --strip-program=${MY_CROSS_PREFIX}strip" --with-shared --disable-database --disable-termcap --with-fallbacks="dumb,vt100,linux,xterm-256color,vt400,xterm,putty,xterm-16color,xterm-88color,rxvt,putty-256color,konsole,screen" --prefix=/usr/local --disable-db-install --without-manpages --without-progs --without-tack --without-tests
PATH="$PATH:${MY_CROSS_PATH}" make -j8 all DESTDIR="${BUILD_DIR}/fake_root"
PATH="$PATH:${MY_CROSS_PATH}" make install DESTDIR="${BUILD_DIR}/fake_root"

cd ..

cd readline-8.1

PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=$MY_CROSS_ARCH CFLAGS="-I${BUILD_DIR}/fake_root/usr/local/include ${OPT_CFLAGS}" LDFLAGS="-L${BUILD_DIR}/fake_root/usr/local/lib"
PATH="$PATH:${MY_CROSS_PATH}" make -j8 all DESTDIR="${BUILD_DIR}/fake_root" MFLAGS="SHLIB_LIBS=\"-L${BUILD_DIR}/fake_root/usr/local/lib -lncurses\""
PATH="$PATH:${MY_CROSS_PATH}" make install DESTDIR="${BUILD_DIR}/fake_root"

cd ..

cd gdbm-1.23/

PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=$MY_CROSS_ARCH --enable-libgdbm-compat CFLAGS="-Wno-builtin-macro-redefined -U__DATE__ -U__TIME__ -I${BUILD_DIR}/fake_root/usr/local/include ${OPT_CFLAGS}" LDFLAGS="-L${BUILD_DIR}/fake_root/usr/local/lib"

DESTDIR="${BUILD_DIR}/fake_root" PATH="$PATH:${MY_CROSS_PATH}" make -j8 all
DESTDIR="${BUILD_DIR}/fake_root" PATH="$PATH:${MY_CROSS_PATH}" make install

cd ..

cd xz-5.2.5/

CFLAGS="${OPT_CFLAGS}" PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=${MY_CROSS_ARCH} --prefix="${BUILD_DIR}/fake_root/usr/local"

PATH="$PATH:${MY_CROSS_PATH}" make clean

PATH="$PATH:${MY_CROSS_PATH}" make all -j8

PATH="$PATH:${MY_CROSS_PATH}" make install

cd ..

cd bzip2-1.0.8/

make clean

echo "

CFLAGS += ${OPT_CFLAGS}

" >> Makefile

make -j8 bzip2 CC=${MY_CROSS_PREFIX}gcc AR=${MY_CROSS_PREFIX}ar RANLIB=${MY_CROSS_PREFIX}ranlib

make install PREFIX=${BUILD_DIR}/fake_root/usr/local CC=${MY_CROSS_PREFIX}gcc AR=${MY_CROSS_PREFIX}ar RANLIB=${MY_CROSS_PREFIX}ranlib

make clean

make -f Makefile-libbz2_so -j8 all CC=${MY_CROSS_PREFIX}gcc AR=${MY_CROSS_PREFIX}ar RANLIB=${MY_CROSS_PREFIX}ranlib

cp -d libbz2.so* ${BUILD_DIR}/fake_root/usr/local/lib
ln -s libbz2.so.?.?.? ${BUILD_DIR}/fake_root/usr/local/lib/libbz2.so

cd ..

cd libffi-3.4.2/

CFLAGS="${OPT_CFLAGS}" PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=${MY_CROSS_ARCH} --prefix=${BUILD_DIR}/fake_root/usr/local --disable-multi-os-directory

PATH="$PATH:${MY_CROSS_PATH}" make all -j8

PATH="$PATH:${MY_CROSS_PATH}" make install

cd ..

cd openssl-1.1.1l/

CFLAGS="${OPT_CFLAGS}" CROSS_COMPILE=${MY_CROSS_PREFIX} MACHINE=${MY_CROSS_ARCH3} RELEASE=5.1 SYSTEM=Linux BUILD=build ./config
#CFLAGS="${OPT_CFLAGS}" CROSS_COMPILE=${MY_CROSS_PREFIX} ./Configure ${MY_CROSS_ARCH2}

echo "
#define PLATFORM \"platform: \"
#define DATE \"built on: \"
static const char compiler_flags[] = \"compiler: \";
" > crypto/buildinf.h

make all -j8 DESTDIR=${BUILD_DIR}/fake_root

make install_sw -j8 DESTDIR=${BUILD_DIR}/fake_root

cd ..

#cd Python-3.9.7/
cd Python-2.7.18/

./configure

DESTDIR=${BUILD_DIR}/pyfakeroot/ make -j8 altinstall

make distclean

export PKG_CONFIG=pkg-config
export PKG_CONFIG_LIBDIR=${BUILD_DIR}/fake_root/usr/local/lib/pkgconfig

LDFLAGS="-L${BUILD_DIR}/fake_root/usr/local/lib" PATH="${BUILD_DIR}/pyfakeroot/usr/local/bin:$PATH:${MY_CROSS_PATH}" ./configure --host=${MY_CROSS_ARCH} --build=x86_64-pc-linux-gnu --enable-ipv6 --with-system-ffi --with-ensurepip=no --with-openssl=${BUILD_DIR}/fake_root/usr/local ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no LIBFFI_INCLUDEDIR=${BUILD_DIR}/fake_root/usr/local/include CPPFLAGS="-I${BUILD_DIR}/fake_root/usr/local/include -I${BUILD_DIR}/fake_root/usr/local/include/ncurses -I${BUILD_DIR}/fake_root/usr/local/include/uuid"

# echo "
# *shared*
# 
# _testcapi
# 
# 
# 
# 
# " >> Modules/Setup.local

mv setup.py setup2.py
cp $SRC_PATH/get_setup_modules.py setup.py
DESTDIR=${BUILD_DIR}/pyfakeroot/ PATH="${BUILD_DIR}/pyfakeroot/usr/local/bin:$PATH:${MY_CROSS_PATH}" make sharedmods -j8
rm -f setup.py
mv setup2.py setup.py

make distclean || true

rm -f Modules/Setup.local
cp modules_to_add Modules/Setup.local

LINKFORSHARED=" " LDFLAGS="-L${BUILD_DIR}/fake_root/usr/local/lib" PATH="${BUILD_DIR}/pyfakeroot/usr/local/bin:$PATH:${MY_CROSS_PATH}" ./configure --host=${MY_CROSS_ARCH} --build=x86_64-pc-linux-gnu --enable-ipv6 --enable-optimizations --with-lto --with-system-ffi --with-ensurepip=no --disable-shared --with-tzpath="" --with-openssl=${BUILD_DIR}/fake_root/usr/local ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no LIBFFI_INCLUDEDIR=${BUILD_DIR}/fake_root/usr/local/include CPPFLAGS="-I${BUILD_DIR}/fake_root/usr/local/include -I${BUILD_DIR}/fake_root/usr/local/include/ncurses -I${BUILD_DIR}/fake_root/usr/local/include/uuid"

echo "

#include <stdlib.h>

static void __attribute__((constructor)) my_pythonhome_ctor() {
	if (getenv(\"PYTHONHOME\") == NULL) {
		putenv(\"PYTHONHOME=/proc/self/exe\");
	}
}

" >> Modules/errnomodule.c

if [ -f ./Lib/plat-generic/regen ]; then
echo "#!/bin/sh
" > ./Lib/plat-generic/regen
fi

mkdir ${BUILD_DIR}/pyfakeroot2/ || true

# this is because old pythons
echo "
LDFLAGS += -Wl,--whole-archive -lpthread -Wl,--no-whole-archive -static ${OPT_LDFLAGS}
" >> Makefile

DESTDIR=${BUILD_DIR}/pyfakeroot2/ PATH="${BUILD_DIR}/pyfakeroot/usr/local/bin:$PATH:${MY_CROSS_PATH}" EXTRA_CFLAGS="-DCOMPILER=\\\"\\\" -Wno-builtin-macro-redefined -U__DATE__ -U__TIME__ ${OPT_CFLAGS}" make libinstall -j8

(_CUR_DIR=$(pwd); cd ${BUILD_DIR}/pyfakeroot2/; make -f $_CUR_DIR/Makefile pycremoval)

(
cd ${BUILD_DIR}/pyfakeroot2/usr/local/*/*
rm -r test/ || true
rm -r lib2to3/tests/ || true
rm -r unittest/test/ || true
rm -r ctypes/test/ || true
rm -r distutils/tests/ || true
rm -r tkinter/test/ || true
rm -r idlelib/idle_test/ || true
rm -r sqlite3/test/ || true
rm -r ensurepip/ || true
rm -r email/test || true
rm -r json/tests || true
rm -r bsddb/test || true
rm -r lib-tk/test || true
)

(
cd ${BUILD_DIR}/pyfakeroot2/usr/local/*/*
rm lib2to3/*Grammar*.pickle || true
)

(
cd ${BUILD_DIR}/pyfakeroot2/usr/local/*/*
if [ -f _sysconfigdata*.py ]; then
echo "# system configuration generated and used by the sysconfig module
build_time_vars = {'TZPATH': ''}" > $(echo _sysconfigdata*.py)
fi
)


# fixup ctypes to load
sed -i 's/pythonapi = PyDLL(None)/pythonapi = None/g' ${BUILD_DIR}/pyfakeroot2/usr/local/*/*/ctypes/__init__.py || true

PYTHONHOME=${BUILD_DIR}/pyfakeroot/usr/local ${BUILD_DIR}/pyfakeroot/usr/local/bin/python?.? $SRC_PATH/zipper.py ${BUILD_DIR}/pyfakeroot2/usr/local ../python_lib.zip

${MY_CROSS_PREFIX}objcopy -R .comment -R '.comment.*' -R .note -R '.note.*' -S ./python ../python-stripped

cd ..

cat python-stripped python_lib.zip > static_python
chmod u+x ./static_python

cp ./static_python ../final/static_python

cd ..


