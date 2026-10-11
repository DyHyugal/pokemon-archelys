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

### D51 : blocs 7 à 9 regroupés, suite solo indépendante du test Méga

7. Pokédex : historiques vu/obtenu, filtres, fiches et habitats issus des rencontres légales du laboratoire ; catalogue final toujours attendu.
8. Mise en scène : timeline de caméra/texte FR/EN, verrouillage des commandes de jeu, distinction scène principale non passable / secondaire passable, galerie de replay. Aucune scène du scénario final produite.
9. Persistance : trois emplacements solo, préférence du slot actif, autosave distincte, récupération explicite de la sauvegarde précédente, migration avec originaux préservés.

Ces trois blocs forment un seul build et un seul parcours de test. Le correctif Méga y reste inclus. Mapping de production, assets finaux, personnalisation/audio/commandes, reproduction/fossiles et extension des interactions de combat restent ensuite à planifier dans les règles approuvées ; réseau et modes défi reportés. La suite ne constitue pas une annonce de fin du moteur ou du jeu.

### D52/D53 : bloc 10 — confort après validation de D51

D52 valide fonctionnellement les blocs7–9 et la Méga sous Windows. Bloc10 : personnalisation des touches clavier (déplacement/interagir/menu/sac/journal), trois volumes et sons d'essai originaux, taille des textes16/20/24. Une seule livraison avec parcours groupé. Réutiliser la touche d'interaction dans dialogues, combats et cinématiques ; garder les retours sûrs et les confirmations manuelles. Préférences locales séparées de toutes les sauvegardes, sans changement de schéma ni dépendance. Audio final, personnalisation graphique du héros, assets et mapping de production restent distincts ; manette et accessibilité avancée ne sont pas prétendues terminées.

### D54 : bloc11 — interactions de combat, trois sous-blocs dans un seul lot

11a. Abri : priorité4, protection jusqu'à la fin du tour, répétitions à succès décroissant, dégâts résiduels conservés, état lié à l'individu et effacé au changement.
11b. Zones : Surf touche adversaires et allié, Éboulement/Tranch'Herbe/Rugissement/Mimi-Queue ciblent les adversaires ; PP/action unique, précision/immunités/effets par cible, réduction0,75 si plusieurs cibles présentes. Ciblage volontaire de l'allié pour les attaques individuelles.
11c. Soutien : Coup d'Main, priorité5 et puissance renforcée pour l'allié durant le tour ; boutons de cible explicites et arène d'essai temporaire séparée de la campagne.

Le confort10 reste à tester et figure dans le même LIRE-MOI ; aucun test intermédiaire demandé. Après ce lot : poursuivre les acquisitions solo (œufs/reproduction/fossiles) sur les règles établies, puis les interactions de combat encore manquantes et l'IA double ; vérifier les sources et critères avant chaque implémentation. La personnalisation visuelle et les îles de production attendent les choix d'assets, le scénario et le catalogue finaux. Pas de réseau ni de modes défi.

### D55 : étude d'un socle de combat existant

La suite des interactions maison prévue après D54 est à réexaminer : l'[étude Showdown](ETUDE_MOTEUR_SHOWDOWN.md) recommande un simulateur existant plutôt que la duplication exhaustive des règles. Proposition, sans migration déjà réalisée : format/licences → adaptateur local asynchrone → parité des parcours solo et persistance → ZIP Windows avec runtime portable → interface/IA filtrée → extension du catalogue. Conserver l'aventure, les menus et préférences Godot ; reprendre les règles pertinentes de Tactica après audit, sans porter sa ROM. Réseau, raids et modes défi restent reportés. Cette recommandation n'est pas une nouvelle décision propriétaire.

### D56 : migration autorisée et exécutée

D56 valide explicitement la base Showdown. Lot : adaptateur asynchrone et format, raccordement simple/double, parité des parcours solo et sauvegardes, runtime Windows portable. Les mécaniques nouvelles de combat doivent désormais s'appuyer sur ce moteur ; ne plus étendre les calculs maison. Après playtest de ce lot : approfondir IA et présentation, puis contenus/catalogue selon les choix propriétaires, sans rouvrir le chantier réseau ou les modes reportés.

### D57 — bloc12 acquisitions, partie œufs

Réception unique de cadeaux d'essai → incubation persistée par marche effective → confirmation d'éclosion → équipe ou PC. L'incubateur séparé protège l'interface Showdown des entités non combattantes. Paramètres temporaires documentés, pas comportement final des œufs de l'équipe. Ensuite : reproduction/héritage avec données biologiques sourcées, puis fossiles avec petit catalogue technique et restauration transactionnelle. Pas de développement multi/défis pendant ce lot.

### D58 — roadmap corrigée

La reproduction et les héritages sont supprimés à la demande du propriétaire. Cela remplace les suites précédemment indiquées après le bloc œufs. Prochain bloc : restauration des fossiles, avec un petit catalogue de laboratoire sourcé et une transaction sans perte d'objet si l'équipe/PC est plein. Les œufs cadeaux restent disponibles. Les demandes historiques de reproduction ne sont plus à réaliser.

