# Première île — références individuelles pour image vers 3D

[Télécharger les 35 PNG, prompts et guide](https://raw.githubusercontent.com/DyHyugal/pokemon-archelys/refs/heads/docs/cadrage-valide/docs/design/Assets-isoles-premiere-ile-Archelys.zip)

[Consulter le catalogue Excel des 35 références](https://raw.githubusercontent.com/DyHyugal/pokemon-archelys/refs/heads/docs/cadrage-valide/docs/design/Catalogue-assets-isoles-premiere-ile.xlsx)

Le propriétaire demande de refaire les canvas pour **un asset par image**. Ce lot fournit 35 références individuelles : bâtiments maîtres, arcade, mobilier, quai/bateau, camp/relais, végétation, rochers/falaise/entrée de grotte, sanctuaire, structures RR et équipements intérieurs. Les PNG originaux sont conservés sans modification après génération ; trois premiers essais ont été remplacés par des générations/édition avec image_gen.

Ce sont des modèles maîtres **proposés sous forme d’images**, pas 35 modèles 3D produits, ni chaque élément de l’inventaire de 181 fiches. Les avatars ne sont pas redessinés ; le candidat apprécié attend son export/rig. Espèces, starters et divinité restent au propriétaire. Pas de nouveau gameplay ni de changement des sauvegardes.

## Utilisation

Décompresser le ZIP et ouvrir `Catalogue-assets-isoles.xlsx`. Chaque ligne indique l’ID du premier catalogue, la zone, le PNG, les déclinaisons, un prompt complémentaire de reconstruction et les contrôles utiles. Les liens locaux des images fonctionnent avec le dossier `images` à côté du classeur extrait. L’Excel téléchargé seul ne contient pas les PNG.

Dans Meshy/Tripo, utiliser **Image vers 3D** avec **le PNG individuel**. Ajouter le prompt de la ligne si le mode de l’outil le permet ; ne pas supposer que toutes les interfaces acceptent image et texte. Les planches de zones restent des références d’ambiance, pas l’entrée de cette reconstruction.

Commencer par D001 boutique, D003 maison ou D029 banc avant les modèles complexes. Exporter un GLB avec textures intégrées, puis inspecter dos/côtés, topologie, UV, ombres peintes, ouvertures, pièces mobiles et rendu à la caméra du jeu. Les caractéristiques demandées dans un prompt ne sont pas garanties par une génération.

## Correspondance

| Famille | IDs des PNG |
|---|---|
| Bâtiments du port | D001 boutique, D003 maison, D004 Centre, D005 laboratoire, D006 travée d’arcade |
| Village volcanique | D010 maison de basalte/bois, D011 pavillon |
| Mobilier et quai | D029 banc, D030 lampadaire, D032 panneau, D035 caisse, D038 section de quai, D040 bateau |
| Camp et interactions | D044 tente, D045 relais, D047 barrière, D052 console |
| Végétation | D053 palmier, D054 arbre, D056 arbuste, D057 fougère, D059 herbes |
| Relief et grotte | D067 basalte, D071 falaise, D073 entrée |
| Sanctuaire et RR | D083 portique, D084 plateforme/autel, D087 poste, D088 raffinerie |
| Intérieurs | D095 comptoir de soins, D096 station de soins, D097 PC, D098 comptoir boutique, D102 plateau des starters, D107 lit |

Les raccords d’arcade, quai et falaise demandent une préparation explicite. D084 est une plateforme cérémonielle, plus grande qu’un autel bas : elle peut servir de base pour D085 après adaptation. Certains bâtiments comportent des ornements facultatifs ; par exemple, clocheton et jardinières de la boutique peuvent être omis/séparés pour un premier pilote plus simple. Les références donnent une silhouette à éprouver, sans décider implicitement de tous les détails architecturaux.

## Livrables et vérification

Le ZIP contient 35 PNG, un Excel, un guide et un manifeste : 38 fichiers. Taille : 56 987 784 octets. Les copies de PNG restent dans `/workspace/artifacts/archelys-assets-isoles/images` ; seuls l’archive et les documents sont enregistrés dans le dépôt pour éviter de dupliquer 35 grandes images en plus du ZIP.

Le [manifeste](Assets-isoles-premiere-ile-Archelys.json) conserve les prompts image exacts, les références utilisées, les sources originales, dimensions et SHA256. Total : 38 générations/éditions, 35 références retenues ; trois essais de D095/D096/D098 remplacés et conservés hors pack. Outil : image_gen.imagegen. Illustrations générées pour la demande, aucune extraction de modèles officiels, pas de licence de designs Pokémon implicitement accordée.

Vérifications effectuées : PNG décodables, 35 IDs uniques, correspondance image/prompt/Excel, empreintes des fichiers extraits et intégrité ZIP. Aucune validation de reconstruction Meshy/Tripo ou de rendu Godot déduite de ces contrôles. Les planches précédentes sont préservées.
