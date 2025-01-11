
import sys
import os
import glob
import errno
import sysconfig

def makedirs(dirname):
    try:
        os.makedirs(dirname)
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise

def main():
    sysconfig_file = glob.glob("_sysconfigdata*.py")
    assert len(sysconfig_file) == 1
    sysconfig_file = sysconfig_file[0]

    with open(sysconfig_file, 'r') as f:
        sysconfig_locals = {}
        exec(f.read(), {}, sysconfig_locals)
        build_time_vars = sysconfig_locals['build_time_vars']
    
    py_short_ver = '%d.%d' % sys.version_info[:2]

    my_build_time_vars = {
        'TZPATH': '',
        'CC': '/',
        'AR': '/',
        'ARFLAGS': '',
        'CFLAGS': '',
        'LDFLAGS': '',
        'CCSHARED': '',
        'LDSHARED': '/',
        'EXT_SUFFIX': '.cpython-.so',
        'SO': '.cpython-.so',
        'SOABI': 'cpython-',
        'LIBRARY': 'libpython' + py_short_ver + '.a',
        'LDLIBRARY': 'libpython' + py_short_ver + '.so',
    }

    for v in set(my_build_time_vars.keys()):
        if v not in build_time_vars:
            my_build_time_vars.pop(v)

    vars_to_keep = {'HAVE_GETENTROPY', 'HAVE_GETRANDOM', 'HAVE_GETRANDOM_SYSCALL', 'WITH_DOC_STRINGS', 'WITH_FREELISTS', 'WITH_PYMALLOC'}

    for v in vars_to_keep:
        if v in build_time_vars:
            my_build_time_vars[v] = build_time_vars[v]

    with open(sysconfig_file, 'w') as f:
        f.write('# system configuration generated and used by the sysconfig module\n')
        f.write('build_time_vars = {' + ', '.join(repr(v) + ': ' + repr(my_build_time_vars[v]) for v in sorted(my_build_time_vars.keys())) + '}\n')

    # 14d98ac31b9f4e5b89284271f03fb77fc81ab624
    # 3.2a5
    if '-' in os.path.basename(os.path.dirname(sysconfig.get_makefile_filename())):
        config_dirname = 'config-' + py_short_ver
    else:
        config_dirname = 'config'
    makedirs(config_dirname)
    with open(os.path.join(config_dirname, 'Makefile'), 'w') as f:
        pass

    makedirs('../../include/python' + py_short_ver)
    with open(os.path.join('../../include/python' + py_short_ver, 'pyconfig.h'), 'w') as f:
        pass
    with open(os.path.join('../../include/python' + py_short_ver, 'Python.h'), 'w') as f:
        pass

if __name__ == '__main__':
    main()
