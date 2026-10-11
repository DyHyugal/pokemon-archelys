# D64 — messages, historique et préparation des choix en combat

Objectif : rendre les combats solo plus compréhensibles sans modifier les calculs Showdown ni les règles de campagne. Ce lot continue les travaux autorisés en autonomie ; il ne valide pas Windows les livraisons précédentes. Trois volets livrés ensemble, avec un seul parcours dans le LIRE-MOI.

## Messages FR/EN

Un formateur de présentation traite le protocole public destiné au joueur : attaques, entrées, KO, Méga, dommages/soins, statuts/guérison, incapacité à agir, variations de statistiques avec nombre de crans, efficacité/critique/échec, champs/climats, talents/objets et effets révélés. Les noms présents au catalogue sont traduits ; un effet hors catalogue conserve son nom anglais, sans importer un catalogue final. Métadonnées et requêtes du simulateur ne sont jamais affichées par ce formateur. Les lignes incomplètes reconnues sont ignorées au lieu de provoquer une erreur.

Chaque message attend la confirmation manuelle. Le compteur indique sa place dans la séquence courante. Aucun délai ne confirme les textes ; une répétition clavier ne les avance pas. Les tests accélèrent réellement le temps du moteur à ×4. Les animations et styles de combat configurables restent à réaliser séparément : ce lot ne prétend pas les implémenter.

## Historique consultable

Accessible pendant un message ou un choix, en simple et double. Historique bilingue de la bataille courante, pages de vingt messages, numéro du tour fourni par l'adaptateur. Il contient les messages déjà présentés et le message courant, jamais les messages suivants de la séquence encore en attente. Fermer par Échap restitue le même message ou choix ; la consultation ne consomme pas d'action et ne supprime pas un choix double déjà verrouillé.

Historique temporaire en mémoire, hors sauvegarde de campagne. Il est remis à zéro au démarrage d'un autre combat et n'est pas une galerie de replay après la fin. Aucune modification du schéma5 ni de ses migrations ; copies originales conservées. La pagination est aussi vérifiée sur une fixture longue, distincte des contrôles de vrais combats Showdown.

## Fiches des attaques et équipe

Dans le sélecteur simple, infobulle et interrupteur d'affichage des fiches ; en double, fiches intercalées avant les commandes/cibles existantes. Catégorie, puissance et précision de base, priorité et portée. Surf mentionne adversaires ET allié, Abri soi-même, soutien allié, attaques de zone tous les adversaires. Ce sont les valeurs du catalogue technique22/43, pas une prédiction de dégâts, de précision effective ou de KO. Les PV/PP et restrictions de commandes restent ceux du simulateur.

Le choix d'un remplaçant affiche également le statut dans la langue courante. En double, un rappel indique qu'un choix allié est déjà verrouillé. Les sélecteurs gardent leur défilement et suivent le focus ; les chiffres de fiches CT/rappel sont aussi normalisés sans suffixe décimal.

## Vérification et limites

Nouvelle suite : traductions des événements, protocole tronqué/privé, vrai combat simple et double, journal sans messages futurs, fermeture sans avance, clavier répété et temps×4, lecture sans dépenses, pagination, PP, maintien des choix doubles et sortie manuelle. 52 contrôles spécifiques réussis et suite complète réussie via `tools/check_prototype.py`. Rendu GL Linux :53 contrôles avec export PNG réel du sélecteur, distinct d'un playtest Windows. La preuve visuelle se trouve dans `verification/BATTLE_READABILITY.png`.

Showdown et Node restent épinglés, binaire Windows officiel inchangé. Aucun modèle Pokémon/île finale, réseau/raid/défi ou reproduction ajoutés. Personnalisation/photo/PC/aventure des lots précédents conservés. Dernière validation propriétaire : D52 ; Windows des lots ultérieurs reste à tester.
