# Atelier Archélys — Godot 0.1

Outil développeur dédié au projet, demandé par le propriétaire après l'audit USUL. Cible : fabriquer Archélys selon le cahier existant, avec sources 7G/USUL en priorité. Ce lot ne remplace ni le scénario, ni la direction artistique, ni les règles Showdown 9G par celles d'une ROM. Les concessions de l'audit restent des hypothèses, pas des décisions de produit.

## Ouvrir l'atelier

Installer **Godot standard 4.6.3** depuis https://godotengine.org/download/archive/4.6.3-stable/ ; la version .NET n'est pas nécessaire. Décompresser toute l'archive `Archelys-Atelier-Godot.zip`, puis importer `Archelys-Atelier/game/project.godot` dans le gestionnaire de projets Godot. Conserver `builds/` et `tools/` à côté de `game/` : ils contiennent le moteur de combat hors ligne et le pont optionnel Blender.

Le panneau **Archélys** est activé par défaut. Le menu Projet → Outils → Ouvrir l'atelier Archélys permet de retrouver son onglet. S'il a été désactivé, le réactiver dans Projet → Paramètres du projet → Extensions. Dans le panneau, Maps → Ouvrir la map d'exemple. **F6** lance uniquement la map ouverte. L'archive Atelier démarre aussi cet exemple avec F5 ; le dépôt conserve le démarrage habituel du laboratoire. Ce n'est pas un nouvel exécutable Windows à lancer : l'application d'édition est Godot.

Le catalogue Pokémon du laboratoire reste provisoire : cette version n'ajoute pas automatiquement les 807 espèces d'USUL ni le futur roster d'Archélys. Les équipes d'essai doivent employer des espèces reconnues par ce catalogue.

Le combat d'essai fonctionne hors ligne avec Node Windows et Showdown fournis dans `builds/`. Sur Linux, préparer Showdown avec `python3 tools/prepare_showdown.py` et définir `ARCHELYS_NODE_BIN` vers le binaire Node compatible. Blender et un importateur 3DS ne sont nécessaires que pour la conversion optionnelle ; la composition et les événements fonctionnent sans eux.

## Fabriquer une map

Créer une map 2D ou 3D depuis Maps et choisir un nouveau fichier `.tscn` dans le projet. Son identifiant est enregistré dans `data/workshop/maps.json`. Ne pas réutiliser le même nom de fichier pour deux destinations différentes. Une map 3D neuve contient un sol de travail et une lumière ; ces éléments se modifient dans la scène native.

La bibliothèque propose quatre éléments dessinés originaux du prototype. Sélectionner un élément, puis Placer : il apparaît au point de départ de la map. Le déplacer dans la vue native Godot, utiliser l'aimantation, modifier ses propriétés dans l'inspecteur. Ctrl+Z/Ctrl+Maj+Z utilisent l'historique natif. Les objets 2D sont triés par leurs pieds ; le point cyan représente le pivot. Le rectangle orange montre l'empreinte bloquante dans l'éditeur.

`height_pixels` définit la hauteur visuelle d'un sprite ; `blocking_size` définit séparément son empreinte de collision. Pour un modèle 3D, régler `model_scale`, `model_offset` et la boîte `blocking_size`. La boîte est une première collision éditable, pas une collision détaillée de grotte. Les collisions ne se déduisent pas automatiquement de l'image d'une façade. Les modèles 3D se placent en 3D ; le panneau refuse de traiter un PNG comme un modèle 3D ou de convertir silencieusement un GLB en sprite.

Pour enregistrer un nouvel asset, l'importer d'abord dans les fichiers Godot, renseigner sa provenance et ses droits, puis Ajouter un PNG/GLB du projet. La bibliothèque garde chemin et SHA256. Pas de remplacement silencieux d'un identifiant existant. Les sources USUL locales peuvent être placées dans `game/assets/local_usul/`, exclu de Git et de notre packager. Cela ne dispense pas d'examiner les ressources d'un export public ; le packager de jeu historique ne constitue pas un filtre de droits.

## Écrire une interaction

Sélectionner un objet Atelier dans la scène, puis ouvrir Événements. Créer son événement, choisir une action, remplir la référence ou les textes FR/EN et Ajouter l'étape. La liste donne l'ordre d'exécution. Le bouton d'inspection permet de modifier/réordonner les étapes et leurs paramètres : quantité, valeur vraie/fausse, destination, etc. Les ajouts/suppressions sont annulables. Sauver la scène Godot conserve les ressources d'événement.

| Action | Paramètres et comportement |
|---|---|
| dialogue | Texte FR obligatoire ; EN facultatif avec repli FR. Avance manuelle. |
| set_flag | Référence d'état et valeur vraie/fausse. |
| require_flag | Interrompt si la valeur ne correspond pas. |
| give_item | Référence et quantité ; inventaire propre à l'essai Atelier. |
| battle | Référence d'équipe dans `data/workshop/battles.json` ; véritable Showdown et interface existante. |
| warp | Identifiant de `maps.json` ; `destination` donne x/z en 2D et x/y/z en 3D. |

`required_flag`, `forbidden_flag` et `once_flag` contrôlent l'accès à l'interaction et sa répétabilité. Les objets ont aussi `visible_if` et `hidden_if`. Les changements de flags/inventaire d'une interaction sont transactionnels : échec, condition bloquante ou combat perdu/annulé restaure leurs valeurs d'avant l'interaction. Les effets propres au combat restent gérés par le service de combat. Un changement de map conserve l'événement actif et la session Atelier. Les événements de cette version démarrent à l'interaction, pas automatiquement sur franchissement d'une zone.

