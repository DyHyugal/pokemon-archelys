# Tester le laboratoire

Le laboratoire est un outil de faisabilité : graphismes, avatar et combat sont provisoires. Aucun Pokémon final ni histoire jouable n’est intégré.

## Windows

Le ZIP de prerelease, quand publié par le workflow, contient l’exécutable, un LIRE-MOI et un manifeste. Décompresser entièrement puis lancer l’exe. Aucune installation Godot pour jouer à cet export. Le premier build lab-09897ca a été testé avec succès sous Windows par le propriétaire. Les changements ultérieurs doivent être vérifiés à leur tour.

ZQSD/WASD/flèches : déplacer le personnage. Maisons/arbres bloquent les passages. Porte turquoise : une étape factice, attend le nombre de participants. Boutons : sauvegarde, chargement solo, simulation d’un tour et retour au début du combat factice.

Multijoueur reporté : aucun essai owner attendu actuellement. Les commandes sont masquées par défaut derrière une case optionnelle. Ancien essai coop : trois fenêtres sur le même PC. Première = Héberger ; autres = Rejoindre à 127.0.0.1. Ce serveur écoute seulement localhost ; ce ZIP n’est pas encore une invitation Internet ou un essai entre deux PC. Maximum trois participants.

La simulation de combat du panneau reste locale et séparée du réseau : elle ne prétend pas démontrer un combat coop synchronisé. Les entrées clavier ne doivent pas déplacer le joueur quand il écrit l’adresse.

## Sauvegardes de prototype

Sous Windows, dossier habituel : `%APPDATA%\Godot\app_userdata\Archélys — laboratoire technique\`. `laboratory_campaign.json` et copie précédente `.backup`. Pour restaurer : fermer le jeu, préserver la sauvegarde actuelle, copier la backup vers le nom sans `.backup`. Le chargement coop est refusé dans le bouton solo ; import coop non implémenté.

## Développement et contrôles

Godot 4.6.3 et Python 3. Installer outils Linux vérifiés via `python3 tools/bootstrap_godot.py --prefix /tmp/archelys-godot --templates` ; téléchargement templates volumineux (~1,2 Go). Ajouter le sous-dossier bin au PATH et définir XDG_DATA_HOME sur le sous-dossier data. Blender n’est nécessaire que pour régénérer le mannequin.

Depuis le dépôt : `python3 tools/check_prototype.py`. Cela importe le projet, exécute les 19 contrôles du socle, 6 contrôles de dialogue, l’import animé et la scène fonctionnelle solo. Le test scène vérifie aussi proximité PNJ, avance manuelle, déplacement suspendu et suivi caméra. `--network` active en supplément l’ancienne régression ENet ; elle n’est pas requise pour poursuivre le solo. Les logs avec erreurs ou marqueurs manquants font échouer le contrôle, même si Godot rend un code 0.

Export : `godot --headless --path game --export-release Windows "$PWD/builds/Archelys-Laboratoire.exe"`, puis `python3 tools/package_windows.py --commit <sha>`. Les builds et caches restent hors Git ; le workflow publie une prerelease après contrôles réussis.

## Ce que le test owner doit vérifier

Retour acquis sur le premier build : lancement, déplacement, fluidité, sauvegarde et combat factice OK. Pour la suite : vérifier le confort de la caméra rapprochée et du curseur de distance ; aller près du guide (à droite du départ), appuyer sur E ou Entrée, vérifier que le mouvement s’arrête et que chaque phrase attend une nouvelle pression. FR/EN choisit la langue du prochain dialogue. Le combat affiché est désormais un duel solo. Le rendu final et une première île ne sont pas à valider à partir de ce graybox.

## Tests inclus dans le ZIP et nom fixe

Chaque ZIP contient désormais un LIRE-MOI avec version, commit, empreinte de l’exécutable, changements, tests à effectuer et modèle de retour. Sa source est [LIRE_MOI_WINDOWS.txt](LIRE_MOI_WINDOWS.txt) ; le packaging injecte les informations du build. Son changement déclenche la CI et une nouvelle release. Le nom `Archelys-Laboratoire.exe` reste identique, seul le tag de release change.

L’exécutable est toujours non signé : aucun certificat/service de signature de code n’est disponible. Le LIRE-MOI distingue SmartScreen, qui peut proposer « Informations complémentaires → Exécuter quand même », des protections qui ne proposent pas cette option. Aucune désactivation globale de la sécurité n’est demandée.

Livraison `lab-2d171c7` : ZIP publié téléchargé, empreintes ZIP/EXE et intégrité vérifiées ; LIRE-MOI versionné et nom fixe confirmés. Le répertoire de certificats Authenticode de l’exécutable est vide, conformément au statut non signé. Le build précédent a été signalé bloqué par Windows : aucune nouvelle exécution Windows validée ici.
