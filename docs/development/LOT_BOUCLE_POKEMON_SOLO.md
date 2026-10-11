# Lot D47 — boucle Pokémon solo

Le propriétaire valide lab-d33e5ee (D46) et demande de regrouper les trois blocs suivants, avec un seul playtest. Objectif : une boucle cohérente équipe → rencontre/combat → capture/progression → PC → sauvegarde.

## Portée développée

- Équipe six membres, changement du leader, PC 240 places, IDs persistants ; dépôt du dernier membre apte interdit ; retrait dans une équipe pleine interdit.
- Résumé, statistiques calculées, 25 natures, IV 0–31, EV 0–252/510, édition gratuite hors combat et type de Puissance Cachée. Appliquer une saisie illégale ne modifie rien.
- Équipement et inventaire : Baie Oran, Restes, Œuf Chance ; Potion et deux remèdes ; retrait d'objet sans duplication ; rappel gratuit parmi les attaques du catalogue.
- Combat solo au tour par tour : choix, PP/Lutte, types, catégories, précision/évasion, priorités/Vitesse, critique, six niveaux de variations, changements, KO/remplacement, victoire/défaite, EXP et EV gagnés. Statuts brûlure/poison/paralysie/sommeil/gel, confusion et apeurement ; Engrais/Brasier/Torrent/Statik sur le catalogue.
- Rencontres en marchant dans un rectangle d'herbes ; IV/nature sauvages générés ; stade évolutif légal en montée et descente ; Pikachu ne devient pas Raichu automatiquement.
- Poké Ball/Super Ball, affaiblissement/statut, capture vers équipe puis PC ; refus sans consommation si PC et équipe pleins ; capture/fuite interdites contre dresseur.
- EXP et caps non décroissants ; aucun stockage de niveaux au-dessus du cap ; décisions d'apprentissage/remplacement/refus et évolutions conservées dans les saves ; évolutions successives et Pierre Foudre.
- Deux dresseurs techniques, soins gratuits et outils F3 pour tester sans grind. Argent/reward de première victoire seulement ; rematch ne baisse pas le cap. Défaite : perte technique plafonnée à 100 ₽ et retour au point de soins. Ces chiffres ne sont pas l'économie ou l'équilibrage final.

## Catalogue et fidélité des règles

13 espèces et 27 attaques réellement intégrées. Les trois premiers membres niveau 8 sont une équipe d'essai, sans choix de starters définitifs. [Données, origine, version et licence](../../game/data/pokemon/README.md). Données PokéAPI figées et empreintes vérifiées ; aucune bibliothèque, sprite ou modèle Pokémon importé. Affichage de combat encore textuel, assets et animations finaux à traiter au bloc graphique.

Ce lot couvre les comportements sur ce petit catalogue. Il ne valide pas une conformité exhaustive 9G : arrondis/modificateurs exacts de dégâts à compléter, capture conventionnelle sans capture critique ni tous les modificateurs spécifiques 9G, fuite sauvage simplifiée garantie, attaques hors catalogue et talents alternatifs absents. L'IA choisit parmi ses propres attaques avec les types visibles, sans lire le choix futur du joueur ; ce n'est pas l'IA difficile finale. Terrains/climats, doubles/Méga, catalogue étendu et reproduction restent aux blocs concernés. Les niveaux/caps 10→18→36 sont uniquement le parcours technique de test.

## Sauvegardes et architecture

Schéma 3, lecture des schémas 1/2. Position, anciens objectifs et jeton préservés ; roster initial fourni une seule fois à la migration. Copie de l'original `.v1.backup` ou `.v2.backup` avant remplacement, plus backup roulante. Équipe/PC/PV/PP/IV/EV/natures/sac/argent/caps/victoires/choix en attente persistés. Langue/caméra restent indépendantes. Ancien build incapable de lire schéma 3 : restaurer une copie originale pour rollback, jamais écraser ses originaux.

Domaine indépendant du moteur de rendu ; UI émet des commandes. Aucun réseau ajouté. Sauvegarde, chargement, édition et menus d'exploration bloqués pendant le combat. Les touches maintenues ne passent pas les événements de combat ; chaque message attend une confirmation.

## Vérification et livraison

114 contrôles de domaine (43 existants + 71 nouveaux), deux parcours de scène réels et import GLB. Nouveaux contrôles : formules de statistiques indépendantes, EV/IV illégaux, types, priorité/KO, PP/Lutte, statuts, consommables/équipement, capture/PC plein, XP/caps/évolutions/choix persistés, corruption et migration des sauvegardes. UI : marche en herbes, commandes par boutons, blocage du mouvement, confirmations manuelles, capture équipe pleine→PC, sauvegarde/reprise et apprentissage/évolution.

Les captures Linux logiciel servent à inspecter le rendu ; aucune mesure de GPU Windows ou validation artistique finale. Un seul parcours owner dans le LIRE-MOI. EXE moteur officiel inchangé ; les données PCK changent. Branche de travail poussée, aucune fusion automatique.

Contrôles locaux réussis : [log](validation/pokemon-loop-checks.log). Captures inspectées : [résumé](validation/pokemon-team.png), [combat](validation/pokemon-battle.png), [apprentissage](validation/pokemon-choices.png). Import de données répété avec sources figées et empreintes vérifiées.

## Livraison publiée

[ZIP Windows lab-2816c71](https://github.com/DyHyugal/pokemon-archelys/releases/download/lab-2816c71/Archelys-Laboratoire-Windows.zip) ; [CI réussie](https://github.com/DyHyugal/pokemon-archelys/actions/runs/38141018877). Archive publiée téléchargée : CRC, empreintes ZIP/EXE/PCK, commit source, LIRE-MOI et notice PokéAPI vérifiés. EXE identique octet pour octet à lab-d33e5ee validé par le propriétaire. PCK exporté chargé et combat rendu sous Linux logiciel ; cela ne remplace pas le test Windows. Version source du build : 2816c71.
