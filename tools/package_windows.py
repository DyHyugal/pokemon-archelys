#!/usr/bin/env python3
import pathlib,zipfile,hashlib,json,argparse
root=pathlib.Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--commit',default='local');args=p.parse_args()
folder=root/'builds';exe=folder/'Archelys-Laboratoire.exe'
assert exe.is_file() and exe.read_bytes()[:2]==b'MZ','Windows PE executable missing'
exe_sha256=hashlib.sha256(exe.read_bytes()).hexdigest()
text=(root/'docs/development/LIRE_MOI_WINDOWS.txt').read_text(encoding='utf-8').format(
    commit=args.commit,short_commit=args.commit[:7],exe_sha256=exe_sha256)
(folder/'LIRE-MOI.txt').write_text(text,encoding='utf-8')
manifest={'commit':args.commit,'godot':'4.6.3','stage':'technical-laboratory',
          'windows_executable_sha256':exe_sha256,'code_signing':'unsigned',
          'windows_execution':'not validated on Windows','network_validation':'deferred; prior lab-09897ca tested on localhost only'}
(folder/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
(folder/'release-notes.md').write_text('''Laboratoire solo Archélys avec LIRE-MOI détaillé : version, tests attendus et aide pour les avertissements Windows. Nom fixe Archelys-Laboratoire.exe, toujours non signé. Caméra rapprochée avec suivi et curseur de distance, PNJ de test avec dialogue manuel FR/EN, duel factice et sauvegarde solo. Panneau réseau ancien masqué, développement multijoueur reporté. Décors/mannequin provisoires.\n\nLe propriétaire a validé le premier build lab-09897ca sous Windows. Cet export modifié reste à retester sur Windows. Les connexions entre PC et sur Internet ne sont pas validées. Aucun contenu final ou moteur Pokémon 9G complet.\n''')
archive=folder/'Archelys-Laboratoire-Windows.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for file in [exe,folder/'LIRE-MOI.txt',folder/'manifest.json']:z.write(file,file.name)
with zipfile.ZipFile(archive) as z:assert z.testzip() is None
(folder/'SHA256SUMS.txt').write_text(hashlib.sha256(archive.read_bytes()).hexdigest()+'  '+archive.name+'\n')
print('Windows ZIP verified:',archive,archive.stat().st_size)
