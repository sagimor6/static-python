
import sys
import os
import sysconfig

sys.path.append('.')

import setup2

def get_setup_build_ext():
    class Dummy:
        pass
    res = Dummy()
    from distutils.command.build_ext import build_ext
    
    orig_sysconfig_get_config_var = sysconfig.get_config_var
    
    def sysconfig_get_config_var(name):
        if name == 'PYTHONFRAMEWORK':
            return 'a'
        else:
            return orig_sysconfig_get_config_var(name)
    
    class MyBuildExt(build_ext):
        def __init__(self, dist):
            build_ext.__init__(self, dist)
            
        def build_extensions(self):
            
            if 'MODULE_BLACKLIST' in os.environ and len(os.environ['MODULE_BLACKLIST'].strip()) != 0:
                module_blacklist = set(os.environ['MODULE_BLACKLIST'].strip().split(' '))
                exts = []
                for e in self.extensions:
                    if e.name in module_blacklist:
                        self.failed.append(e.name)
                    else:
                        exts.append(e)
                self.extensions = exts

            for e in self.extensions:
                e.library_dirs = [x for x in e.library_dirs if not x.startswith('/usr/lib')]
            
            build_ext.build_extensions(self)
            
            lines = []
            for e in self.extensions:
                if e.name in self.failed:
                    continue
                defines_and_flags = ' '.join(['-D' + define_to_str(x) for x in e.define_macros] + [x for x in e.extra_compile_args])
                if e.name == '_testcapi':
                    defines_and_flags += ' -UPy_BUILD_CORE_BUILTIN -UPy_BUILD_CORE '
                def_line = '__' + e.name + '_DEFS=__BLABLA__ ' + defines_and_flags
                line = [
                    e.name,
                    ' '.join([normalize_path(x) for x in e.sources]),
                    ' '.join([x for x in e.extra_objects]),
                    ' '.join(['-I' + x for x in e.include_dirs]),
                    ' '.join(['-U' + x for x in e.undef_macros]),
                    ' '.join(['-L' + x for x in e.library_dirs]),
                    ' '.join(['-l' + x for x in e.libraries]),
                    ' '.join([x for x in e.extra_link_args]),
                    '-D$(__' + e.name + '_DEFS)' if len(defines_and_flags) != 0 else ''
                ]
                if len(defines_and_flags) != 0:
                    lines.append(def_line)
                line = ' '.join(line) + ' '
                assert '=' not in line
                lines.append(line)
            
            lines = '\n'.join(lines)
            lines += '\n'
            
            with open('modules_to_add', 'w') as f:
                f.write(lines)
            with open('failed_modules', 'w') as f:
                f.write(' ,'.join(self.failed))
    
    def setup_fake(*args, **kwargs):
        #print((args, kwargs))
        #  kwargs['cmdclass']['build_ext'], kwargs['ext_modules']
        kwargs['script_args'] = ['build_ext']
        class MyMyBuildExt(kwargs['cmdclass']['build_ext'], MyBuildExt):
            pass
        kwargs['cmdclass']['build_ext'] = MyMyBuildExt
        from distutils.core import Extension, setup
        res.dist = setup(*args, **kwargs)
    
    def define_to_str(d):
        if type(d) == str:
            return d
        else:
            d_val = d[1]
            if d_val is not None:
                d_val = d_val.replace('"', "\\"*4 + '"') # escape
            return d[0] + (('=' + d_val) if d_val is not None else '')
    
    def normalize_path(s):
        return os.path.relpath(s, 'Modules')
    
    if sys.version_info.major == 2:
        plat = setup2.host_platform
        if '-' in plat:
            plat = plat[:plat.find('-')]
        setup2.host_platform = plat
    
    setup2.setup = setup_fake
    setup2.build_ext = MyBuildExt
    setup2.sysconfig.get_config_var = sysconfig_get_config_var
    setup2.find_executable = lambda x: None
    
    if hasattr(setup2, 'COMPILED_WITH_PYDEBUG'):
        setup2.COMPILED_WITH_PYDEBUG = True
    
    setup2.main()
    
    return res.dist

def main():
    get_setup_build_ext()
    

if __name__ == '__main__':
    main()

