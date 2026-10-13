# Prototype fangame 2D HD — D78

Le propriétaire abandonne le rendu 3D du monde, approuve la proposition de 2D dessinée HD et demande une démo avec les éléments disponibles. Clarification : fonctionnement de fangame comme Insurgence ou Empyrean, avec un gros effort de design. Cela ne demande pas de changement de moteur ni de reprise des règles/sauvegardes à zéro.

## Présentation développée

La démo Windows ouvre maintenant la présentation 2D. L'atelier propose « Démo 2D HD ». Sprites fixes précalculés à partir des exports Tripo, sol pavé/herbe illustrés en 2D, ombres 2D, caméra de suivi avec zoom, ordre d'affichage par profondeur pour passer derrière les éléments. Aucun bâtiment/personnage 3D vivant dans le monde principal de cette démo ; les coordonnées Vector3 existantes servent encore au calcul des déplacements et des interactions, sans déterminer un rendu 3D.

37 sprites de décors, 68 images du personnage : quatre directions, huit frames de marche, huit de course et un repos par direction. Sols : deux textures originales générées pour le prototype, adaptées à 512×512 et répétées en miroir. Aucun nouveau crédit Tripo utilisé. Sources, pivots des sprites et provenance conservés dans `game/assets/hd2d`. Génération hors ligne : `tools/bake_hd2d.gd`, depuis les modèles du propriétaire ; elle n'est pas requise pour lancer le jeu.

Havre, sentier, maison, boutique et Centre servent au parcours principal de cet essai. Les trois lieux de prolongement gardent une présentation 2D de continuité ; ce n'est pas la refonte définitive de huit maps. Les PNJ réutilisent le chibi avec des couleurs différentes : profils individuels encore à produire. Les bâtiments restent des rendus précalculés de modèles, **pas des assets entièrement dessinés à la main ni la reproduction exacte de la planche conceptuelle**. Le test vise à décider si ce réemploi fournit une base acceptable.

## Logique et sauvegardes

Collisions, portes, services, PNJ, choix du starter, sac, journal, commandes, réglages, progression et sauvegardes utilisent le socle existant. Les dispositions/collisions initiales sont exportées dans le manifeste 2D ; les obstacles retirés par progression disparaissent aussi de la logique et de l'affichage. Schéma campagne 5 et slots existants conservés ; aucune sélection nouvelle du Pokédex ou des starters.

Showdown reste le moteur réel des combats. Interface/messages/commandes conservés ; aucune arène 3D créée en mode 2D. L'habillage des combats et les sprites Pokémon définitifs restent à réaliser. L'apparence du héros est fixe dans cet essai ; réglages précédents conservés, sélecteurs temporairement désactivés dans ce mode. Le mode photo 2D demande une adaptation ; un message le précise. Le réglage de distance de caméra sert de zoom 2D.

Les composants 3D précédents restent dans l'atelier et le dépôt pour régression/historique ; leur présence ne signifie pas que la direction 3D du monde est maintenue. Le ZIP conserve donc les anciens assets et sa taille ne représente pas celle d'une future distribution 2D autonome. Une extraction du seul runtime 2D sera pertinente après validation du rendu et des services.

## Contrôles exécutés

`hd2d_scene.gd` : **28 contrôles headless et 34 avec captures**. Ouverture native 2D, absence de décors 3D en scène, images d'animations distinctes, déplacement visible, vraie porte vers l'intérieur et retour, sac, chargement sans perte, suppression d'obstacle avec progression, vrai combat Showdown/attaque/PP/fuite/retour à la vue 2D, campagne atelier intacte et fermeture du canvas. Le nouveau test est intégré à `tools/check_prototype.py` ; les tests hérités restent conservés.

Captures réelles en 1920×1080 dans [hd2d](hd2d), prises depuis le jeu avec l'interface : rue, maison, sac, sentier, Centre et combat. Vérifications Linux/llvmpipe, aucune validation artistique owner, aucun test de performances sur son GPU Windows déduit.

## Retour owner groupé

LIRE-MOI du ZIP : visiter rue et intérieurs, marcher/courir, passer derrière les éléments, parler aux PNJ, utiliser une porte/service, sac, save/load, zoom. Comparer proportions, netteté, cohérence des textures et lisibilité avec la planche de droite. Ne pas assimiler validation fonctionnelle et validation du rendu. Les composants fixes/précalculés pourront être remplacés par des sprites dessinés plus cohérents si ce test ne convient pas.
