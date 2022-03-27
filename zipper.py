
import sys
import os
import zipfile

zipfile.zlib.Z_DEFAULT_COMPRESSION = 9

def zip_dir(src_dir, dest_zip):
    with zipfile.ZipFile(dest_zip, 'w', zipfile.ZIP_DEFLATED) as zip_f:
        paths = []
        for root, dirs, files in os.walk(src_dir):
            for file in files:
                paths.append(os.path.join(root, file))
        
        paths = sorted(paths)
        
        for file in paths:
            info = zipfile.ZipInfo(os.path.relpath(file, src_dir))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.create_system = 0
            with open(file, 'rb') as f:
                content = f.read()
            zip_f.writestr(info, content)

def main():
    src_dir = sys.argv[1]
    dest_zip = sys.argv[2]
    zip_dir(src_dir, dest_zip)

if __name__ == '__main__':
    main()
