# static-python

[![General CI](https://github.com/sagimor6/static-python/workflows/General%20CI/badge.svg?event=push)](https://github.com/sagimor6/static-python/actions/workflows/general-ci.yml)

[![Automatic ci](https://github.com/sagimor6/static-python/actions/workflows/automatic.yml/badge.svg?branch=master&event=push)](https://github.com/sagimor6/static-python/actions/workflows/automatic.yml)

This script is supposed to cross compile a statically linked python 3 or 2.
The result is a single file that contains python and all its builtin modules.

My goal is that the build will be reproducible and deterministic
(if two people compile using this script with the same toolchain and module versions, the results should be the same).

Currently, the script minimizes size in exchange for performance.

The script was tested with python 3.9.7 and 2.7.18 for aarch64 and worked.

USAGE:
```
make distclean
MY_CROSS_ARCH=aarch64-buildroot-linux-musl MY_CROSS_PATH=/opt/aarch64-buildroot-linux-musl/bin Python_VER=3.9.7 make -j all
```

In order to blacklist modules use the ``MODULE_BLACKLIST`` environment variable, which is a list of module names seperated by spaces.
for example to build a very minimal static python:
```
export MODULE_BLACKLIST="gdbm dbm crypt _xxsubinterpreters audioop _testcapi _testinternalcapi _testbuffer _testimportmultiple _testmultiphase _xxtestfuzz readline _curses _curses_panel _crypt _ssl _hashlib _dbm _gdbm _sqlite3 ossaudiodev _bz2 _lzma pyexpat _elementtree _multibytecodec _codecs_kr _codecs_jp _codecs_cn _codecs_tw _codecs_hk _codecs_iso2022 _decimal _ctypes_test _ctypes _uuid xxlimited"
make -j all
```

When building the Dockerfile, you need to pass ARCH and LIBC args. for exmaple:
```
docker build -t static_python_gen --build-arg=ARCH=aarch64 --build-arg=LIBC=musl .
```

TODO:
- I currently don't support the tkinter module.
- There are no tests.
- Don't compile dependencies of blacklisted modules.
- Enable option to remove non binary modules, like distutils.
- more TODOs.

