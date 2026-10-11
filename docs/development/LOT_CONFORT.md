# Bloc10 — paramètres, commandes et lisibilité

D52 : le propriétaire valide lab-04a2317 et la Méga. Ce bloc implémente les réglages déjà demandés par K5/L3/Q16, sans répéter les tests owner des blocs7–9. Objectif : commandes cohérentes dans tout le solo, lisibilité et contrôle réel des bus audio ; format de campagne5 inchangé, aucune dépendance ou service payant.

## Commandes

`ComfortStore` conserve les touches physiques dans `user://comfort.json`. Les déplacements gardent initialement les alias ZQSD/WASD/flèches. Changer une action remplace ses alias par une touche unique, avec refus des conflits avec les autres réglages **et** leurs valeurs par défaut. Le menu capture une nouvelle pression, ignore les répétitions, permet d'annuler avec Échap ; reset limité aux touches.

Échap demeure un retour au menu quelle que soit la touche choisie. Entrée/Espace restent réservées à la confirmation et F3 au laboratoire ; la confirmation A historique reste disponible dans les textes, indépendamment des commandes d'exploration. La touche d'interaction choisie est utilisée dans le monde, les dialogues, le combat simple/double et la timeline. L'ancienne touche d'interaction ne passe plus les textes après changement. Mouvement bloqué par les modaux comme auparavant ; clavier seul, pas de reconfiguration manette/chords dans ce bloc.

## Audio et textes

Trois gains linéaires indépendants Général/Musique/Effets, zéro = mute ; remonter réactive le bus. Deux échantillons PCM originaux générés servent à vérifier les volumes ; prévisualisation et arrêt explicites, arrêt à la fermeture du menu. [Provenance](../licenses/LABORATORY_AUDIO.md). Aucun ajout de bande-son finale ou sons d'interaction non demandés. La vitesse du jeu n'altère ni le pitch des lecteurs ni l'horloge AudioServer.

Taille du corps de texte16/20/24 appliquée aux composants de menu, dialogue, combat et cinématique ; les titres/panneaux ayant leur propre style gardent ce style. Les menus utilisent leur défilement existant. Ce réglage ne revendique ni conformité exhaustive d'accessibilité, ni lecteur d'écran, ni un nouveau thème graphique.

## Persistance et contrôles

Préférences locales indépendantes de langue/caméra et de la campagne : chargement, nouvelle partie et changement d'emplacement n'en changent pas la valeur. Lecture invalide = valeurs sûres, update invalide ne remplace pas le fichier valide, écriture temporaire puis remplacement. Normalisation des nombres JSON en entiers pour retrouver les touches et tailles après relance.

Nouveaux tests :21 assertions de service sur persistance/conflits/réserves/sons/bus,25 contrôles de scène sur vrais sliders/options/boutons/capture, déplacement physique, touche dans dialogue/bataille/cinématique, confirmation sans répétition, reset et conservation lors du chargement. Les contrôles audio techniques testent données PCM, routing/gain/mute et lecteurs ; l'écoute réelle sous Windows reste au propriétaire.

Le contrôle du PCK exporté et les captures en texte24 complètent le parcours automatisé. Aucun test Nuzlocke/Soul-link/multi. La validation Windows de ce bloc reste attendue ; les anciens systèmes et la Méga ont déjà reçu D52.

Preuves : [journal des contrôles](validation/comfort-checks.log), [volumes](validation/comfort-settings.png), [touches](validation/comfort-keys.png), [dialogue24](validation/comfort-dialogue.png), [combat24](validation/comfort-battle.png), [cinématique24](validation/comfort-cinematic.png). Suite obligatoire réussie :237 assertions de domaine,25 nouveaux contrôles de scène et les parcours précédents. Rendu du PCK exporté inspecté sous Linux/Mesa ; écoute et lancement Windows attendent le propriétaire. Aucun changement de schéma, migration ou dépendance dans ce bloc.

## Livraison vérifiée

Source `d9b3d8d1c6a6ee8077f952676eaf202bd93ae651`, préversion [lab-d9b3d8d](https://github.com/DyHyugal/pokemon-archelys/releases/tag/lab-d9b3d8d). [CI réussie](https://github.com/DyHyugal/pokemon-archelys/actions/runs/38160154219),47secondes. ZIP public téléchargé : CRC, SHA256, manifeste/commit, empreintes EXE/PCK, LIRE-MOI ciblé et notice audio contrôlés. EXE officiel inchangé ; pas de nouvelle signature ni fusion automatique.

[Télécharger Windows](https://github.com/DyHyugal/pokemon-archelys/releases/download/lab-d9b3d8d/Archelys-Laboratoire-Windows.zip). SHA256 ZIP : `f10f7a9f33e374d0d4295fe879540e5ce49cdf0239ba42ba0ab560a30a6cd4a3`. Essai Windows et écoute du bloc confort restent au propriétaire ; D52 valide déjà les anciens blocs et la Méga.
