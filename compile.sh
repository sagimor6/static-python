#!/bin/sh -e

MY_CROSS_PREFIX=/opt/aarch64-buildroot-linux-musl/bin/aarch64-buildroot-linux-musl-
MY_CROSS_PATH=/opt/aarch64-buildroot-linux-musl/bin
MY_CROSS_ARCH=aarch64-buildroot-linux-musl
MY_CROSS_ARCH2=linux-aarch64
MY_CROSS_ARCH3=aarch64

rm -rf final
mkdir final

rm -rf build
mkdir build

cd build

BUILD_DIR=$(pwd)

tar -xJf ../Python-3.9.7.tar.xz
#tar -xJf ../Python-2.7.18.tar.xz
tar -xJf ../xz-5.2.5.tar.xz
tar -xJf ../zlib-1.2.11.tar.xz
tar -xzf ../openssl-1.1.1l.tar.gz
tar -xzf ../bzip2-latest.tar.gz
tar -xzf ../libffi-3.4.2.tar.gz
tar -xzf ../ncurses-6.2.tar.gz
tar -xzf ../readline-8.1.tar.gz
tar -xzf ../gdbm-1.23.tar.gz
tar -xzf ../sqlite-autoconf-3380100.tar.gz
tar -xJf ../util-linux-2.37.4.tar.xz
# tar -xzf ../tcl8.6.12-src.tar.gz
# tar -xzf ../tk8.6.12-src.tar.gz

mkdir fake_root
mkdir pyfakeroot

cd zlib-1.2.11/
make distclean

LDFLAGS="-flto -ffat-lto-objects -Wl,--gc-sections -Os" CFLAGS="-ffunction-sections -fdata-sections -flto -ffat-lto-objects -Os" CROSS_PREFIX=${MY_CROSS_PREFIX} ./configure --prefix=$(pwd)/../fake_root/usr/local/

make clean
make all -j8
make install

cd ..

cd util-linux-2.37.4

PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=$MY_CROSS_ARCH --prefix=/usr/local --disable-all-programs --enable-libuuid --without-python CFLAGS="-I$(pwd)/../fake_root/usr/local/include -flto -ffat-lto-objects -ffunction-sections -fdata-sections -Os" LDFLAGS="-L$(pwd)/../fake_root/usr/local/lib -flto -ffat-lto-objects -Wl,--gc-sections -Os"

DESTDIR="$(pwd)/../fake_root" PATH="$PATH:${MY_CROSS_PATH}" make -j8 all
DESTDIR="$(pwd)/../fake_root" PATH="$PATH:${MY_CROSS_PATH}" make install

cd ..

# cd tcl8.6.12/unix
# 
# PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=$MY_CROSS_ARCH --with-system-sqlite --without-tzdata CFLAGS="-I${BUILD_DIR}/fake_root/usr/local/include -flto -ffat-lto-objects -ffunction-sections -fdata-sections -Os" LDFLAGS="-L${BUILD_DIR}/fake_root/usr/local/lib -flto -ffat-lto-objects -Wl,--gc-sections -Os"
# 
# DESTDIR="${BUILD_DIR}/fake_root" PATH="$PATH:${MY_CROSS_PATH}" make -j8 install-binaries
# 
# cd ../..
# 
# cd tk8.6.12/unix
# 
# PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=$MY_CROSS_ARCH --with-tcl="${BUILD_DIR}/fake_root/usr/local/lib" CFLAGS="-I${BUILD_DIR}/fake_root/usr/local/include -flto -ffat-lto-objects -ffunction-sections -fdata-sections -Os" LDFLAGS="-L${BUILD_DIR}/fake_root/usr/local/lib -flto -ffat-lto-objects -Wl,--gc-sections -Os"
# 
# DESTDIR="${BUILD_DIR}/fake_root" PATH="$PATH:${MY_CROSS_PATH}" make -j8 install-binaries
# 
# cd ../../
# 
# cd tcl8.6.12/unix
# 
# make distclean
# 
# PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=$MY_CROSS_ARCH --disable-shared --with-system-sqlite --without-tzdata CFLAGS="-I${BUILD_DIR}/fake_root/usr/local/include -flto -ffat-lto-objects -ffunction-sections -fdata-sections -Os" LDFLAGS="-L${BUILD_DIR}/fake_root/usr/local/lib -flto -ffat-lto-objects -Wl,--gc-sections -Os"
# 
# DESTDIR="${BUILD_DIR}/fake_root" PATH="$PATH:${MY_CROSS_PATH}" make -j8 install-binaries install-headers
# 
# cd ../..
# 
# cd tk8.6.12/unix
# 
# make distclean
# 
# PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=$MY_CROSS_ARCH  --disable-shared --with-tcl="{BUILD_DIR}/fake_root/usr/local/lib" CFLAGS="-I${BUILD_DIR}/fake_root/usr/local/include -flto -ffat-lto-objects -ffunction-sections -fdata-sections -Os" LDFLAGS="-L${BUILD_DIR}/fake_root/usr/local/lib -flto -ffat-lto-objects -Wl,--gc-sections -Os"
# 
# DESTDIR="${BUILD_DIR}/fake_root" PATH="$PATH:${MY_CROSS_PATH}" make -j8 install-binaries install-headers
# 
# cd ../..

