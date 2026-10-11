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
pck_sha256=hashlib.sha256(pck.read_bytes()).hexdigest()
exe_sha256=hashlib.sha256(exe.read_bytes()).hexdigest()
text=(root/'docs/development/LIRE_MOI_WINDOWS.txt').read_text(encoding='utf-8').format(
    commit=args.commit,short_commit=args.commit[:7],exe_sha256=exe_sha256,pck_sha256=pck_sha256)
(folder/'LIRE-MOI.txt').write_text(text,encoding='utf-8')
manifest={'commit':args.commit,'godot':'4.6.3','stage':'technical-laboratory',
          'windows_executable_sha256':exe_sha256,'game_pack_sha256':pck_sha256,'code_signing':'unsigned',
          'distribution':'portable-external-pck','unmodified_godot_template':True,
          'windows_execution':'not validated on Windows','network_validation':'deferred; prior lab-09897ca tested on localhost only'}
(folder/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
(folder/'release-notes.md').write_text("Blocs 4–6 regroupés : boutique/Centre/intérieurs, pêche et actions contextuelles, carte/Vol ; réglages cap/EXP/shiny/défi ; terrains/climats, politique de poseurs en IA difficile, quatre Méga historiques et doubles solo mono-cible. 17 espèces/38 attaques provisoires. Trois comparatifs FHD dans le ZIP, aucun style final adopté.\n\nParcours unique et limites dans LIRE-MOI. Questions restantes et propositions de noms/divinités dans Documentation (SPOILERS DEV). Reprise Nuzlocke avec Chapignon et règles complètes de doubles/raids restent à compléter. Sauvegarde schéma4 avec originaux v1/v2/v3 préservés. EXE Godot portable officiel inchangé ; garder EXE/PCK ensemble. Aucun test multijoueur demandé.\n",encoding='utf-8')
archive=folder/'Archelys-Laboratoire-Windows.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for file in [exe,pck,folder/'LIRE-MOI.txt',folder/'manifest.json',root/'docs/licenses/Godot-LICENSE.txt',root/'docs/licenses/Godot-COPYRIGHT.txt',root/'docs/licenses/PokeAPI-LICENSE.txt']:z.write(file,file.name)
    for file in sorted((root/'docs/design/comparatifs').glob('quartier-*.png')):z.write(file,'Comparatifs/'+file.name)
    z.write(root/'docs/design/PROPOSITIONS_NOMS_ET_DIVINITES.md','Documentation/Propositions-noms-et-divinites.md')
    z.write(root/'docs/sources/Questions-restantes-Archelys.xlsx','Documentation/Questions-restantes-Archelys.xlsx')
with zipfile.ZipFile(archive) as z:assert z.testzip() is None
(folder/'SHA256SUMS.txt').write_text(hashlib.sha256(archive.read_bytes()).hexdigest()+'  '+archive.name+'\n')
print('Windows ZIP verified:',archive,archive.stat().st_size)
