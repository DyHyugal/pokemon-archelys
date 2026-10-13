# D81 — démo de calibration 2D dessinée

14 octobre 2026. Le propriétaire demande de mettre en pratique les conventions étudiées pour corriger échelle, déplacement et animation du décor, puis autorise « fais la demo ». Histoire et direction B restent les exigences immuables de D80. Petite portion de référence, pas production de toutes les îles.

## Ce qui change

Le havre est assemblé avec un kit séparé : texture de pelouse, pavage, surface d'eau, trois bâtiments et arbres. Le héros utilise douze poses réellement dessinées : repos et deux pas pour quatre orientations, dont un véritable dos. Boucle pas/repos/autre pas/repos ; course emploie les mêmes poses avec cadence liée à la distance parcourue. Pas d'animation de course séparée prétendue.

Les coordonnées de monde ont une projection carrée de 64 pixels par unité sur les deux axes, au lieu de 64×48. Avatar normalisé à 80 pixels, pivot aux pieds. Ces nombres sont une proposition de calibration, pas une valeur officielle imposée ou un asset extrait d'une ROM. À zoom identique et même fenêtre, taille du héros identique dans chaque lieu : la caméra ne recadre plus chaque carte avec un facteur différent. Les positions/périmètres des anciens fonds intérieurs/sentier sont convertis pour préserver leur alignement avec les dessins, sans étirer ces images.

Marche 2,8 unités/s, course 5,4 ; diagonale limitée à la même vitesse. Le ×4 affecte le déplacement réel comme la cadence des poses. La caméra conserve le réglage utilisateur. L'animation marche exige un déplacement réel ; arrêt ou menu/dialogue = repos. Les collisions utilisent toujours de petits sous-pas contre la traversée des obstacles.

Personnages, bâtiments et arbres ont un tri natif par leur pied. Tronc bloquant, passage autour et derrière la couronne accessible ; légère transparence de couronne quand le héros est derrière. PNJ placés pour ne plus se trouver masqués par une façade/arbre à leur position normale. Les modèles de PNJ restent des variantes de veste du héros, pas leurs designs finaux.

## Animations de décor

La mer utilise sa texture indépendante avec déformation/courant et variations de lumière. La berge est un autre élément fixe. Les arbres ont un déplacement progressif depuis le pied immobile vers le haut, de faible amplitude et déphasé entre arbres. Ce n'est pas une animation individuelle de chaque feuille, ni l'animation d'une forêt peinte dans un fond complet.

Menu Accueil → Calibration graphique : eau/lave, grille, figer/animer. La lave est un aperçu explicitement hors scénario et ne modifie ni flags, ni biome de la campagne. L'eau reste le mode par défaut. Les animations du décor utilisent une horloge réelle indépendante du ×4. Réduire les mouvements les fige, comme la commande locale de comparaison. Le héros conserve une cadence liée à son déplacement.

## Périmètre et conservation

Choix des starters provisoires, PNJ/dialogues, portes, Centre/PC, boutique/sac, sentier/balise/dresseur/rencontres, combat réel Showdown et progression D79 conservés. Aucune sélection finale d'espèces ou de starters. Nouvelle namespace de sauvegardes `archelys_calibration_demo.json`, trois slots ; D79 et atelier préservés. Aucune migration automatique. Aucun travail multi/raid/défi.

Le havre est modulaire. Les intérieurs et le sentier gardent leurs fonds D79, avec coordonnées recalibrées et nouveau personnage ; ils ne sont pas présentés comme intégralement découpés ou animés. Les placements restent décrits dans les données du prototype, pas un éditeur propriétaire fini. Ce lot n'est pas une reproduction exacte de l'illustration B ; il éprouve son assemblage en éléments réutilisables.

## Sources et assets

L'audit a étudié les sources publiques d'Essentials v21.1 : `Game_Map` (grille 32×32), `TilemapRenderer` (source/affichage), `Spriteset_Map` (couches), conventions de cartes/événements. [Audit et liens des sources](AUDIT_ESSENTIALS_GODOT.md). Aucun code Ruby ou moteur ROM importé dans Godot. Aucun dump de ROM effectué ; pas de propriété de licence supposée à partir d'un dépôt.

Trois PNG originaux générés via image_gen dans cette conversation, inspirés des références B et du héros D79 : feuille du héros, kit extérieur et surfaces. Fichiers conservés ; les bornes alpha sont mesurées pour sélectionner les régions et pivots. Le renderer Godot sélectionne les frames, normalise leur hauteur et extrait des régions de texture en mémoire pour éviter de répéter un atlas entier. Métadonnées/empreintes/provenance : `game/assets/drawn/calibration/frames.json` et `provenance.json`. Les poses peuvent encore présenter des différences de dessin entre frames ; inspection et retouches à prévoir après retour.

## Vérifications

`drawn_demo.gd` conserve le parcours réel : accessibilité des points, portes/retours, soins/PP, PC/boutique/sac/carte, sauvegardes, actions, frontières de portion, Showdown/attaque/fuite et atelier intact.

`calibration_scene.gd` vérifie les métriques de projection, hauteur/pivot et dessins distincts des quatre directions, cadence repos/marche à partir du mouvement, vitesse sur x/y/diagonale à 15/30/60 FPS pour marche/course et ×1/×4, densité identique entre lieux, contrôles de preview sans changement d'histoire, tronc et approches accessibles, tri/fade avant et derrière arbre. Sur rendu graphique, comparaison de véritables régions de pixels : eau, couronne et lave changent ; Réduire les mouvements fige eau/couronne. La région de couronne tient compte du facteur entre canvas logique et capture FHD.

Résultats et lien de livraison consignés dans VERIFICATION_D81 après exécution. Captures Linux/llvmpipe ; aucune performance Windows propriétaire ou acceptation artistique déduite. Parcours groupé dans le LIRE-MOI du ZIP. Retour graphique nécessaire avant extension du kit/production de toute l'île.
