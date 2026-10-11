# Coopération — exigences et architecture à éprouver

Exigences : 1/2/3 joueurs, même aventure ; campagnes solo et coop distinguées ; sauvegarde authoritative chez l’hôte. Copies clients de secours permettant restauration/changement d’hôte, pas fusion de branches de progression divergentes.

Exploration indépendante entre deux étapes. Les événements scénaristiques attendent tous les membres attendus de la campagne. Absence ne signifie pas qu’on avance sans l’ami et qu’il rattrape seul. Rôles de déclencheur de dialogue et composition du groupe restent à fixer. Q10 autorise désormais ajout/retrait de participants ; mécanisme de rattrapage individuel à résoudre avec la campagne commune.

Chaque dresseur possède six Pokémon. Renforts humains remplacent les rivaux quand la scène le permet. Duel/PvP et échanges seulement dans la même campagne au départ. Informations spectateur identiques à celles du joueur regardé, sans mouvements ennemis cachés révélés.

## Formats demandés

- Solo classique et Duo ponctuel.
- Coop Duo avec un actif par joueur, réserve propre, joueur éliminé en spectateur.
- Raid phasé : plusieurs actifs joueurs contre un boss à la fois, puis transition au suivant.
- Raid simultané : jusqu’à trois actifs par camp dans un seul tour, priorité et vitesse.

Le dernier format exige un système custom ; appeler le tour « classique » ne fournit pas ses règles. Pas de raid automatique emprunté à Écarlate/Violet. Spécifier sélection des cibles, effets de zone et effets de terrain à six actifs avant implémentation.

## Intégrité

Un combat commencé ne reçoit pas de nouvel entrant. Déconnexion = abandon et retour à l’état avant combat, sans annuler les progrès indépendants d’un autre joueur. Au démarrage d’une scène, tous doivent être présents. Le remplacement IA pour absence dans une activité non scénaristique reste à préciser.

Proposition technique à éprouver : hôte arbitre actions, transactions et écritures ; commandes clients validées ; identifiant de campagne, de joueur, révision de sauvegarde, journal de transaction et écritures atomiques. Les réglages de difficulté sont communs. Le Soul-link exige un service de liens commun, avec résolution des KO concurrents.

LAN/direct d’abord proposé ; invitation Internet universelle, migration d’hôte à chaud et infrastructure de type MMO non promises. Serveur dédié éventuel = étude distincte. Tester avec trois processus et au moins deux machines réelles avant de considérer le réseau validé.

## Complément Q

Attente ou rival IA pour combat non scénaristique lorsqu’un ami manque ; scènes exigent présence. Délai 60 secondes puis action automatique. Raids sans dégâts aux alliés, captures garanties individuelles, Soul-link/caps facultatifs. Nouveaux joueurs acceptés mais rattrapage encore à spécifier. Édition IV/EV/natures gratuite hors combat dès le début. Réglages partagés ne doivent pas diverger entre clients.
