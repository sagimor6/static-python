# static-python

This script is supposed to cross compile a statically linked python 3 or 2.
The result is a single file that contains python and all its builtin modules.

My goal is that the build will be reproducible and deterministic
(if two people compile using this script with the same toolchain and module versions, the results should be the same).

Currently, the script minimizes size in exchange for performance.

The script was tested with python 3.9.7 and 2.7.18 for aarch64 and worked.

USAGE:
``
    make distclean
    Python_VER=3.9.7 make -j all
``


TODO:
- I currently don't support the tkinter module.
- There are no tests.
- Allow the user to disable modules (not by editing the script).
- more TODOs.

