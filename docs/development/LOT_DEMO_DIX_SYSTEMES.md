# D71 — dix blocs solo dans la démo

Demande propriétaire du 12 octobre 2026 : poursuivre idéalement dix blocs en autonomie ; Pokédex et starters seront fournis ensuite. Aucun Pokédex, starter ou asset final n’est choisi par ce lot. Meshy demeure l’outil d’essai retenu, aucun modèle Meshy encore fourni/importé.

| Bloc | Livraison | Limite |
|---|---|---|
| 1. Contenu configurable | `data/demo/content.json` pilote starters, niveaux, rencontres, pêche, œuf cadeau et équipe du dresseur ; validation des références/stades | Catalogue d’essai22espèces ; futurs nouveaux IDs exigent enrichissement préalable du catalogue, pas un import automatique de500espèces |
| 2. Règles de la partie | Difficulté, Défini/Choix, soins du sac, cap ON/OFF, EXP et chance shiny modifiables/sauvegardés | Réutilise moteur/IA existants ; aucun nouveau raid/défi |
| 3. Chromatique dans le résumé | Flag éditable gratuitement hors combat, sauvegardé, envoyé au simulateur ; choix légaux de talents conservés | Textures chromatiques des modèles non produites |
| 4. Sac utilisable | Liste triée, quantités, utilisation sur membre choisi, équipement direct, refus sans dépense | Catalogue et prix provisoires conservés |
| 5. Incubateur de l’aventure | Professeur physique, œuf cadeau unique configurable, marche, éclosion équipe/PC et persistence | Carapuce/20m sont fixtures, pas distribution finale ; reproduction toujours retirée |
| 6. Fossiles au Centre | Chercheur physique, service existant désormais compatible avec isle-center, origine réelle enregistrée | Trois fossiles d’essai uniques explicitement marqués, niveaux/distribution non finalisés |
| 7. Photo de la démo | Cadrage du vrai héros, déplacement bloqué, UI masquée, PNG réel, retour caméra/menu | Manette virtuelle B routée ; manette physique et performances Windows à vérifier |
| 8. Pêche au port | Interaction sur la jetée, rencontre sauvage réelle Showdown | Magicarpe5 provisoire ; pas de modèle3D correspondant, indication « modèle en attente » |
| 9. Conditions de combat visibles | Climat/terrain et durée sur l’interface3D, messages toujours manuels | Ce n’est pas une livraison d’animations d’attaques finales |
| 10. Import d’assets locaux | Inspection GLB, enregistrement source/droits/empreinte, refus d’écrasement, registre avec échelle/orientation, remplacement visuel des bâtiments | Registre livré vide ; héros et modèles Pokémon spécifiques restent à adapter après réception et validation des assets |

## Défaut supplémentaire corrigé

L’Œuf Chance équipé empêchait le démarrage Showdown : l’objet est absent de son catalogue compétitif. Le bridge déclare maintenant cet objet tenu sans effet de combat spécifique. L’EXP reste gérée dans l’aventure ; les mécaniques générales de retrait d’objet restent celles de Showdown. Tests natifs : import, conservation après tour, reconnaissance de l’objet et export du retrait. Aucun fichier upstream modifié ; extension d’intégration enregistrée dans la provenance.

## Sauvegardes et tests

Enveloppe de démo et campagne5 inchangées, anciens emplacements conservés. Le starter historique d’une sauvegarde est validé par le catalogue disponible, indépendamment de la nouvelle sélection de départ ; un changement de starters ne doit pas rendre cette partie illisible. Les méthodes restent bloquées pendant les combats et les services ne modifient pas la campagne du laboratoire.

Contrôles : suite locale complète, 29 contrôles services intégrés en headless, 33 sous rendu GL avec captures/PNG photo, 74 contrôles bridge natif. Les imports sont exercés avec un GLB original d’essai dans un répertoire temporaire ; refus PNG, chemin invalide et échelle invalide sans perte du registre. Aucun asset réel Meshy testé.

Dernière validation Windows fonctionnelle propriétaire : D52. Les graphiques de maquette restent rejetés comme finition finale ; captures Linux llvmpipe = preuve d’intégration, pas validation artistique ni performance GPU joueur. Mono prioritaire, multi/raids/défis reportés.
