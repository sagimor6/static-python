
import os
import subprocess
import re
import requests
import argparse

def main():
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('arch', help='The architecture. E.g: aarch64, x86_64, ...')
    parser.add_argument('libc', help='The libc. E.g: musl, glibc, ...')
    parser.add_argument('--date', help='The toolchain date. E.g: 2021.11, 2020.08, ...')
    parser.add_argument('--bleeding', action='store_true', default=False, help='Use bleeding edge toolchain, not the stable one')
    parser.add_argument('--extract', action='store_true', default=False, help='Exctact toolchain')
    
    args = parser.parse_args()
    
    url = 'https://toolchains.bootlin.com/downloads/releases/toolchains/{}/tarballs/'.format(args.arch)
    
    body = requests.get(url).text
    
    matcher = re.compile(r'\<a\shref=\"(?P<url>(?P<arch>\w(\w|\-\w)*)\-\-(?P<libc>\w+)\-\-(?P<stability>(stable|bleeding\-edge))\-(?P<date>[0-9]{4}\.[0-9]{2})\-(?P<num>[0-9]+)\.tar\.bz2)\"\>')
    
    matches = []
    
    best_match = None
    
    for match in matcher.finditer(body):
        match = match.groupdict()
        if match['arch'] != args.arch:
            continue
        
        if match['libc'] != args.libc:
            continue
        
        if args.date is not None:
            if match['date'] != args.date and match['date'] + '-' + match['num'] != args.date:
                continue
        
        if args.bleeding:
            if match['stability'] != 'bleeding-edge':
             continue
        else:
            if match['stability'] != 'stable':
             continue
        
        if best_match is None or (best_match['date'] < match['date'] or (best_match['date'] == match['date'] and int(best_match['num'], 10) < int(match['num'], 10))):
            best_match = match
    
    assert best_match is not None
    
    filename = best_match['url'] # filename is ok according to regex, no path traversal
    url = 'https://toolchains.bootlin.com/downloads/releases/toolchains/{}/tarballs/{}'.format(args.arch, filename)
    
    print('downloading from {}'.format(url))
    
    content = requests.get(url).content
    with open(filename, 'wb') as f:
        f.write(content)
    
    if args.extract:
        subprocess.call(['tar', '-xjf', filename])
        
        dir_name = filename[:-len('.tar.bz2')]
        
        gcc = None
        for fname in os.listdir(os.path.join(dir_name, 'bin')):
            if fname.endswith('-gcc'):
                if gcc is None or len(gcc) < len(fname):
                    gcc = fname
        
        if gcc is not None:
            prefix = gcc[:-len('-gcc')]
            print('compile with: MY_CROSS_ARCH="{}" MY_CROSS_PATH="{}"'.format(prefix, os.path.join(os.getcwd(), dir_name, 'bin')))


if __name__ == '__main__':
    main()
