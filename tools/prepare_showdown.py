#!/usr/bin/env python3
"""Build the pinned offline simulator; optional official Windows Node runtime."""
import argparse,hashlib,json,os,pathlib,shutil,subprocess,urllib.request,zipfile
ROOT=pathlib.Path(__file__).resolve().parents[1]
PIN='942cda71d14bf0618bd57991708a2e2734b6daba'
NODE='24.19.0'
p=argparse.ArgumentParser();p.add_argument('--source',type=pathlib.Path);p.add_argument('--windows',action='store_true');args=p.parse_args()
cache=pathlib.Path(os.environ.get('ARCHELYS_DEPENDENCY_CACHE',str(ROOT/'artifacts/dependencies')))
cache.mkdir(parents=True,exist_ok=True)
source=args.source or cache/'pokemon-showdown'
def run(*cmd,cwd=None):subprocess.run(cmd,cwd=cwd,check=True)
if not source.exists():
 run('git','clone','https://github.com/smogon/pokemon-showdown.git',str(source))
 run('git','checkout',PIN,cwd=source)
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=source,text=True).strip()==PIN,'Unexpected Showdown revision'
assert not subprocess.check_output(['git','status','--porcelain','--untracked-files=no'],cwd=source,text=True).strip(),'Modified upstream sources'
if not (source/'dist/sim/battle.js').exists():
 run('npm','ci','--omit=optional',cwd=source);run('node','build',cwd=source)
output=ROOT/'builds/showdown'
if output.exists():shutil.rmtree(output)
output.mkdir(parents=True)
# Retain dynamic data loading and historical Mega data; exclude source maps/server/random teams.
up=output/'upstream';up.mkdir()
for section in ['sim','lib','data','config']:
 shutil.copytree(source/'dist'/section,up/'dist'/section,ignore=shutil.ignore_patterns('*.map','*.d.ts','random-battles'))
shutil.copytree(source/'node_modules/ts-chacha20',up/'node_modules/ts-chacha20',ignore=shutil.ignore_patterns('*.map','*.d.ts'))
shutil.copy2(source/'LICENSE',output/'Showdown-LICENSE.txt')
shutil.copy2(source/'node_modules/ts-chacha20/LICENSE',output/'ts-chacha20-LICENSE.txt')
for name in ['bridge.cjs','policy.cjs']:shutil.copy2(ROOT/'combat/showdown'/name,output/name)
shutil.copy2(ROOT/'game/data/pokemon/laboratory.json',output/'catalog.json')
metadata={'showdown_commit':PIN,'protocol':1,'node_windows':NODE,'data':'gen9 with selected historical moves and Mega','source_modified':False,'integration_extensions':['Lucky Egg held-item metadata; XP remains in adventure','Persistent toxic status and new-battle stage reset']}
(output/'provenance.json').write_text(json.dumps(metadata,indent=2)+'\n')
if args.windows:
 asset=f'node-v{NODE}-win-x64.zip';base=f'https://nodejs.org/dist/v{NODE}/'
 sums=urllib.request.urlopen(base+'SHASUMS256.txt',timeout=60).read().decode()
 expected=next(line.split()[0] for line in sums.splitlines() if line.split()[-1]==asset)
 archive=cache/asset
 if not archive.exists():
  with urllib.request.urlopen(base+asset,timeout=60) as response,archive.open('wb') as f:shutil.copyfileobj(response,f)
 assert hashlib.sha256(archive.read_bytes()).hexdigest()==expected,'Node checksum mismatch'
 runtime=ROOT/'builds/runtime';runtime.mkdir(exist_ok=True)
 with zipfile.ZipFile(archive) as z:
  prefix=f'node-v{NODE}-win-x64/'
  for name,target in [('node.exe','node.exe'),('LICENSE','Node-LICENSE.txt')]:
   (runtime/target).write_bytes(z.read(prefix+name))
 metadata.update(node_archive_sha256=expected,node_exe_sha256=hashlib.sha256((runtime/'node.exe').read_bytes()).hexdigest())
 (output/'provenance.json').write_text(json.dumps(metadata,indent=2)+'\n')
 print('Windows Node official archive verified:',asset)
print('Offline Showdown prepared:',output)
