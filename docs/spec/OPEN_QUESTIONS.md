# Questions ouvertes

Ces points ne bloquent pas la rédaction du cadrage. Ils doivent être résolus avant la mise en œuvre du système concerné. Ne pas inventer la réponse.

## Avant scénario détaillé

- Confirmer la synthèse : cinq thèmes d’îles + île céleste + site Æther ; ordre, île de départ et connexions.
- Expliquer pourquoi l’île draconique et céleste échappent au contrôle annoncé de toute la région.
- Fixer le rôle de Silver, l’identité des dirigeants, la source de puissance céleste et le sort final du père.
- Nombre d’arènes/épreuves avant les boss, ordre des défis divins, soins et défenses du titre.
- Huit arènes Ultra-Dimension en postgame confirmées ; architecture et récit de ce contenu à concevoir.
- Contradiction à résoudre : scènes clés impossibles à passer versus journal garantissant de ne pas perdre les objectifs.

## Avant prototype combat et réseau

- Raid par phases et simultané : répartition fixe par île ou tirage aléatoire ? Le choix doit être sauvegardé pour la reproductibilité.
- Cibles, attaques de zone, dégâts aux alliés, effets/talents pour 3 actifs par camp ; HP, actions et immunités des boss ; passage des phases.
- Taille de campagne fixée ou modifiable, identités des joueurs attendus, arrivée d’un nouveau joueur et changement d’hôte.
- Remplacement rival IA quand un joueur manque à un combat normal, sans autoriser scénario en son absence.
- Délai d’action, conséquence de délai dépassé et périmètre du retour avant combat en cas de déconnexion ; captures et objets déjà validés ailleurs ne doivent pas être annulés.
- Attribution des captures de raid ; chances individuelles et moment d’enregistrement ; échanges atomiques, KO liés Soul-link pendant plusieurs combats simultanés.
- Soul-link : capture manquée, doublons, genres/types éventuels, cadeaux, lien par zone ou par rang, remplaçants et pertes simultanées. Il n’existe pas une règle universelle unique à importer sans validation.
- Éventuelle invisibilité de certaines commandes pendant PvP pour éviter de révéler une action à l’adversaire via le spectateur.
- Référence 9G exacte, catalogue des attaques réintroduites et exceptions ; Méga des deltas ; mutations IV/EV hors combat et conditions de disponibilité.

## Avant production graphique et livraison

- Bibliothèque réellement disponible, licences, formats et qualité des modèles animés ; coût des 9 Fakemons et des variantes.
- Version du moteur et renderer après essai ; matériel de référence pour le minimum, budget performance.
- Charte visuelle, thèmes de couleurs, exactitude des noms FR/EN, musique et sons.
- Plongée et île sous-marine : estimation et décision de périmètre avant ajout.
- Synchronisation du wiki, hébergement, licence du code et actifs originaux ; séparation des spoilers publics.
- Invitation Internet sans configuration, coût/limites de relais, serveur dédié : décider après un essai vérifiable.


## Précisions ouvertes après le scénario V2 du 16 octobre 2026

Les questions historiques ci-dessus sont conservées pour provenance ; plusieurs ont depuis reçu des réponses dans `docs/cadrage-valide`. **Ne pas les rouvrir sans nécessité**. Après la nouvelle bible [SCENARIO_INTEGRAL_V2_CODEX.md](../design/SCENARIO_INTEGRAL_V2_CODEX.md), restent à valider : noms définitifs des six îles et des personnages locaux ; correspondance finale des branches Aqua/Galaxie/Plasma/Flare aux îles II–IV ; identité des divinités, gardiens, équipes et starters ; nature exacte de Couronne Zéro et de la Concordance ; sort individuel des héritiers ; détails de famille (mère/triplés) ; questionnaire final et variations linguistiques. L'architecture narrative 1 à 3 rôles joueurs/PNJ est un **choix acté**, mais son implémentation réseau reste reportée.


## Suite de l'audit D118 — questions d'implémentation encore ouvertes (17 octobre 2026)

- La **monture Sharpedo** est annoncée déjà implémentée par le propriétaire ; vérifier concrètement ses capacités actuelles (déclencheur, limites en mer, transitions de carte, coop), plutôt que réécrire l'outil. Concevoir les repères de l'épreuve et la plage d'arrivée sur île II.
- Pour **Dracaufeu**, le propriétaire demande de **débloquer vol libre et voyage rapide aux villes après libération II**, puis d'atteindre III en volant. **Ne pas affirmer que cette Pokémonture ou ses deux modes est déjà fonctionnelle sans audit.** Règles de vitesse, survol des mers, obstacles et destination rapide = détails d'exécution à fixer.
- **Quatre gardiens d'entrée draconiques** : niveau exact et espèces encore à valider (tier 38 provisoire), compatibilité avec la difficulté Tactica, niveaux des Pokémon sauvages après chaque porte. Il est explicitement interdit de conditionner l'entrée d'un biome aux îles II–IV ; le modèle de revanche tier 57/80/95 est facultatif et doit être validé indépendamment.
- Confirmer si le **duel du gardien plus les activités internes** forment l'épreuve officielle de chaque biome, comme proposé, sans deuxième combat maître obligatoire ; l'existence de quatre épreuves draconiques et d'une dernière arène demeure en vigueur.
- Confirmer le verrou éventuel de la **dernière arène Dragon** après les quatre libérations, en plus des quatre épreuves ; il ne doit jamais bloquer l'accès aux espèces des biomes.
- Le nouvel audit impose aussi des corrections de mapping (volcan en descente sur cinq paliers, village au fond, orientation des arches/bancs, camps et forteresse Magma). Ces corrections **n'ont pas été exécutées dans Godot** par la présente documentation.
