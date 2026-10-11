# Pokémon Archélys

Fangame Pokémon en cours de conception : un nouvel archipel, un récit original et une aventure solo ou coopérative jusqu’à trois joueurs.

**État : cadrage approuvé et laboratoire technique initial. Aucune version d’aventure jouable n’est disponible.**

Le nom de travail est Pokémon Archélys. Le rendu cible est une 3D stylisée nette en Full HD sur Windows. Les choix techniques doivent être éprouvés avant la production.

La [documentation de conception sur develop](https://github.com/DyHyugal/pokemon-archelys/tree/develop/docs) contient le cahier des charges V0.1 à relire, les décisions, la roadmap et les réponses aux questionnaires.

## Branches

`main` accueille les jalons validés ; `develop` assemble le prochain jalon. Une seule branche de travail temporaire est active par défaut, puis supprimée après intégration. L’initialisation de main est documentaire et ne représente pas une version jouable validée.

## Contribution

Lire [AGENTS.md](AGENTS.md) avant toute modification. Les choix de game design et la validation visuelle appartiennent au propriétaire du projet. Les recherches et prototypes ne sont pas présentés comme des fonctions terminées.

Ce projet est distinct de Pokémon Tactica. Aucun modèle, animation ou musique tiers n’est inclus à ce stade. Le dépôt ne définit pas encore une licence générale sur son code et ses contenus ; les droits des assets seront suivis séparément.

Le [laboratoire et son bilan](https://github.com/DyHyugal/pokemon-archelys/blob/docs/cadrage-valide/docs/development/BILAN_SESSION_2026-10-11.md) sont dans la branche de travail en attente d’intégration. Les prereleases éventuelles sont des prototypes, pas la V1.

Le [bloc menus solo](docs/development/LOT_MENUS_SOLO.md) présente le Sac, le Journal et les Paramètres, dont la distance de caméra conservée entre lancements.

Le [lot regroupé de boucle Pokémon solo](docs/development/LOT_BOUCLE_POKEMON_SOLO.md) relie équipe/PC, combat, rencontres, capture et progression sur un catalogue provisoire, avec un parcours de test unique dans le ZIP.

Le [nouveau lot exploration/règles/comparatifs](https://github.com/DyHyugal/pokemon-archelys/blob/docs/cadrage-valide/docs/development/LOT_EXPLORATION_REGLES_VISUELS.md) est disponible en [ZIP Windows lab-58819aa](https://github.com/DyHyugal/pokemon-archelys/releases/download/lab-58819aa/Archelys-Laboratoire-Windows.zip). LIRE-MOI contient un seul parcours de test ; dossiers Comparatifs et Documentation contiennent trois rendus FHD, propositions de noms/divinités (SPOILERS DEV) et Excel des questions restantes avec colonne réponse. Le prototype ne constitue pas l'aventure finale ou une direction artistique approuvée.

Les combats du laboratoire utilisent maintenant [Showdown intégré](docs/development/INTEGRATION_SHOWDOWN.md), un simulateur local sous MIT. Pour développer : Node24.19.0, `python tools/prepare_showdown.py`, puis `python tools/check_prototype.py`. Le ZIP joueur contient le runtime ; aucune installation ni connexion nécessaire. La validation Windows de ce nouveau lot reste distincte des tests locaux.
