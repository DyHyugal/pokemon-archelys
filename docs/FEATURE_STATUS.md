# État des fonctionnalités

Les statuts portent sur les preuves, pas sur l’enthousiasme ou la présence dans une roadmap.

| Fonction | État | Preuve ou condition |
|---|---|---|
| Cadrage V0.1 | APPROUVÉ | Confirmation explicite du propriétaire, 11 octobre 2026 ; questions ouvertes conservées |
| Git main/develop | PRÉPARÉ | Branches initialisées ; vérifier push remote |
| Moteur Godot/Blender | LABORATOIRE TESTÉ | Godot 4.6.3, Blender 4.3.2 ; adéquation finale non validée |
| Assets 3D animés | PROTOTYPE ORIGINAL TESTÉ | Mannequin GLB, sept os/une animation ; aucun Pokémon intégré |
| Combat 9G + exceptions | SOCLE SOLO DÉVELOPPÉ ET TESTÉ | Lot D47 : 13 espèces/27 attaques ; conformité exhaustive, Méga et règles avancées à compléter |
| IA difficile | DEMANDÉ | C18 ; comportements Tactica à analyser |
| Coopération 2/3 | REPORTÉ — ESSAI LOCALHOST CONSERVÉ | Trois processus ENet ; pas d’Internet ni combat réseau |
| Raids phasés/simultanés | DEMANDÉ | R01 ; règles détaillées ouvertes |
| Sauvegardes et migration | SOLO SCHÉMA 3 TESTÉ | Équipe/PC/sac/progression/choix, lecture v1/v2 et copies originales ; réseau reporté |
| Soul-link | DEMANDÉ | C28 ; règles précises ouvertes |
| Région et scénario | EN CADRAGE | Thèmes et synopsis, pas de maps |
| Résumé IV/EV/natures/PC | DÉVELOPPÉ ET TESTÉ LOCALEMENT | Lot D47 : valeurs réelles, validation IV/EV/nature, PC, équipement ; test Windows attendu |
| Actions terrain | DEMANDÉ | C32 |
| Wiki joueurs | PRÉPARÉ LOCAL | Rubriques documentaires ; non publié |
| Exports Windows | PREMIER BUILD VALIDÉ WINDOWS | Owner : lab-09897ca lancement/fluidité/déplacement/save/combat OK ; nouveau build à retester |
| FR/EN complets | DEMANDÉ | C25 |
| Réponses Q01–Q16 | TRANSCRITES | Classeur et JSON conservés ; décisions D22–D33 |
| Scénario complet et casting | PROPOSÉS | Documents V0.1, approbation owner attendue |
| Règles Soul-link | PROPOSÉES | Mode facultatif ; détails à valider |
| Préférences langue/caméra | DÉVELOPPÉ ET TESTÉ | Stockage automatique indépendant, conservation au chargement et nouvelle scène ; nouveau build Windows à retester |
| Journal et sac | SOCLE DE TEST DÉVELOPPÉ | Trois objectifs de laboratoire, caisse unique/jeton et sauvegarde ; pas de scénario/catalogue final |
| Migration save 1→2 | TESTÉE LOCALEMENT | Position/progression conservées, original .v1.backup préservé ; retest Windows attendu |
| Dialogues PNJ | SOCLE SOLO TESTÉ | PNJ de laboratoire, proximité, avance manuelle, blocage du déplacement, données FR/EN ; pas de scénario final |
| Distribution portable EXE + PCK | EXPORT TESTÉ TECHNIQUEMENT | EXE identique au template officiel ; PCK chargé/rendu sous Linux ; lab-477caad lancé sans avertissement chez le propriétaire ; nouvelle variante à retester |
| Signature Windows | DEMANDÉE — NON DISPONIBLE | Aucun certificat/service de signature ; build non signé, avertissement Windows signalé par owner |
| LIRE-MOI par build | PRÉPARÉ | Version/commit/hash injectés, tests owner précis et diagnostic de blocage Windows ; nom EXE fixe |
| Caméra et menus solo | VALIDÉS WINDOWS | lab-d33e5ee validé par propriétaire (D46), ergonomie et fonctionnement OK |

Priorité D36 : solo d’abord ; réseau, copies/imports de campagnes et Soul-link coop reportés. Le rendu actuel demeure provisoire.

## Bloc menus solo

Retour propriétaire D44 : lab-e84ee99 validé, excepté l'absence d'un menu Sac. Le nouveau bloc fournit Pause, Sac (jeton/quantité/description ou sac vide), Journal, Paramètres FR/EN et distance caméra persistante, sauvegarde/chargement. Outils laboratoire cachés par défaut. Développement et vérification technique du bloc ; validation Windows et visuelle du nouveau build encore attendue. Pas de contenu ou combat Pokémon final.

## Boucle Pokémon solo regroupée

Menus lab-d33e5ee validés par le propriétaire (D46). Lot D47 : équipe/PC, résumé/IV/EV/natures, équipement et rappel, combat solo, rencontres/capture, EXP/apprentissages/évolutions/caps et stockage schéma 3 développés dans le laboratoire. Catalogue de 13 espèces/27 attaques, pas les 500 entrées finales. Contrôles de domaine et parcours UI exécutés ; validation Windows du nouveau lot attendue. Le moteur n'est pas un simulateur 9G exhaustif : arrondis exacts, capture critique/modificateurs spécifiques, catalogue complet, terrains/climats, Méga/doubles et IA difficile restent à implémenter/vérifier. [Portée exacte](development/LOT_BOUCLE_POKEMON_SOLO.md).
