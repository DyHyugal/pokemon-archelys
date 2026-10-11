#!/usr/bin/env python3
"""Download pinned official Godot archives with upstream SHA-512 verification."""
import argparse,hashlib,pathlib,urllib.request,zipfile,os,json
VERSION='4.6.3'
BASE=f'https://github.com/godotengine/godot-builds/releases/download/{VERSION}-stable/'
def install(prefix,templates):
    prefix=prefix.resolve();prefix.mkdir(parents=True,exist_ok=True)
    with urllib.request.urlopen(BASE+'SHA512-SUMS.txt',timeout=60) as response:sums=response.read().decode()
    expected={line.split()[-1].lstrip('*'):line.split()[0] for line in sums.splitlines() if len(line.split())==2}
    records=[]
    for name in [f'Godot_v{VERSION}-stable_linux.x86_64.zip']+([f'Godot_v{VERSION}-stable_export_templates.tpz'] if templates else []):
        if name not in expected:raise RuntimeError(f'Upstream checksum missing: {name}')
        archive=prefix/name
        digest=hashlib.sha512()
        if archive.exists():
            with archive.open('rb') as stream:
                while chunk:=stream.read(4*1024*1024):digest.update(chunk)
        if digest.hexdigest()!=expected[name]:
            digest=hashlib.sha512()
            with urllib.request.urlopen(BASE+name,timeout=90) as response,archive.open('wb') as target:
                while chunk:=response.read(4*1024*1024):target.write(chunk);digest.update(chunk)
        if digest.hexdigest()!=expected[name]:raise RuntimeError(f'SHA-512 mismatch: {name}')
        with zipfile.ZipFile(archive) as z:
            if name.endswith('.zip'):
                entry=f'Godot_v{VERSION}-stable_linux.x86_64'
                output=prefix/'bin/godot';output.parent.mkdir(exist_ok=True)
                with z.open(entry) as source,output.open('wb') as target:
                    while chunk:=source.read(4*1024*1024):target.write(chunk)
                output.chmod(0o755)
            else:
                folder=prefix/f'data/godot/export_templates/{VERSION}.stable';folder.mkdir(parents=True,exist_ok=True)
                for entry in ['windows_release_x86_64.exe','windows_debug_x86_64.exe']:
                    with z.open('templates/'+entry) as source,(folder/entry).open('wb') as target:
                        while chunk:=source.read(4*1024*1024):target.write(chunk)
        records.append({'artifact':name,'url':BASE+name,'sha512':expected[name]})
        print('Verified:',name,flush=True)
    (prefix/'verified-artifacts.json').write_text(json.dumps(records,indent=2))
    print('PATH:',prefix/'bin');print('XDG_DATA_HOME:',prefix/'data')
if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--prefix',type=pathlib.Path,required=True);parser.add_argument('--templates',action='store_true')
    args=parser.parse_args();install(args.prefix,args.templates)
