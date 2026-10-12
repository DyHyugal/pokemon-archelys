# Pokémon Archélys

Fangame Pokémon en cours de conception : un nouvel archipel, un récit original et une aventure solo ou coopérative jusqu’à trois joueurs.

**État : cadrage approuvé et laboratoire solo jouable ; ouverture proposée, pas de V1 finalisée.**

Le nom de travail est Pokémon Archélys. Le rendu cible est une 3D stylisée nette en Full HD sur Windows. Les choix techniques doivent être éprouvés avant la production.

La [documentation de conception sur develop](https://github.com/DyHyugal/pokemon-archelys/tree/develop/docs) contient le cahier des charges V0.1 à relire, les décisions, la roadmap et les réponses aux questionnaires.

Les [propositions graphiques des six îles et du site Æther](docs/design/ATLAS_PROPOSE_2026-10-12.md) comprennent sept planches de quatre vues. Elles ont été approuvées comme direction artistique (D68), distincte des modèles provisoires intégrés.

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

**Dernière livraison : [Démo Windows lab-a732c7c](https://github.com/DyHyugal/pokemon-archelys/releases/download/lab-a732c7c/Archelys-Laboratoire-Windows.zip)** — douze blocs intégrés : expédition, actions contextuelles, Vol, services sur place, Pokédex de démo, scènes/replay, autosave séparée, archives portables, diagnostic des sauvegardes, visionneuse GLB, préflight contenu et combat lisible. Ancienne fixture tactique fiabilisée après reproduction de deux coups critiques. [CI réussie](https://github.com/DyHyugal/pokemon-archelys/actions/runs/38307537252). [Détail et limites](docs/development/LOT_DEMO_PROGRESSION_SERVICES.md), [preuves de livraison](docs/development/VERIFICATION_D72.md), parcours groupé dans le LIRE-MOI. Sauvegardes conservées ; Pokédex/starters finaux et exports Meshy attendus. Rendu de maquette toujours provisoire.

Le [lot groupé aventure/IA/visuels](docs/development/LOT_AVENTURE_IA_VISUELS.md) relie village, sentier, épreuve et épilogue, avec sauvegarde et récompenses uniques. Il enrichit les comparatifs FHD ; scénario et direction artistique proposés restent à approuver. Le LIRE-MOI du ZIP contient le parcours de test complet.

Le [lot personnage/thèmes/photo](docs/development/LOT_PERSONNAGE_THEMES_PHOTO.md) ajoute la personnalisation sauvegardée du mannequin, trois palettes d'interface et l'export PNG avec cadrage. Les assets restent provisoires ; toutes les consignes du parcours regroupé sont dans le LIRE-MOI du ZIP.

Le [gros bloc gestion des équipes](docs/development/LOT_GESTION_EQUIPES.md) apporte huit boîtes stables, les échanges avec l'équipe pleine, la recherche bilingue et la préparation d'un Pokémon stocké avec confirmation des CT/rappels. Il conserve tous les nouveaux lots précédents, à tester avec le parcours du LIRE-MOI.

Le [lot lisibilité des combats](docs/development/LOT_LISIBILITE_COMBATS.md) traduit les événements connus, permet de relire les messages déjà présentés et détaille les attaques sans consommer d’action. Les confirmations manuelles sont conservées, y compris à vitesse×4.

Le [lot options de combat et défaite](docs/development/LOT_OPTIONS_COMBAT_DEFAITE.md) ajoute les styles classiques, les soins du sac ON/OFF et corrige le retour au Centre. Showdown résout les remplacements et effets d’entrée ; les options sont enregistrées dans la campagne.

La [première île proposée en douze blocs](docs/development/LOT_PREMIERE_ILE_12_BLOCS.md) se lance dans **Aventure → Explorer la première île proposée**. Elle conserve l’équipe ; nouvel emplacement conseillé pour juger les niveaux. Bilan SPOILERS DEV, cinq captures et parcours groupé inclus dans le ZIP.
