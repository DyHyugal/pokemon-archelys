# Vérification D77 — 34 exports intégrés

Source : `5887ff80b1ac5d90735b10fc95457f5342eaf6a9`, branche `docs/cadrage-valide`.

[CI complète réussie](https://github.com/DyHyugal/pokemon-archelys/actions/runs/38444514302) : import des assets, tests, export Windows, packaging et publication. La suite locale passe ; les quatre parcours de démo concernés par l'ajustement final des collisions intérieures passent également. Nouveau contrôle : 120 assertions headless, 128 avec captures FHD ; les 120 assertions passent aussi contre le PCK exporté.

[Télécharger le ZIP](https://github.com/DyHyugal/pokemon-archelys/releases/download/lab-5887ff8/Archelys-Laboratoire-Windows.zip) : HTTP 200, **444,998,454 octets**, téléchargement complet et empreinte recalculée conformes au SHA256 publié :

`f87e814b4d94f91bb922cd1c607c5c5a90bbac232dba1162ad6b929e066ffd54`

Les 34 GLB sources copiés ont les mêmes empreintes que les exports reçus ; pivots/échelles/orientations et matériaux adaptés à l'exécution, sans modifier les originaux. EXE officiel Godot inchangé, nom fixe, Showdown/Node offline conservés. Neuf captures réelles et provenance dans le ZIP. Playtest Windows/visuel owner et mesure sur GPU réel non réalisés ici.

[Lot et limites](LOT_TRIPO_SCENERY.md) ; [vue du havre à distance joueur](tripo-batch/town-player.png). PNJ, terrains et une partie des éléments restent provisoires. Le guide en tête du LIRE-MOI permet un seul retour de visite groupé.
