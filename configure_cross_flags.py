
import subprocess
import os
import tempfile
import shutil

def run_cross_cmd(cmd, *flags):
    cross_prefix = os.environ['CROSS_PREFIX']
    with open('/dev/null', 'r+b') as devnull:
        proc = subprocess.Popen((cross_prefix + cmd,) + flags, stdin=devnull, stdout=devnull, stderr=devnull, shell=False)
    return proc.wait()

def main():
    
    dir = tempfile.mkdtemp()
    try:
        with open(os.path.join(dir, 'test.c'), 'w') as f:
            f.write("""

                double d = 90904234967036810337470478905505011476211692735615632014797120844053488865816695273723469097858056257517020191247487429516932130503560650002327564517570778480236724525140520121371739201496540132640109977779420565776568942592.0;

            """)
        
        assert run_cross_cmd('gcc', '-c', '-o', os.path.join(dir, 'test.o'), os.path.join(dir, 'test.c')) == 0

        with open(os.path.join(dir, 'test.o'), 'rb') as f:
            res = f.read()
        
        if b'noonsees' in res:
            print('ac_cv_big_endian_double=yes')
        elif b'seesnoon' in res:
            print('ac_cv_little_endian_double=yes')
    finally:
        shutil.rmtree(dir)
    
    print('ac_cv_working_tzset=yes')
        
            

if __name__ == '__main__':
    main()
