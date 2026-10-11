# Ordre de développement

L’autorisation du 11 octobre 2026 permet de commencer la conception et les essais en autonomie. Le cahier est approuvé ; les propositions et les validations de rendu restent distinctes.

## 1. Socle et laboratoire — commencé

Architecture séparant domaine, services et présentation ; outils reproductibles ; projet Godot ; zone provisoire ; déplacement, caméra, modèle animé, sauvegarde et trois processus réseau. Vérifier rapidement ce qui est coûteux avant de produire la région.

## 2. Stabiliser les systèmes qui conditionnent tout le jeu

Priorité solo : interactions et dialogues localisés, progression, sauvegardes, données Pokémon, inventaire et résumés, combat solo puis rencontres et captures. Les règles Pokémon doivent être spécifiées/testées avant de remplacer le combat factice. Raids, rattrapage, échanges et spectateur attendent la reprise multijoueur. L’objectif est une petite boucle fonctionnelle vérifiée, pas de couvrir immédiatement 500 espèces.

## Priorité confirmée après le retour Windows

D35–D37 : premier laboratoire confirmé jouable sous Windows, caméra à rapprocher. Les travaux suivants sont solo ; ne pas prolonger les essais connexion/saves multi. Un modèle de dialogue indépendant de la scène, des données FR/EN et le simulateur séparé préparent l’adaptation future sans coder le réseau de production. Les commandes réseau de l’ancien essai restent masquées par défaut, sans supprimer ses sources. Le socle dialogue est testé avec un PNJ de laboratoire, sans scénario imposé.

Prochaines étapes indépendantes : catalogue de données et validation des règles 9G, menus d’équipe/résumé, inventaire ; première rencontre/combat/capture après le choix du petit lot d’espèces et des assets autorisés. Éprouver quelques échantillons visuels avant le mapping de production. Aucun chantier des îles n’est lancé à partir du graybox seul.

## 3. Éprouver la direction artistique

Comparer quelques rendus sur le même quartier : matériaux, caméra, éclairage, avatar, végétation et eau. Choisir le style et le niveau de détail avec le propriétaire. Vérifier pipeline Blender/glTF, rig, animations et budget performance. Le décor du laboratoire ne fixe pas le niveau graphique demandé.

## 4. Mapping de la première île

Plan des routes, villes, biomes, transitions, points d’intérêt et blocages ; graybox d’abord pour distances et exploration ; modularité des bâtiments ; remplacement progressif par assets validés. Ne pas produire la carte entière avant de contrôler un quartier représentatif.

## 5. Première boucle d’aventure

Prologue, PNJ, journal, première route, rencontres, capture, soins, boutique, arène/épreuve, boss et ouverture draconique. Version solo testable indépendamment. Préserver des événements et règles séparés de la présentation ; leur adaptation coop et les contrôles de regroupement viennent plus tard. Réglages et progression comparés aux règles retenues de Tactica.

## 6. Extension par île

Chaque île reprend les systèmes éprouvés et ajoute ses biomes/événements propres. Revalidation des évolutions, caps, données et IA sur toute la plage de progression, pas uniquement la première rencontre. Retours draconiques construits au rythme des étapes.

## 7. Fin principale et postgame

Défi divin, repaire RR, libération du père et conséquences visibles ; portails célestes, huit arènes Ultra-Dimension, revanches, Tour de Combat et visiteurs mystère. Périmètre réévalué sans ajouter des années silencieusement.

## 8. Finalisation V1

FR/EN complets, playtests solo/coop, équilibrage, performances PC de référence, compatibilité save, documentation joueurs et publication. Windows exécutables, pas ROM. Ports autres après bilan V1.

## Cycle de travail

Une tâche → critères d’acceptation → courte branche de travail → tests adaptés et build si pertinent → mise à jour des preuves → PR vers develop → validation des jalons sur main. Une seule branche temporaire active par défaut. La branche actuelle réunit le cadrage et le laboratoire de cette session ; elle n’est pas encore fusionnée dans develop.

Le questionnaire restant contient des choix avant le système concerné ; ses 51 réponses ne sont pas toutes nécessaires pour déplacer un avatar dans le laboratoire. En cas d’inconnue, utiliser un comportement d’essai explicitement balisé, pas une règle finale supposée.

## Cadence après D43

Livrer des lots cohérents plutôt qu’une fonctionnalité isolée par ZIP. Les contrôles locaux/CI restent systématiques ; le LIRE-MOI rassemble un parcours owner pour toutes les nouveautés. Premier lot : préférence langue/zoom, interactions, journal, sac et migration. La production des îles et les données Pokémon choisies restent conditionnées aux arbitrages et à la direction artistique.

### Bloc après lab-e84ee99 validé

Assembler les menus solo autour des services existants : Pause, Sac, Journal et Paramètres, sauvegarde/chargement, contrôles modaux et HUD dégagé. Ensuite poursuivre les systèmes solo indépendants du casting ; contenu Pokémon, scénario et production d'îles restent soumis aux choix/validations déjà identifiés. Aucun démarrage des travaux réseau.

### D47 : les trois premiers blocs sont réunis

Équipe/résumé/PC → moteur solo → rencontre/capture/progression sont les étapes internes d'un seul lot, avec un build et un parcours owner à sa fin. Premier catalogue provisoire pour éprouver la boucle avant extension. Les systèmes avancés, correction des limites de fidélité 9G, graphique représentatif et décisions produit restantes demeurent explicites dans le rapport.
