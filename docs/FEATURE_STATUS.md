# État des fonctionnalités

Les statuts portent sur les preuves, pas sur l’enthousiasme ou la présence dans une roadmap.

| Fonction | État | Preuve ou condition |
|---|---|---|
| Cadrage V0.1 | APPROUVÉ | Confirmation explicite du propriétaire, 11 octobre 2026 ; questions ouvertes conservées |
| Git main/develop | PRÉPARÉ | Branches initialisées ; vérifier push remote |
| Moteur Godot/Blender | LABORATOIRE TESTÉ | Godot 4.6.3, Blender 4.3.2 ; adéquation finale non validée |
| Assets 3D animés | PROTOTYPE ORIGINAL TESTÉ | Mannequin GLB, sept os/une animation ; aucun Pokémon intégré |
| Combat 9G + exceptions | SOCLE SOLO DÉVELOPPÉ ET TESTÉ | D49 : 17 espèces/38 attaques, quatre Méga, terrains/climats, doubles mono-cible ; conformité exhaustive non acquise |
| IA difficile | POLITIQUE DE LABORATOIRE TESTÉE | Poseur → bénéficiaire → rappel/second poseur, sans données cachées ; switches défensifs complets non finalisés |
| Coopération 2/3 | REPORTÉ — ESSAI LOCALHOST CONSERVÉ | Trois processus ENet ; pas d’Internet ni combat réseau |
| Raids phasés/simultanés | DEMANDÉ | R01 ; règles détaillées ouvertes |
| Sauvegardes et migration | SOLO SCHÉMA 4 TESTÉ | Équipe/PC/sac/progression/choix, lecture v1/v2/v3 et copies originales ; réseau reporté |
| Soul-link | DEMANDÉ | C28 ; règles précises ouvertes |
| Région et scénario | EN CADRAGE | Thèmes et synopsis, pas de maps |
| Résumé IV/EV/natures/PC | SOCLE VALIDÉ WINDOWS | lab-2816c71, D48 ; extensions CT/talents/Méga du nouveau lot à retester |
| Actions terrain | LABORATOIRE DÉVELOPPÉ ET TESTÉ | Obstacles/collisions, Surf, Escalade et Vol carte ; déblocages provisoires, Flash sans grotte à tester |
| Wiki joueurs | PRÉPARÉ LOCAL | Rubriques documentaires ; non publié |
| Exports Windows | PORTABLE VALIDÉ JUSQU’À lab-2816c71 | Nouveau lab-58819aa exporté/publié/vérifié ; validation owner attendue |
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

## Historique — boucle Pokémon solo regroupée

Menus lab-d33e5ee validés par le propriétaire (D46). Lot D47 : équipe/PC, résumé/IV/EV/natures, équipement et rappel, combat solo, rencontres/capture, EXP/apprentissages/évolutions/caps et stockage schéma 3 développés dans le laboratoire. Catalogue de 13 espèces/27 attaques, pas les 500 entrées finales. Contrôles de domaine et parcours UI exécutés, puis validation Windows reçue (D48). À ce stade du lot D47, le moteur n'était pas un simulateur 9G exhaustif : arrondis exacts, capture critique/modificateurs spécifiques, catalogue complet, terrains/climats, Méga/doubles et IA difficile restent à implémenter/vérifier. [Portée exacte](development/LOT_BOUCLE_POKEMON_SOLO.md).

## Lot D49 — après validation de lab-2816c71

Les équipes/combat/capture de D47 sont désormais **validés Windows par le propriétaire** (D48). Le lot D49 ajoute services/exploration, essais de règles avancées et comparatifs graphiques ; développé et testé techniquement, **nouveau playtest Windows et direction artistique attendus**. Les réponses N01–N51 sont transcrites ; noms/divinités proposés, sans choix implicite.

| Fonction nouvelle | État / limites |
|---|---|
| Boutique / monnaie / Centre / intérieurs | Développé et testé, prix/lieux provisoires |
| Pêche et map/Fly | Développé et testé sur famille Magicarpe ; carte finale absente |
| Caps OFF / retour / EXP / shiny | Développé et testé ; option shiny concerne la génération future |
| Méga historiques | Quatre formes testables ; une seule par camp, y compris après KO |
| Terrains / climats | Sous-ensemble 9G testé sur catalogue ; interactions hors catalogue à compléter |
| Doubles solo | Quatre acteurs, cibles/queue/switch/KO testés ; zone/redirection/objets et IA poseurs double à compléter |
| Nuzlocke solo | Quotas/KO/PC/shiny/doublons et retrait testés ; reprise Chapignon ouverte N35, œufs/cadeaux/fossiles non présents |
| Soul-link / raid / réseau | Reportés ; les réponses règlent des choix mais ne constituent pas du code livré |
| Quartier graphique | Trois rendus FHD et lieu comparatif, validation N45 attendue ; aucune île finale produite |
| Musique / personnalisation / cinématiques | Spécifiées, pas développées dans ce lot |

[Rapport de portée et preuves](development/LOT_EXPLORATION_REGLES_VISUELS.md).

Livraison D49 : [lab-58819aa](https://github.com/DyHyugal/pokemon-archelys/releases/tag/lab-58819aa), CI verte,184assertions et parcours de scènes réussis, ZIP publié/PCK vérifiés ; nouveau test Windows et comparatifs artistiques attendent le propriétaire. Les fonctionnalités limitées/reportées restent indiquées dans le tableau et le rapport.

## Retour D50 et correctif d'accès Méga

lab-58819aa : fonctionnement du reste du lot confirmé Windows par le propriétaire, notamment CS. Méga non accessible dans son parcours : ancien Dracaufeu non équipé par le kit. Correctif développé : équipements des individus existants avec restitution de l'ancien objet, kit sans doublons supplémentaires, vraie case visible et motifs d'indisponibilité en simple/double. Test de scène reproduisant Dracaufeu37/kit/case/attaque et réservation Méga en double. Nouveau build à retester uniquement sur ce correctif.

Nuzlocke/Soul-link : **reportés, non prioritaires et non validés Windows** ; activation d'un nouveau défi retirée du menu de laboratoire, états déjà sauvegardés conservés et désactivation possible pour une ancienne partie. Aucun nouveau travail de règles ni test propriétaire demandé. Graphismes : thème/type de ville apprécié, qualité visuelle et assets finaux non approuvés.
