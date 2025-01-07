
import sys
import os
import glob

def main():
    sysconfig_file = glob.glob("_sysconfigdata*.py")
    assert len(sysconfig_file) == 1
    sysconfig_file = sysconfig_file[0]

    with open(sysconfig_file, 'r') as f:
        sysconfig_locals = {}
        exec(f.read(), {}, sysconfig_locals)
        build_time_vars = sysconfig_locals['build_time_vars']

    my_build_time_vars = {'TZPATH': '', 'CC': 'cc', 'AR': 'ar', 'ARFLAGS': 'rcs', 'CFLAGS': '', 'LDFLAGS': '', 'CCSHARED': '-fPIC', 'LDSHARED': '-shared', 'EXT_SUFFIX': '.cpython-.so'}
    vars_to_keep = {'HAVE_GETENTROPY', 'HAVE_GETRANDOM', 'HAVE_GETRANDOM_SYSCALL', 'WITH_DOC_STRINGS'}

    for v in vars_to_keep:
        if v in build_time_vars:
            my_build_time_vars[v] = build_time_vars[v]

    with open(sysconfig_file, 'w') as f:
        f.write('# system configuration generated and used by the sysconfig module\n')
        f.write('build_time_vars = {' + ', '.join(repr(v) + ': ' + repr(my_build_time_vars[v]) for v in sorted(my_build_time_vars.keys())) + '}\n')
    
    py_short_ver = '%d.%d' % sys.version_info[:2]
    os.makedirs('config-' + py_short_ver, exist_ok=True)
    with open(os.path.join('config-' + py_short_ver, 'Makefile'), 'w') as f:
        pass

    os.makedirs('../../include/python' + py_short_ver, exist_ok=True)
    with open(os.path.join('../../include/python' + py_short_ver, 'pyconfig.h'), 'w') as f:
        pass

if __name__ == '__main__':
    main()
