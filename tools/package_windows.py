#!/usr/bin/env python3
import pathlib,zipfile,hashlib,json,argparse
root=pathlib.Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--commit',default='local');args=p.parse_args()
folder=root/'builds';exe=folder/'Archelys-Laboratoire.exe'
assert exe.is_file() and exe.read_bytes()[:2]==b'MZ','Windows PE executable missing'
text='''ARCHÉLYS — LABORATOIRE TECHNIQUE\n\nDécompresser entièrement le ZIP puis lancer Archelys-Laboratoire.exe.\nWindows 64 bits. Prototype non signé ; pas une version finale.\nGraphismes et mannequin provisoires. Combat factice, pas de moteur 9G complet.\nZQSD/WASD/flèches pour marcher. Caméra plus proche, suit le joueur ; curseur distance dans le panneau.\nGuide près du départ : E / A / Entrée pour parler et avancer manuellement ; FR/EN pour choisir les textes.\nPorte turquoise : étape de campagne factice.\nSolo prioritaire ; ancien panneau réseau masqué derrière une case optionnelle.\nServeur de cet ancien essai : localhost uniquement, trois fenêtres sur le même PC.\nNe pas exposer ce laboratoire sur Internet. Invitations/LAN publiques non validées.\nSauvegarde et chargement solo ; import réseau non implémenté.\nCopie précédente : laboratory_campaign.json.backup à côté de la sauvegarde.\nSur Windows : %APPDATA%\\Godot\\app_userdata\\Archélys — laboratoire technique\\\nRestauration prototype : fermer le jeu, copier le fichier .backup vers laboratory_campaign.json.\nLe jeu n'est pas une ROM. Il ne contient aucun modèle Pokémon officiel.\n'''
(folder/'LIRE-MOI.txt').write_text(text,encoding='utf-8')
manifest={'commit':args.commit,'godot':'4.6.3','stage':'technical-laboratory',
          'windows_executable_sha256':hashlib.sha256(exe.read_bytes()).hexdigest(),
          'windows_execution':'not validated on Windows','network_validation':'deferred; prior lab-09897ca tested on localhost only'}
(folder/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
(folder/'release-notes.md').write_text('''Suite solo du laboratoire Archélys. Caméra rapprochée avec suivi et curseur de distance, PNJ de test avec dialogue manuel FR/EN, duel factice et sauvegarde solo. Panneau réseau ancien masqué, développement multijoueur reporté. Décors/mannequin provisoires.\n\nLe propriétaire a validé le premier build lab-09897ca sous Windows. Cet export modifié reste à retester sur Windows. Les connexions entre PC et sur Internet ne sont pas validées. Aucun contenu final ou moteur Pokémon 9G complet.\n''')
archive=folder/'Archelys-Laboratoire-Windows.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for file in [exe,folder/'LIRE-MOI.txt',folder/'manifest.json']:z.write(file,file.name)
with zipfile.ZipFile(archive) as z:assert z.testzip() is None
(folder/'SHA256SUMS.txt').write_text(hashlib.sha256(archive.read_bytes()).hexdigest()+'  '+archive.name+'\n')
print('Windows ZIP verified:',archive,archive.stat().st_size)
