# D82 — vérification de l’Atelier Godot 0.1

14 octobre 2026. Outil développeur demandé ; pas de nouvelle validation artistique ni d'île complète.

## Exécuté localement

- Suite existante `tools/check_prototype.py` terminée avec `ALL PROTOTYPE CHECKS PASSED`, nouveaux contrôles Atelier inclus. Après ajout de l’identification du dump et des vérifications 3D/clavier, contrôles ciblés réexécutés : **33 contrats**, **19 contrôles de prévisualisation**, zéro échec.
- Contrats : tables et sous-fichiers GARC, extraction exacte, source intacte, refus de chevauchements/hors limites/versions inconnues, identification NCCH d’une fixture Ultra-Lune, formats bruts explicitement non convertis ; événements conditionnels/manuels, attente de victoire, rollback, répétabilité, restauration atomique ; instanciation réelle d’un GLB original avec collision.
- Prévisualisation : véritable entrée clavier, NPC et dialogue manuel, récompense/visibilité, langue et état sauvegardés/rechargés, mauvais fichier refusé, combat **réel Showdown** via l’interface existante, victoire, passage entre deux scènes, état conservé et position d’arrivée. Les fixtures Pokémon ne sont pas un roster final.
- Éditeur Godot headless : **10 contrôles**, zéro échec, sur le plugin chargé dans le vrai éditeur : placement depuis palette, propriétaire de scène, undo/redo, ajout/undo/redo d’un dialogue et sauvegarde/réouverture de la ressource. Pas seulement un test du modèle de données.
- Pont Blender 4.3.2 : lancement réel, export d’un triangle synthétique en GLB inspecté, manifeste, refus d’écrasement, refus d’import sans géométrie. L’importateur de ce contrôle est une fixture : **cela ne valide pas n3ds_importer sur une ressource USUL réelle**.

- Éditeur graphique X11/llvmpipe : **11 contrôles**, zéro échec ; panneau révélé via l’API `EditorDock` de Godot 4.6. [Capture réelle](workshop/editor.png). Le pilote logiciel émet un diagnostic d’initialisation Vulkan non disponible ; le rendu OpenGL et les contrôles de l’éditeur ont abouti. Ce n’est pas une mesure de performances utilisateur.

## Restant à confirmer

Aucun dump USUL n’est disponible ici. La conversion GFModel/BCH réelle, l’association modèles/textures/animations, la fidélité des matériaux et la reconstruction des maps officielles ne sont pas validées. Pas de nouveau chiffre de configuration minimale ni de fluidité Windows. Le guide décrit les fonctions encore absentes du panneau (personnalisation, cinématiques complètes, services/rencontres par formulaires).

Le plugin est lié aux services Archélys ; il s’utilise avec le projet fourni, pas comme un addon universel à copier dans n’importe quel jeu. Les sources/ROMs et imports locaux officiels sont exclus de l’archive de distribution Atelier.

## Livraison

Archive `Archelys-Atelier-Godot.zip` produite par `tools/package_workshop.py` : projet Godot, guide, outils et moteur de combat hors ligne Windows. Le packager contrôle le CRC et chaque fichier du manifeste SHA256 après écriture. Le `project.godot` de l’archive démarre l’exemple ; celui du dépôt conserve le laboratoire. Livraison source `14ab081f06b3ca40383d6ea778fe9a3ca542e1f6` ; [CI 38565618403](https://github.com/DyHyugal/pokemon-archelys/actions/runs/38565618403) terminée avec succès (validation et publication).

[Télécharger l’Atelier Godot](https://github.com/DyHyugal/pokemon-archelys/releases/download/lab-14ab081/Archelys-Atelier-Godot.zip). Archive publiée effectivement retéléchargée : **261384196 octets**, **1322 fichiers** du manifeste, CRC et chaque SHA256 interne vérifiés. SHA256 de l’archive : `4bffd0da475b7bce0be41e42595dcd2bb42397b0ebd046f0ad8118b12c5c9994`. L’archive conserve le bilan au moment de sa construction ; ce document enregistre ensuite la vérification de publication.