cd sqlite-autoconf-3380100

PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=$MY_CROSS_ARCH CFLAGS="-DSQLITE_OMIT_COMPILEOPTION_DIAGS -I$(pwd)/../fake_root/usr/local/include -flto -ffat-lto-objects -ffunction-sections -fdata-sections -Os" LDFLAGS="-L$(pwd)/../fake_root/usr/local/lib -flto -ffat-lto-objects -Wl,--gc-sections -Os"

DESTDIR="$(pwd)/../fake_root" PATH="$PATH:${MY_CROSS_PATH}" make -j8 all
DESTDIR="$(pwd)/../fake_root" PATH="$PATH:${MY_CROSS_PATH}" make install

cd ..

cd ncurses-6.2/

PATH="$PATH:${MY_CROSS_PATH}" CFLAGS="-flto -ffat-lto-objects -ffunction-sections -fdata-sections -Os" LDFLAGS="-flto -ffat-lto-objects -Wl,--gc-sections -Os" ./configure --host=$MY_CROSS_ARCH INSTALL="/usr/bin/install -c --strip-program=${MY_CROSS_PREFIX}strip" --with-shared --disable-database --disable-termcap --with-fallbacks="dumb,vt100,linux,xterm-256color,vt400,xterm,putty,xterm-16color,xterm-88color,rxvt,putty-256color,konsole,screen" --prefix=/usr/local --disable-db-install --without-manpages --without-progs --without-tack --without-tests
PATH="$PATH:${MY_CROSS_PATH}" make -j8 all DESTDIR="$(pwd)/../fake_root"
PATH="$PATH:${MY_CROSS_PATH}" make install DESTDIR="$(pwd)/../fake_root"

cd ..

cd readline-8.1

PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=$MY_CROSS_ARCH CFLAGS="-I$(pwd)/../fake_root/usr/local/include -flto -ffat-lto-objects -ffunction-sections -fdata-sections -Os" LDFLAGS="-L$(pwd)/../fake_root/usr/local/lib -flto -ffat-lto-objects -Wl,--gc-sections -Os"
PATH="$PATH:${MY_CROSS_PATH}" make -j8 all DESTDIR="$(pwd)/../fake_root" MFLAGS="SHLIB_LIBS=\"-L$(pwd)/../fake_root/usr/local/lib -lncurses\""
PATH="$PATH:${MY_CROSS_PATH}" make install DESTDIR="$(pwd)/../fake_root"

cd ..

cd gdbm-1.23/

PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=$MY_CROSS_ARCH --enable-libgdbm-compat CFLAGS="-Wno-builtin-macro-redefined -U__DATE__ -U__TIME__ -I$(pwd)/../fake_root/usr/local/include -flto -ffat-lto-objects -ffunction-sections -fdata-sections -Os" LDFLAGS="-L$(pwd)/../fake_root/usr/local/lib -flto -ffat-lto-objects -Wl,--gc-sections -Os"

DESTDIR="$(pwd)/../fake_root" PATH="$PATH:${MY_CROSS_PATH}" make -j8 all
DESTDIR="$(pwd)/../fake_root" PATH="$PATH:${MY_CROSS_PATH}" make install

cd ..

cd xz-5.2.5/