### D59 — fossiles, lot solo livré techniquement

Service au Centre → échantillons uniques dans le sac → restauration transactionnelle → équipe/PC → résumé/Pokédex/combats Showdown → sauvegarde. Évolutions40 pour les deux familles à deux stades. Suite : audit du catalogue et des interactions de combat/IA dans le périmètre solo ; pas reprise de reproduction, défis ou réseau. Les décisions artistiques/catalogue final/scénario ne sont pas déduites de cet essai.

## Proposition de lots plus conséquents après D59 — D60

Cadence : un ZIP et un parcours owner pour chaque ensemble terminé, avec contrôles locaux/CI intermédiaires. Aucun mini-build pour chaque attaque, objet ou écran. Reproduction retirée ; multi/raids/défis reportés. Dernière validation Windows reçue D52.

1. **Combat solo complet sur le catalogue d'essai** : audit du raccordement Godot/Showdown (actions forcées, tours multiples, KO/remplacements, sac/capture/retour d'état), approfondissement de l'IA simple/double avec informations visibles seulement, interface des cibles/états/champs/tours et scénarios représentatifs isolés. Livrable : un ensemble de combats couvrant ces parcours, sans réimplémenter les dégâts/statuts officiels déjà résolus par Showdown. Pas promesse de catalogue final ou conformité exhaustive à tous les formats.
2. **Aventure solo continue de démonstration** : plusieurs zones provisoires reliées, interactions/événements/journal, progression avec combat de boss et déblocage, retours/chargement cohérents, équipement/boutique/PC au service du parcours. Réutiliser et compléter les systèmes existants plutôt que présenter les mêmes fonctionnalités comme nouvelles. Livrable : parcours représentatif de bout en bout ; casting/récit/niveaux provisoires explicitement balisés, aucune île narrative finale.
3. **Quartier graphique représentatif FHD** : bâtiments/sols/eau/végétation/éclairage et avatar d'essai cohérents, animations/transitions représentatives et mesures de fluidité ; assets à provenance enregistrée. Présenter des comparatifs puis intégrer le style approuvé. Livrable : petite zone de référence, pas une refonte simultanée de tout l'archipel ; approbation artistique toujours nécessaire.
4. **Première tranche du vrai jeu** : prologue/première ville/première route/épreuve, dialogues et journal FR/EN, rencontres et économie, sauvegardes et mise en scène. Condition préalable : validation du quartier/style, du contenu narratif concerné et des espèces/assets de cette tranche. Livrable : première aventure jouable avec le rendu retenu. L'ensemble des îles ne démarre pas automatiquement.

Ordre recommandé :1→2→3→4. Des préparatifs de l'art peuvent accompagner les systèmes indépendants ; aucun résultat provisoire n'est considéré comme une validation owner.

## D61 — exécution groupée des quatre lots

Combat/IA et affichage → route persistante et règles de progression → enrichissement/rendus FHD → ouverture proposée FR/EN. Ces quatre chantiers sont développés et vérifiés techniquement dans un seul build. La condition artistique/narrative du lot4 demeure : la production de la vraie première île attend l'approbation ; le parcours livré est sa maquette jouable. Aucun développement réseau/défis/reproduction.

Après ce build : recueillir un retour groupé Windows sur parcours/sauvegarde/combats et une critique des comparatifs ; corriger les écarts observés avant extension. Choisir ensuite style, espèces/assets et dialogues de l'ouverture, puis remplacer progressivement les fixtures. Voir LOT_AVENTURE_IA_VISUELS.md. Ne pas annoncer le moteur complet ou la fidélité exhaustive sur la seule base de ces tests.

## D62 — lot suivant indépendant des choix de production

Personnage de laboratoire et persistance → thèmes d'interface et migration de préférences → photo/cadrage/export réel. Un ZIP englobe ces nouveautés et conserve le parcours D61 à tester demain. Aucun besoin de produire de nouveaux modèles Pokémon ou d'îles pour vérifier ce socle. Boutiques de vêtements et assets finaux attendent la sélection artistique. Les demandes photo/personnalisation existent déjà ; aucun nouveau mini-jeu ou changement d'économie final.

Suites après retour groupé : corriger le parcours et la présentation observés ; intégrer les arbitrages de style/casting/catalogue nécessaires à la vraie première tranche, puis produire ses assets selon le processus comparatif approuvé. Pas de démarrage automatique des modes reportés.

## D63 — gros bloc gestion et préparation des équipes

Emplacements stables et transactions de transfert → interface huit boîtes/recherche → résumé commun PC/équipe → préparation des attaques et confirmation → contrôle bout en bout avec Showdown/sauvegarde. Réutiliser les240 places et les règles du catalogue existant, pas un nouveau système de coût ou de relâchement. Une livraison conserve tous les lots précédents à tester demain.

Après ce bloc, priorité au retour propriétaire groupé et aux décisions qui débloquent les vrais contenus/assets ; ne pas produire arbitrairement de nouvelles îles ou500 Pokémon. Les fondations de collection/preparation sont testées, pas un jeu complet annoncé.
