# Préparation du premier lot Meshy

Le propriétaire a choisi un essai Meshy Pro d’un mois (D70). Aucun compte, export ou modèle Meshy n’est disponible dans ce dépôt à ce stade. Les quotas et fonctions payantes doivent être vérifiés dans l’interface du compte ; aucun tarif supposé ici.

## Commencer par une seule boutique

Utiliser l’image crème/toit turquoise/auvent approuvée comme référence pour **Image vers 3D**, puis télécharger le modèle. Le PNG seul ou une capture du viewer ne contient pas de géométrie. Privilégier GLB/glTF avec textures ; FBX accompagné de ses textures reste utilisable via Blender. Conserver le fichier original et les réglages/export du projet.

Avant de produire toute une ville : examiner face, côtés, arrière, toit et dessous. Vérifier que l’arrière n’est pas une copie incohérente de la façade, que portes et fenêtres restent nettes, que le modèle ne fusionne pas avec un socle/environnement, et que textures et transparences fonctionnent une fois exportées. Un aperçu du site ne prouve pas la qualité dans Godot.

## Intégration prévue

1. Import dans Blender, examen des dimensions, matériaux, triangles et composantes.
2. Mise à l’échelle et orientation cohérentes avec le quartier ; conserver les sources originales.
3. Import Godot et essai à la caméra réelle, puis éclairage et raccord au sol.
4. Positionner explicitement porte et collision de gameplay ; ne pas dériver les interactions du nom des meshes générés.
5. Vérifier le rendu et les performances avec plusieurs instances avant de multiplier les exports.

Les collisions, noms d’interactions, carte et objectifs appartiennent au gameplay. Le remplacement de la façade ne doit pas déplacer implicitement un service ni casser une sauvegarde. Un changement du gabarit peut nécessiter un ajustement explicite du placement/collision.

## Suite seulement après ce premier essai

Boutique → maison commune → Centre → végétation et accessoires → kit modulaire de la ville. Les concepts de région servent de référence commune ; générer une ville entière en un bloc risque de rendre les rues, intérieurs et variantes inutilisables.

Personnages dans un essai séparé : protagonistes masculin/féminin et trois rivaux sont envisagés par le propriétaire. Valider un premier humanoïde au repos ET animé avant cinq générations. Vérifier visage, mains, squelette, déformations et cheveux/vêtements. La personnalisation nécessite des composants ou variantes compatibles ; elle n’est pas obtenue automatiquement avec cinq modèles complets.

Enregistrer pour chaque asset : outil/version disponibles, référence et prompt, date, propriétaire du fichier, conditions d’utilisation applicables, retouches, empreinte source et export. Les droits de l’outil ne remplacent pas ceux des designs préexistants. Le rendu cible DS/USUL en FHD reste le critère, pas la seule réussite de l’import.
