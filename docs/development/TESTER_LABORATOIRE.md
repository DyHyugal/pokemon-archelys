# Tester le laboratoire

Le laboratoire est un outil de faisabilité : graphismes, avatar et combat sont provisoires. Aucun Pokémon final ni histoire jouable n’est intégré.

## Windows

Le ZIP de prerelease, quand publié par le workflow, contient l’exécutable, un LIRE-MOI et un manifeste. Décompresser entièrement puis lancer l’exe. Aucune installation Godot pour jouer à cet export. Export créé sur Linux ; exécution réelle sous Windows attend la validation du propriétaire.

ZQSD/WASD/flèches : déplacer le personnage. Maisons/arbres bloquent les passages. Porte turquoise : une étape factice, attend le nombre de participants. Boutons : sauvegarde, chargement solo, simulation d’un tour et retour au début du combat factice.

Essai coop : trois fenêtres sur le même PC. Première = Héberger ; autres = Rejoindre à 127.0.0.1. Ce serveur écoute seulement localhost ; ce ZIP n’est pas encore une invitation Internet ou un essai entre deux PC. Maximum trois participants.

La simulation de combat du panneau reste locale et séparée du réseau : elle ne prétend pas démontrer un combat coop synchronisé. Les entrées clavier ne doivent pas déplacer le joueur quand il écrit l’adresse.

## Sauvegardes de prototype

Sous Windows, dossier habituel : `%APPDATA%\Godot\app_userdata\Archélys — laboratoire technique\`. `laboratory_campaign.json` et copie précédente `.backup`. Pour restaurer : fermer le jeu, préserver la sauvegarde actuelle, copier la backup vers le nom sans `.backup`. Le chargement coop est refusé dans le bouton solo ; import coop non implémenté.

## Développement et contrôles

Godot 4.6.3 et Python 3. Installer outils Linux vérifiés via `python3 tools/bootstrap_godot.py --prefix /tmp/archelys-godot --templates` ; téléchargement templates volumineux (~1,2 Go). Ajouter le sous-dossier bin au PATH et définir XDG_DATA_HOME sur le sous-dossier data. Blender n’est nécessaire que pour régénérer le mannequin.

Depuis le dépôt : `python3 tools/check_prototype.py`. Cela importe le projet, exécute les tests, l’import animé, la scène fonctionnelle et trois processus ENet. Les logs avec erreurs ou marqueurs manquants font échouer le contrôle, même si Godot rend un code 0.

Export : `godot --headless --path game --export-release Windows "$PWD/builds/Archelys-Laboratoire.exe"`, puis `python3 tools/package_windows.py --commit <sha>`. Les builds et caches restent hors Git ; le workflow publie une prerelease après contrôles réussis.

## Ce que le test owner doit vérifier

Lancement Windows, fluidité et commandes ; lisibilité de l’interface ; personnages des trois fenêtres synchronisés ; porte bloquée tant qu’un participant manque ; écriture/relecture de save. Le rendu final et une première île ne sont pas à valider à partir de ce graybox.
