# D74 — boutique et héros Tripo intégrés

Demande du propriétaire du 13 octobre 2026 : intégrer D001 et P001 dans la démo, avec retouches nécessaires, puis livrer une version Windows testable. Option A retenue en conversation : exploration 3D chibi et combats Pokémon en illustrations 2D. La conversion de la présentation des combats n’est pas réalisée par ce lot ; ses règles Showdown restent inchangées.

## Modèles effectivement utilisés

Les premiers GLB contenaient 1 770 822 triangles (boutique) et 1 918 750 (avatar), sans squelette. Ils ont été conservés hors dépôt et simplifiés provisoirement à 45 000 / 22 000 triangles pour examen. Le propriétaire a ensuite fourni une meilleure base : retopologie Tripo de la boutique (20 243 triangles, 4 060 764 octets) et chibi avec retopologie/rig (19 149 triangles, 3 846 940 octets, 65 articulations, clips `walk` et `run`). Ce sont ces derniers fichiers, inchangés dans leur géométrie, qui sont intégrés. Aucune nouvelle génération payante par Codex.

Textures intégrées conservées ; provenance, SHA256 et historique dans `game/assets/tripo/provenance.json`. Origine : exports Tripo fournis par le propriétaire pour son projet ; conditions du service non vérifiées indépendamment. Aucune licence de designs tiers présumée.

## Intégration

La boutique remplace seulement `shop` dans le havre, via le registre existant. Échelle, rugosité/reflets et intensité de normale ajustés ; collision au sol et point d’entrée déplacés selon son encombrement. Le vantail est inclus dans le mesh, pas une porte articulée. L’intérieur existant et son marchand restent opérationnels.

Le héros et sa prévisualisation utilisent le même chibi. Marche normale 1,7 unité/s, course Maj 3,8 ; boucle et vitesse des clips calibrées selon le déplacement de leur racine. Les translations horizontales du bassin sont neutralisées sur des copies propres à chaque instance : pas de dérive hors du joueur. L’arrêt est une pose fixe issue du début de `walk` : pas de clip de repos animé fourni. La personnalisation de palette est expérimentale, par masque procédural ; ce n’est pas une tenue modulaire finie. Coiffure et visage fixes, contrôles correspondants désactivés, valeurs historiques conservées dans les sauvegardes.

Les autres bâtiments/PNJ restent des maquettes : aucun remplacement massif, aucun choix final de roster ni de lore. Le nouveau héros n’est pas une validation artistique automatique. Aucun changement de schéma ou remise à zéro des sauvegardes.

## Vérification et limites

Contrôles réels : import des GLB, budget géométrique, shaders indépendants entre aperçu/joueur, clips joués et racine stable sur leur boucle, entrée/sortie boutique, obstacles, sauvegarde/reprise et atelier inchangé. Contrôles de cette version : 23 conditions pilotes en headless (avant captures), puis six captures FHD et contrôles associés. Régressions du socle via `tools/check_prototype.py`, incluant `tests/tripo_pilots.gd`. Captures réalisées dans Godot à 1920×1080 avec llvmpipe logiciel ; elles ne prouvent pas une configuration minimale ni les performances Windows.

Validation visuelle et exécution Windows à effectuer par le propriétaire avec le parcours du LIRE-MOI. Vérifier notamment le rendu de face/profil/dos, les mouvements du chibi, la taille relative à la boutique et la fluidité. Pas de test multi requis.
