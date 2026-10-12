#!/usr/bin/env python3
"""Checks actual prototype paths; errors or missing markers fail the run."""
import pathlib,subprocess,os,sys,argparse,shutil
parser=argparse.ArgumentParser();parser.add_argument("--network",action="store_true",help="Run the retained localhost regression, not required for solo development");args=parser.parse_args()
root=pathlib.Path(__file__).resolve().parents[1]
env=os.environ.copy()
runtime=pathlib.Path(env.get('ARCHELYS_RUNTIME_ROOT','/tmp/archelys-test-runtime'))
for label,var in [('data','XDG_DATA_HOME'),('config','XDG_CONFIG_HOME'),('cache','XDG_CACHE_HOME')]:
    env.setdefault(var,str(runtime/label));pathlib.Path(env[var]).mkdir(parents=True,exist_ok=True)
env.setdefault('ARCHELYS_NODE_BIN',shutil.which('node') or '')
steps=[(['godot','--headless','--path',str(root/'game'),'--editor','--import','--quit'],None),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/demo_scene.gd'],'DEMO SCENE:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/demo_contracts.gd'],'DEMO CONTRACTS:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/demo_navigation.gd'],'DEMO NAVIGATION:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/demo_services.gd'],'DEMO SERVICES:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/demo_extended.gd'],'DEMO EXTENDED:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/demo_chapter.gd'],'DEMO CHAPTER:'),
       ([sys.executable,str(root/'tools/check_demo_content.py')],'DEMO CONTENT:'),
       ([sys.executable,str(root/'tools/check_demo_content_contracts.py')],'DEMO CONTENT CONTRACTS:'),
       ([sys.executable,str(root/'tools/check_demo_asset_import.py')],'DEMO ASSET IMPORT:'),
       ([env['ARCHELYS_NODE_BIN'],str(root/'combat/showdown/tests.cjs')],'SHOWDOWN ADAPTER:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/showdown_integration.gd'],'SHOWDOWN INTEGRATION:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/battle_options.gd'],'BATTLE OPTIONS:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/battle_readability.gd'],'BATTLE READABILITY:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/atlas_services.gd'],'ATLAS SERVICES:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/atlas_scene.gd'],'ATLAS SCENE:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/archipelago_assets.gd'],'ARCHIPELAGO ASSETS:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/island_systems.gd'],'ISLAND SYSTEMS:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/island_scene.gd'],'ISLAND SCENE:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/run_tests.gd'],'ARCHÉLYS TESTS: 19 checks, 0 failures'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/journey_systems.gd'],'JOURNEY SYSTEMS: 17 checks, 0 failures'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/journey_scene.gd'],'JOURNEY SCENE:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/fossil_systems.gd'],'FOSSIL SYSTEMS: 23 checks, 0 failures'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/nursery_systems.gd'],'NURSERY SYSTEMS: 18 checks, 0 failures'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/solo_systems.gd'],'SOLO SYSTEMS: 18 checks, 0 failures'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/dialogue_tests.gd'],'DIALOGUE TESTS: 6 checks, 0 failures'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/pokemon_systems.gd'],'POKEMON SYSTEMS: 71 checks, 0 failures'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/exploration_combat.gd'],'EXPLORATION COMBAT: 70 checks, 0 failures'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/exploration_scene.gd'],'EXPLORATION SCENE:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/pokemon_scene.gd'],'POKEMON SCENE:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/mega_ui.gd'],'MEGA UI:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/collection_systems.gd'],'COLLECTION SYSTEMS:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/collection_scene.gd'],'COLLECTION SCENE:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/storage_systems.gd'],'STORAGE SYSTEMS:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/storage_scene.gd'],'STORAGE SCENE:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/presentation_systems.gd'],'PRESENTATION SYSTEMS:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/presentation_scene.gd'],'PRESENTATION SCENE:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/comfort_systems.gd'],'COMFORT SYSTEMS:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/comfort_scene.gd'],'COMFORT SCENE:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/tactics_systems.gd'],'TACTICS SYSTEMS: 46 checks, 0 failures'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/tactics_scene.gd'],'TACTICS SCENE:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/asset_import.gd'],'GLB IMPORT:'),
       (['godot','--headless','--path',str(root/'game'),'--script','res://tests/scene_smoke.gd'],'SCENE SMOKE:')]
if args.network:
    steps.append(([sys.executable,str(root/'tools/check_network.py')],'NETWORK client-b: players=3, gate=true'))
for command,marker in steps:
    result=subprocess.run(command,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=60)
    print(result.stdout,flush=True)
    if result.returncode or 'SCRIPT ERROR:' in result.stdout or '\nERROR:' in result.stdout or (marker and marker not in result.stdout):
        if env.get('GITHUB_ACTIONS')=='true':
            details=(' '.join(command)+'\n'+result.stdout[-6000:]).replace('%','%25').replace('\r','%0D').replace('\n','%0A')
            print('::error title=Prototype check failed::'+details,flush=True)
        raise SystemExit('Prototype check failed: '+' '.join(command))
print('ALL PROTOTYPE CHECKS PASSED')