CFLAGS="-flto -ffat-lto-objects -ffunction-sections -fdata-sections -Os" LDFLAGS="-flto -ffat-lto-objects -Wl,--gc-sections -Os" PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=${MY_CROSS_ARCH} --prefix="$(pwd)/../fake_root/usr/local"

PATH="$PATH:${MY_CROSS_PATH}" make clean

PATH="$PATH:${MY_CROSS_PATH}" make all -j8

PATH="$PATH:${MY_CROSS_PATH}" make install

cd ..

cd bzip2-1.0.8/

make clean

echo "

CFLAGS += -Os

" >> Makefile

make -j8 bzip2 CC="${MY_CROSS_PREFIX}gcc -Os -flto -ffat-lto-objects -ffunction-sections -fdata-sections -Wl,--gc-sections" AR=${MY_CROSS_PREFIX}ar RANLIB=${MY_CROSS_PREFIX}ranlib LDFLAGS="-flto -ffat-lto-objects -Wl,--gc-sections -Os"

make install PREFIX=$(pwd)/../fake_root/usr/local CC="${MY_CROSS_PREFIX}gcc -flto -ffat-lto-objects -ffunction-sections -fdata-sections" AR=${MY_CROSS_PREFIX}ar RANLIB=${MY_CROSS_PREFIX}ranlib LDFLAGS="-flto -ffat-lto-objects -Wl,--gc-sections"

make clean

make -f Makefile-libbz2_so -j8 all CC="${MY_CROSS_PREFIX}gcc -Os -flto -ffat-lto-objects -ffunction-sections -fdata-sections -Wl,--gc-sections" AR=${MY_CROSS_PREFIX}ar RANLIB=${MY_CROSS_PREFIX}ranlib LDFLAGS="-flto -ffat-lto-objects -Wl,--gc-sections -Os"

cp -d libbz2.so* $(pwd)/../fake_root/usr/local/lib
ln -s libbz2.so.?.?.? $(pwd)/../fake_root/usr/local/lib/libbz2.so

cd ..

cd libffi-3.4.2/

CFLAGS="-flto -ffat-lto-objects -ffunction-sections -fdata-sections -Os" LDFLAGS="-flto -ffat-lto-objects -Wl,--gc-sections -Os" PATH="$PATH:${MY_CROSS_PATH}" ./configure --host=${MY_CROSS_ARCH} --prefix=$(pwd)/../fake_root/usr/local --disable-multi-os-directory

PATH="$PATH:${MY_CROSS_PATH}" make all -j8

PATH="$PATH:${MY_CROSS_PATH}" make install

cd ..

cd openssl-1.1.1l/

LDFLAGS="-flto -ffat-lto-objects -Wl,--gc-sections -flto-partition=one -Os" CFLAGS="-ffunction-sections -fdata-sections -flto -ffat-lto-objects -flto-partition=one -Os" CROSS_COMPILE=${MY_CROSS_PREFIX} MACHINE=${MY_CROSS_ARCH3} RELEASE=5.1 SYSTEM=Linux BUILD=build ./config
#LDFLAGS="-flto -ffat-lto-objects -Wl,--gc-sections" CFLAGS="-ffunction-sections -fdata-sections -flto -ffat-lto-objects" CROSS_COMPILE=${MY_CROSS_PREFIX} ./Configure ${MY_CROSS_ARCH2}

echo "
#define PLATFORM \"platform: \"
#define DATE \"built on: \"
static const char compiler_flags[] = \"compiler: \";
" > crypto/buildinf.h

make all -j8 DESTDIR=$(pwd)/../fake_root

make install_sw -j8 DESTDIR=$(pwd)/../fake_root

cd ..

cd Python-3.9.7/
#cd Python-2.7.18/

./configure

DESTDIR=$(pwd)/../pyfakeroot/ make -j8 altinstall

make distclean

export PKG_CONFIG=pkg-config
export PKG_CONFIG_LIBDIR=$(pwd)/../fake_root/usr/local/lib/pkgconfig

