#!/usr/bin/env python3
"""Checks actual prototype paths; errors or missing markers fail the run."""
import pathlib,subprocess,os,sys,argparse
parser=argparse.ArgumentParser();parser.add_argument("--network",action="store_true",help="Run the retained localhost regression, not required for solo development");args=parser.parse_args()
root=pathlib.Path(__file__).resolve().parents[1]
env=os.environ.copy()
runtime=pathlib.Path(env.get('ARCHELYS_RUNTIME_ROOT','/tmp/archelys-test-runtime'))
for label,var in [('data','XDG_DATA_HOME'),('config','XDG_CONFIG_HOME'),('cache','XDG_CACHE_HOME')]:
    env.setdefault(var,str(runtime/label));pathlib.Path(env[var]).mkdir(parents=True,exist_ok=True)
steps=[(['godot','--headless','--path',str(root/'game'),'--editor','--import','--quit'],None),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/run_tests.gd'],'ARCHÉLYS TESTS: 19 checks, 0 failures'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/dialogue_tests.gd'],'DIALOGUE TESTS: 6 checks, 0 failures'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/asset_import.gd'],'GLB IMPORT:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/scene_smoke.gd'],'SCENE SMOKE:')]
if args.network:
    steps.append(([sys.executable,str(root/'tools/check_network.py')],'NETWORK client-b: players=3, gate=true'))
for command,marker in steps:
    result=subprocess.run(command,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=60)
    print(result.stdout,flush=True)
    if result.returncode or 'SCRIPT ERROR:' in result.stdout or '\nERROR:' in result.stdout or (marker and marker not in result.stdout):
        raise SystemExit('Prototype check failed: '+' '.join(command))
print('ALL PROTOTYPE CHECKS PASSED')
