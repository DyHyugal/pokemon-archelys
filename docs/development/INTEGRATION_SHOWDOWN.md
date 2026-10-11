# Intégration Showdown — D56

Le propriétaire a explicitement demandé l'intégration le11 octobre2026. Les combats Pokémon jouables simples et doubles du laboratoire utilisent désormais Showdown ; l'aventure, les menus et la campagne restent sous Godot. Le [rapport préalable](ETUDE_MOTEUR_SHOWDOWN.md) reste une preuve datée de la faisabilité, pas l'état courant d'intégration.

## Changements

Le simulateur est figé au commit `942cda71d14bf0618bd57991708a2e2734b6daba`. Le format Archélys active la9G et les Méga historiques, sans les restrictions compétitives Smogon, Téra, Dynamax ou capacités Z. Le catalogue visible reste17 espèces/42 attaques : importer les données du moteur n'ajoute ni modèles ni500 entrées à l'aventure. Les attaques anciennes comme Puissance Cachée sont compatibles avec la base étudiée, mais leur ajout au catalogue/apprentissages joueurs reste distinct.

Le [transport](../../game/scripts/services/showdown_transport.gd) utilise un processus local et un thread pour les échanges bloquants. Messages bornés, identifiants, timeout10s ; le rendu continue à tourner. Le [modèle](../../game/scripts/services/showdown_battle.gd) importe les individus par UID avec PV, statuts, compteurs de sommeil et PP actuels, puis synchronise les états, les consommations d'objets tenus et les formes temporaires. Une panne annule le combat et restaure le snapshot complet, ressources et progression incluses. Aucun moteur de secours silencieux.

Les captures, permissions du sac, EXP/EV, évolutions et progression sont isolées dans `adventure_battle.gd`. Le simulateur résout les attaques/talents/objets tenus, priorités, précision, météo et terrains. Les soins du sac simple utilisent ses objets Pokémon et consomment un tour sans attaque du joueur. Les récompenses des ennemis vaincus sont engagées à la fin du combat ; l'aventure ne modifie pas les statistiques du simulateur en plein tour. Le format de sauvegarde5 et les préférences restent inchangés. Les anciens moteurs sont conservés pour comparaison, sans usage par les combats Pokémon jouables.

L'IA reçoit une projection explicite de sa propre équipe et des adversaires actifs visibles. Pas d'IV/EV, objet, set caché ou commandes adverses. Elle conserve une politique de poseur → bénéficiaire → renouvellement, avec bénéfice de type sous terrain pour un DPS sans talent dédié et sélection de coups par données publiques. Cette politique est un socle, pas une IA experte finalisée : prévision stratégique, switches défensifs et coopération avancée restent à approfondir. Aucun portage de code Tactica.

## Vérifications

Les tests de l'adaptateur Node couvrent conditions et PP initiaux, Surf et dégâts alliés, Abri, soutien, Méga, limite après switch, soins sur le banc, adversaire pendant un tour d'objet, remplacement, vues de l'IA, UID invalides et états impossibles, remplacement partiel double et Lutte avec PP nuls.

Les tests Godot utilisent le vrai processus préparé : ticks pendant les échanges, synchronisation HP/PP, sac après acquittement, sortie/arrêt, panne et rollback, deux actifs K.O. avec un seul remplaçant, victoire scénaristique sans récompense dupliquée, sauvegarde valide et refus sans runtime. Les tests de scènes existants sont adaptés à l'asynchronisme et exercent les vrais boutons : sauvage, capture vers PC, disque, Méga, simple/double, Surf/Abri/Coup d'Main, texte et commandes personnalisées. Les anciens tests du moteur maison ne sont pas présentés comme preuve de conformité Showdown.

Commande de lot : `python tools/check_prototype.py`, après préparation du moteur. Résultats locaux : **36 vérifications Node et33 Godot réussies**, contrôles complets du prototype réussis, dont24 vérifications de scène tactique. La livraison Windows reste à éprouver sur le PC propriétaire. La suite amont ciblée61 réussis/2 ignorés de D55 reste une preuve distincte ; aucune promesse d'avoir testé chaque interaction officielle. Les règles originales et futurs Fakemons devront avoir leurs propres tests.

## Livraison et limites

ZIP portable : EXE Godot officiel non modifié, PCK, dossier showdown, runtime Node officiel24.19.0 et notices MIT/dépendances. L'archive Node est comparée aux SHA256 officiels obtenus par HTTPS ; le packager vérifie de nouveau le binaire. Cela ne prétend pas vérifier une signature Authenticode ou garantir l'acceptation par le Contrôle intelligent Windows. Aucune installation ni connexion requise à l'exécution.

Même nom d'EXE ; tests groupés dans LIRE-MOI. Windows et fluidité sur le PC propriétaire restent à valider. Les messages essentiels sont présentés en FR/EN ; certains détails du protocole (noms de champs/effets) restent techniques et devront être enrichis avec la future présentation des combats. Graphismes finaux, catalogue final, raids, réseau, Nuzlocke et Soul-link ne sont pas livrés par cette intégration.