LDFLAGS="-L$(pwd)/../fake_root/usr/local/lib" PATH="$(pwd)/../pyfakeroot/usr/local/bin:$PATH:${MY_CROSS_PATH}" ./configure --host=${MY_CROSS_ARCH} --build=x86_64-pc-linux-gnu --enable-ipv6 --with-system-ffi --with-ensurepip=no --with-openssl=$(pwd)/../fake_root/usr/local ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no LIBFFI_INCLUDEDIR=$(pwd)/../fake_root/usr/local/include CPPFLAGS="-I$(pwd)/../fake_root/usr/local/include -I$(pwd)/../fake_root/usr/local/include/ncurses -I$(pwd)/../fake_root/usr/local/include/uuid"

echo "
*shared*

_testcapi




" >> Modules/Setup.local

mv setup.py setup2.py
cp ../../get_setup_modules.py setup.py
DESTDIR=$(pwd)/../pyfakeroot/ PATH="$(pwd)/../pyfakeroot/usr/local/bin:$PATH:${MY_CROSS_PATH}" make sharedmods -j8
rm -f setup.py
mv setup2.py setup.py

make distclean

rm -f Modules/Setup.local
mv modules_to_add Modules/Setup.local

CFLAGS="-DCOMPILER=\"\\\"\\\"\" -Wno-builtin-macro-redefined -U__DATE__ -U__TIME__ -ffunction-sections -fdata-sections -Os" LINKFORSHARED=" " LDFLAGS="-Wl,--whole-archive -lpthread -Wl,--no-whole-archive -static -Wl,--gc-sections -L$(pwd)/../fake_root/usr/local/lib -Os" PATH="$(pwd)/../pyfakeroot/usr/local/bin:$PATH:${MY_CROSS_PATH}" ./configure --host=${MY_CROSS_ARCH} --build=x86_64-pc-linux-gnu --enable-ipv6 --enable-optimizations --with-lto --with-system-ffi --with-ensurepip=no --disable-shared --with-tzpath="" --with-openssl=$(pwd)/../fake_root/usr/local ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no LIBFFI_INCLUDEDIR=$(pwd)/../fake_root/usr/local/include CPPFLAGS="-I$(pwd)/../fake_root/usr/local/include -I$(pwd)/../fake_root/usr/local/include/ncurses -I$(pwd)/../fake_root/usr/local/include/uuid"

echo "

#include <stdlib.h>

static void __attribute__((constructor)) my_pythonhome_ctor() {
	putenv(\"PYTHONHOME=/proc/self/exe\");
}

" >> Modules/errnomodule.c

if [ -f ./Lib/plat-generic/regen ]; then
echo "#!/bin/sh
" > ./Lib/plat-generic/regen
fi

mkdir $(pwd)/../pyfakeroot2/ || true
DESTDIR=$(pwd)/../pyfakeroot2/ PATH="$(pwd)/../pyfakeroot/usr/local/bin:$PATH:${MY_CROSS_PATH}" make libinstall -j8

(_CUR_DIR=$(pwd); cd $(pwd)/../pyfakeroot2/; make -f $_CUR_DIR/Makefile pycremoval)

(
cd $(pwd)/../pyfakeroot2/usr/local/*/*
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
cd $(pwd)/../pyfakeroot2/usr/local/*/*
rm lib2to3/*Grammar*.pickle || true
)

(
cd $(pwd)/../pyfakeroot2/usr/local/*/*
if [ -f _sysconfigdata*.py ]; then
echo "# system configuration generated and used by the sysconfig module
build_time_vars = {'TZPATH': ''}" > $(echo _sysconfigdata*.py)
fi
)


# fixup ctypes to load
sed -i 's/pythonapi = PyDLL(None)/pythonapi = None/g' $(pwd)/../pyfakeroot2/usr/local/*/*/ctypes/__init__.py || true

#(cd $(pwd)/../pyfakeroot2/usr/local; zip -r ../../../python_lib.zip *)
PYTHONHOME=$(pwd)/../pyfakeroot/usr/local $(pwd)/../pyfakeroot/usr/local/bin/python?.? ../../zipper.py $(pwd)/../pyfakeroot2/usr/local ../python_lib.zip

${MY_CROSS_PREFIX}objcopy -R .comment -R '.comment.*' -R .note -R '.note.*' -S ./python ../python-stripped

cd ..

cat python-stripped python_lib.zip > static_python
chmod u+x ./static_python

cp ./static_python ../final/static_python

cd ..