Le bouton Vérifier détecte notamment les identifiants d'objets/événements dupliqués, les étapes invalides et les références d'action vides. Ce n'est pas une preuve d'accessibilité de toute la campagne. Le runtime refuse une équipe ou une map absente sans avancer le scénario.

L'exemple donne un jeton avec le guide, fait apparaître un passage vers une seconde map et propose un combat séparé. Équipe de laboratoire, PNJ, graphismes et noms sont provisoires. Ce n'est pas une proposition de nouvel épisode narratif d'Archélys. L'avatar d'essai reste une pose fixe ; cet outil ne prétend pas terminer les animations/personnalisations du jeu.

## Essayer sans toucher à la campagne

ZQSD/WASD ou flèches pour marcher, Maj pour courir, E/Entrée pour interagir. Les boutons permettent sauvegarde, chargement et FR/EN. L'état, les objets, les Pokémon d'essai, la position et la langue sont sauvegardés séparément dans `user://workshop-<empreinte-map>.json`. Sauver est refusé pendant un événement/combat. Aucun import ou écrasement des sauvegardes historiques n'est effectué. La version 0.1 n'est pas un format de sauvegarde final de campagne.

## Sources USUL et conversion

L'onglet Source USUL peut ouvrir un dossier de dump contenant `romfs/` et repérer ses archives connues (Pokémon, champs, textes FR, dresseurs). Si un en-tête NCCH est disponible, son code produit identifie Ultra-Soleil ou Ultra-Lune ; la révision n'est pas devinée. Cette inspection n'importe pas encore la géométrie des maps. Il peut aussi ouvrir directement une **archive GARC v6 little-endian** extraite localement. Il contrôle les tables FATO/FATB/FIMB et les bornes, affiche les membres et sous-fichiers, extrait le membre choisi sans modifier l'archive et produit un manifeste avec identifiants et SHA256. Un fichier déjà extrait est préservé. Les membres compressés restent compressés ; BCH, GFModel et AMX ne deviennent pas des ressources Godot à cette étape. Pas de déchiffrement de `.3ds`/`.cia`, pas d'exécution de scripts AMX, pas d'import automatique de toutes les maps d'Alola.

L'onglet Conversion lance Blender en arrière-plan avec `tools/convert_usul_asset.py`. Installer séparément une copie de confiance de https://github.com/sxrmss/n3ds_importer (GPL-3.0-or-later), décompresser son add-on, indiquer son dossier contenant `__init__.py` ainsi que l'exécutable Blender 4.2+. Choisir ensemble les ressources d'**un seul modèle**, avec ses textures/animations, dans le même dossier. Le lecteur tiers peut parcourir certains conteneurs et compressions ; consulter sa matrice réelle de formats. Ne pas sélectionner tout le Pokédex dans une seule conversion : certaines animations sont associées au modèle principal.

L'outil refuse les destinations existantes, exige une géométrie et écrit un GLB ainsi qu'un rapport dans le dossier utilisateur. Arrêter ne supprime pas les sources. Un `.partial.glb` interrompu reste à examiner. L'éditeur reste utilisable pendant la conversion. Importer ensuite le GLB dans les fichiers Godot et dans la bibliothèque. Les réglages Blender sont locaux à l'éditeur, pas partagés dans le projet.

Le pont est écrit pour l'opérateur `import_scene.n3ds_model`, examiné au commit tiers `a68959eae2f476526845a78af6990648cfe3434d`. Il ne reproduit pas les shaders PICA200. Le code du lecteur tiers n'est pas incorporé au plugin. Son fonctionnement avec un corpus USUL réel reste à vérifier : **aucun dump USUL n'a été fourni dans cet environnement**. La présence d'un rapport « converted-needs-visual-review » indique seulement un export obtenu, jamais une fidélité graphique certifiée.

## Architecture et suite nécessaire

Le plugin est un outil au-dessus de Godot, pas un moteur supplémentaire. `core/` contient lecteurs, données et validation ; `nodes/` les objets/maps éditables ; `runtime/` l'essai jouable ; les services existants restent responsables de Showdown. Les scènes `.tscn` et ressources d'événement sont la source d'édition. Les visuels et collisions générés au chargement ne sont pas dupliqués dans les fichiers de scène.

Prochains travaux pour la chaîne USUL complète : identifier les ressources associées à chaque modèle, importer placements/géométrie/collisions avec une conversion d'axes et d'unités documentée, reconstruire les matériaux compatibles, puis traduire les interactions comprises vers notre système narratif. Les comportements natifs inconnus doivent rester signalés, jamais remplacés par une réussite factice. Un corpus local représentatif est nécessaire pour valider cette chaîne ; les fixtures synthétiques ne la prouvent pas.

Personnalisation modulaire, éditeur de déplacements/caméras de cinématique, rencontres/boutiques/équipes par formulaires, raccordements visuels de zones et intégration des ressources officielles sont encore à développer. Les capacités existantes du jeu ne sont pas toutes exposées dans ce panneau 0.1. Ce lot n'autorise ni un retour graphique 3D définitif ni une réduction aux règles 7G.

## Vérifications reproductibles

`python3 tools/check_prototype.py` inclut les contrats GARC/événements, l'utilisation du plugin dans le vrai éditeur (placement, undo/redo, sauvegarde des ressources) et l'essai de scène avec combat réel, flags, inventaire, langue et transition. `python3 tools/check_usul_bridge.py --blender <exécutable>` vérifie séparément le pont Blender avec un importateur synthétique : il ne valide pas l'importateur tiers sur USUL. Les résultats réellement exécutés sont consignés dans `VERIFICATION_D82.md`.
