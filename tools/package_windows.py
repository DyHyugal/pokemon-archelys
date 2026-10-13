#!/usr/bin/env python3
import pathlib,zipfile,hashlib,json,argparse,os
root=pathlib.Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--commit',default='local');args=p.parse_args()
folder=root/'builds';exe=folder/'Archelys-Laboratoire.exe'
assert exe.is_file() and exe.read_bytes()[:2]==b'MZ','Windows PE executable missing'
pck=folder/'Archelys-Laboratoire.pck'
assert pck.is_file() and pck.read_bytes()[:4]==b'GDPC','External game pack missing or invalid'
template=pathlib.Path(os.environ.get('XDG_DATA_HOME',str(pathlib.Path.home()/'.local/share')))/'godot/export_templates/4.6.3.stable/windows_release_x86_64.exe'
assert template.is_file(),'Verified Godot release template required to package this portable build'
assert hashlib.sha256(exe.read_bytes()).digest()==hashlib.sha256(template.read_bytes()).digest(),'Portable executable must be the unchanged official Godot template'
simulator=folder/'showdown';node_runtime=folder/'runtime'
assert (simulator/'bridge.cjs').is_file() and (node_runtime/'node.exe').is_file(),'Prepared offline Showdown/Node runtime required'
provenance=json.loads((simulator/'provenance.json').read_text())
assert provenance['showdown_commit']=='942cda71d14bf0618bd57991708a2e2734b6daba'
assert hashlib.sha256((node_runtime/'node.exe').read_bytes()).hexdigest()==provenance['node_exe_sha256'],'Node executable modified since verified download'
pck_sha256=hashlib.sha256(pck.read_bytes()).hexdigest()
exe_sha256=hashlib.sha256(exe.read_bytes()).hexdigest()
text=(root/'docs/development/LIRE_MOI_WINDOWS.txt').read_text(encoding='utf-8').format(
    commit=args.commit,short_commit=args.commit[:7],exe_sha256=exe_sha256,pck_sha256=pck_sha256)
(folder/'LIRE-MOI.txt').write_text(text,encoding='utf-8')
manifest={'commit':args.commit,'godot':'4.6.3','stage':'technical-laboratory',
          'windows_executable_sha256':exe_sha256,'game_pack_sha256':pck_sha256,'code_signing':'unsigned',
          'showdown':provenance,'distribution':'portable-external-pck-with-offline-showdown','unmodified_godot_template':True,
          'windows_execution':'not validated on Windows','network_validation':'deferred; prior lab-09897ca tested on localhost only'}
(folder/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
(folder/'release-notes.md').write_text('D74 : boutique et héros Tripo retopologisés intégrés dans le havre, marche/course (Maj), racine sans dérive, prévisualisation et palettes expérimentales. Saves conservées. Coiffure/visage fixes ; autres décors encore maquettes, présentation des combats 2D à venir. Parcours et limites dans LIRE-MOI.\n',encoding='utf-8')
archive=folder/'Archelys-Laboratoire-Windows.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for file in [exe,pck,folder/'LIRE-MOI.txt',folder/'manifest.json',root/'docs/licenses/Godot-LICENSE.txt',root/'docs/licenses/Godot-COPYRIGHT.txt',root/'docs/licenses/PokeAPI-LICENSE.txt',root/'docs/licenses/LABORATORY_AUDIO.md']:z.write(file,file.name)
    for directory in [simulator,node_runtime]:
        for file in sorted(directory.rglob('*')):
            if file.is_file():z.write(file,file.relative_to(folder))
    for file in sorted((root/'docs/design/comparatifs').glob('*.png')):z.write(file,'Comparatifs/'+file.name)
    for file in sorted((root/'docs/design/concepts').iterdir()):
        if file.is_file():z.write(file,'Concepts/'+file.name)
    z.write(root/'docs/design/ATLAS_PROPOSE_2026-10-12.md','Documentation/Atlas-graphique.md')
    z.write(root/'docs/design/CONCEPT_PROMPTS_2026-10-12.json','Documentation/Concept-briefs.json')
    z.write(root/'docs/development/LOT_ATLAS_SERVICES_10_BLOCS.md','Documentation/Atlas-services-10-blocs.md')
    z.write(root/'docs/design/MESHY_PREMIER_LOT.md','Documentation/Meshy-premier-lot.md')
    z.write(root/'docs/development/LOT_DEMO_CANOPY_DIX_BLOCS.md','Documentation/Demo-canopy-dix-blocs.md')
    z.write(root/'docs/development/LOT_DEMO_PROGRESSION_SERVICES.md','Documentation/Demo-progression-services.md')
    z.write(root/'docs/development/LOT_DEMO_DIX_SYSTEMES.md','Documentation/Demo-dix-systemes.md')
    z.write(root/'docs/design/IMPORT_ASSETS_LOCAUX.md','Documentation/Import-assets-locaux.md')
    z.write(root/'docs/development/LOT_EXPLORATION_SAUVES_DEMO.md','Documentation/Exploration-sauves-demo.md')
    z.write(root/'docs/development/LOT_DEMO_HAVRE.md','Documentation/Lot-demo-havre.md')
    z.write(root/'docs/development/LOT_TRIPO_PILOTES.md','Documentation/Pilotes-Tripo.md')
    z.write(root/'game/assets/tripo/provenance.json','Documentation/Tripo-provenance.json')
    z.write(root/'game/assets/demo/provenance.json','Documentation/Demo-assets-provenance.json')
    z.write(root/'docs/design/ASSETS_3D_D68.md','Documentation/Assets3D.md')
    z.write(root/'docs/development/LOT_ASSETS_VISITES.md','Documentation/Lot-assets-visites.md')
    z.write(root/'game/assets/archipelago/provenance.json','Documentation/Assets-provenance.json')
    z.write(root/'docs/development/LOT_PREMIERE_ILE_12_BLOCS.md','Documentation/Premiere-ile-12-blocs.md')
    z.write(root/'docs/design/PROPOSITIONS_NOMS_ET_DIVINITES.md','Documentation/Propositions-noms-et-divinites.md')
    z.write(root/'docs/sources/Questions-restantes-Archelys.xlsx','Documentation/Questions-restantes-Archelys.xlsx')
with zipfile.ZipFile(archive) as z:assert z.testzip() is None
(folder/'SHA256SUMS.txt').write_text(hashlib.sha256(archive.read_bytes()).hexdigest()+'  '+archive.name+'\n')
print('Windows ZIP verified:',archive,archive.stat().st_size)
