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
(folder/'release-notes.md').write_text('''Lot solo : langue et caméra persistantes, panneau/caisse interactifs, journal de trois objectifs, sac avec récompense unique et migration des sauvegardes avec copie originale. Moteur portable inchangé. Tests du lot regroupés dans le LIRE-MOI.

Variante portable gratuite du laboratoire solo Archélys : moteur Godot officiel non modifié et données PCK séparées. Décompresser et garder EXE/PCK ensemble. Aucun changement des réglages de sécurité requis pour ce test ; le Contrôle intelligent peut encore bloquer le moteur non signé. LIRE-MOI avec version et tests attendus. Nom fixe Archelys-Laboratoire.exe, toujours non signé. Caméra rapprochée avec suivi et curseur de distance, PNJ de test avec dialogue manuel FR/EN, duel factice et sauvegarde solo. Panneau réseau ancien masqué, développement multijoueur reporté. Décors/mannequin provisoires.\n\nLe propriétaire a validé le premier build lab-09897ca sous Windows. Cet export modifié reste à retester sur Windows. Les connexions entre PC et sur Internet ne sont pas validées. Aucun contenu final ou moteur Pokémon 9G complet.\n''')
archive=folder/'Archelys-Laboratoire-Windows.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for file in [exe,pck,folder/'LIRE-MOI.txt',folder/'manifest.json',root/'docs/licenses/Godot-LICENSE.txt',root/'docs/licenses/Godot-COPYRIGHT.txt']:z.write(file,file.name)
with zipfile.ZipFile(archive) as z:assert z.testzip() is None
(folder/'SHA256SUMS.txt').write_text(hashlib.sha256(archive.read_bytes()).hexdigest()+'  '+archive.name+'\n')
print('Windows ZIP verified:',archive,archive.stat().st_size)
