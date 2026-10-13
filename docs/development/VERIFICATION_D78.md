# Vérification D78 — prototype fangame 2D HD

Source : `84cb3ff5479a2ff3896d1ac0d055fe2201ba16ca`, branche `docs/cadrage-valide`.

[CI complète réussie](https://github.com/DyHyugal/pokemon-archelys/actions/runs/38463267384) : imports, tests hérités et test 2D, export Windows, packaging et publication. Suite locale complète réussie ; nouveau parcours 2D : 28 contrôles headless et 34 avec captures. Les 28 contrôles passent aussi contre le PCK exporté avec le runtime Showdown externe placé à l'emplacement attendu. Le premier essai PCK avait utilisé un dossier sans ce runtime, expliquant les refus de lancement ; aucune assertion supprimée pour le second essai.

[Télécharger le ZIP](https://github.com/DyHyugal/pokemon-archelys/releases/download/lab-84cb3ff/Archelys-Laboratoire-Windows.zip) : HTTP 200, **456,525,402 octets**, téléchargement complet et SHA256 recalculé conforme au fichier publié :

`abac9395989320cc69395a2f6e7a70557ead61d6b149195770175f08151941af`

Même EXE officiel Godot non modifié, nom fixe. Six captures en FHD et guide groupé inclus. Les nouveaux PNG utilisent les modèles fournis et deux textures de sol générées, sans crédit Tripo supplémentaire. Le monde principal du prototype est affiché avec des sprites/polygones 2D, sans décor 3D vivant ; l'atelier et les anciens assets restent présents pour régression/historique.

[Capture réelle de la rue](hd2d/01-rue.png), [intérieur](hd2d/02-maison.png), [lot/limites](LOT_HD2D.md). Rendu précalculé encore différent d'une illustration entièrement dessinée ; profils PNJ, personnalisation et habillage des combats à réaliser. Aucun playtest Windows owner ni acceptation artistique déduits.
