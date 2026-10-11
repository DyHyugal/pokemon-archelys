# Pokémon Archélys — cahier des charges V0.1

**Statut : approuvé par le propriétaire le 11 octobre 2026, avec les points explicitement ouverts conservés.** Les références A/C/R correspondent aux identifiants des questionnaires conservés dans docs/sources. Ce document décrit le jeu demandé, pas des fonctionnalités implémentées.

## Vision et rôle du propriétaire

Nouvel archipel distinct d’Alola, utilisant USUL comme référence de structure, avec une nouvelle distribution et un récit sombre. Priorités : graphismes, scénario et combats difficiles. Le propriétaire assure direction créative, arbitrages de périmètre et validation finale ; autonomie technique après les validations convenues. Aucun délai contractuel ni budget supplémentaire annoncé au-delà de l’abonnement Plus. Aucune production professionnelle de centaines de modèles n’est garantie par cet abonnement. Sources A1–A5, D2, C04, C30.

## Région et durée

Thèmes demandés : tropical/volcanique, mystique (Fée/Ténèbres/Psy/Spectre), hivernal, draconique et high-tech. S’ajoutent une île céleste de fin de parcours et un ancien Paradis Æther transformé en repaire. Six îles thématiques plus le site Æther sont confirmés (Q01). L’ordre des îles est confié au développeur pour proposition ; connexions et biomes à détailler. L’île draconique devient accessible après la première île et s’ouvre biome par biome selon la progression. Parcours principal imposé, liberté d’exploration locale. Départ sur l’île tropicale/volcanique confirmé (Q01). Sources E1–E4, C02–C03.

Durée indicative : environ 15 h avec exploration modérée, 10–12 h en rush et 20 h ou plus en prenant son temps. Elle sera réévaluée selon le contenu ; postgame envisagé de 5–10 h sans engagement. Sources A4, R/C33.

## Scénario

Le héros, 18 ans, habite la région ; son père est prisonnier du groupe ennemi. Trois compagnons du même âge : Vyna, volontaire et connaissant les bases ; Raidon, hyperactif et tête brûlée ; Hyu, réservé et logique, stratège plus confirmé. Héros peu bavard mais doté de dialogues. Le groupe cherche à empêcher la conquête mondiale et à gagner la puissance nécessaire pour libérer la région. Sources C06–C07.

Le groupe inspiré de Rainbow Rocket domine publiquement la région, bloque entrées/sorties et impose taxes et restrictions commerciales. Ses dirigeants sont principalement des descendants inventés de chefs des anciennes teams, désireux de réussir là où leurs parents ont échoué. Leur objectif et leurs méthodes se révèlent progressivement. Silver est confirmé antagoniste et représentant Rocket à la place de Giovanni (Q03). Sources C04–C07.

Le Défi divin sur l’île céleste attribue un titre de gardien à défendre. L’ordre envisagé est île céleste puis confrontation finale au repaire Æther ; le détail reste un synopsis à approuver. Les portails célestes et l’Ultra-Dimension sont disponibles en postgame. Sources C07, C03.

Récit linéaire ; cinématiques non passables, scènes secondaires ou moyennement importantes passables (Q06). Cinématiques débloquées rejouables, scènes ordinaires non rejouables. Journal des objectifs pour ne pas perdre la destination. Pas de voix ; sons et quelques cinématiques si leur coût reste acceptable. Sources G5, D5.

## Combat et progression

Tour par tour, règles 9G avec exceptions documentées : Méga des règles historiques de combat au tour par tour, une par joueur et combat, sans seconde Méga après son KO. Réintroduction d’attaques absentes avec leur dernière version pertinente, dont Puissance Cachée ; liste et interactions à auditer. Neige 9G recommandée, choix confié au développeur mais non éprouvé. Sources I1–I2, C17.

Arènes et épreuves hybrides ; un combat de boss légendaire par île. La coopération adapte le nombre de légendaires à 1/2/3 joueurs. Deux formats demandés : phases successives contre un légendaire et affrontement simultané jusqu’à 3 contre 3. Répartition fixée par île, répartie de manière équilibrée avec alternance des formats à proposer (Q07) ; cibles, dégâts de zone, statistiques de raid et phases à spécifier. Sources H1–H2, C12, C26, R01.

Caps communs à la campagne, non décroissants ; boss du même événement au même palier. Reprise de comportements Tactica par réimplémentation, notamment IA difficile non omnisciente ; table des informations connues à définir. Styles de combat, soins et animations configurables ; difficulté commune en coop. Sources C18, I4–I5, C27.

Actions contextuelles sans Pokémon compatible ; Vol depuis la carte ; déblocages scénaristiques. Force, Escalade, Surf, Vol, Éclate-Roc et Coupe demandés. Plongée/île sous-marine = étude de coût, non engagement V1. Sources E5, C32.

## Pokémon et confort

Environ 500 entrées, chaque stade et forme régionale compté ; Méga hors total des entrées mais dans le coût de production des modèles. Sélection et starters faits par le propriétaire. Créations envisagées : trois familles de trois stades, soit neuf Fakemons, et des formes delta, pour 50–100 créations au total. Les variantes de couleur ne suffisent pas toujours à produire une forme 3D complète. Sources C19, J2–J3.

Légendaires affrontables durant l’histoire mais capturables uniquement en postgame, exemplaire pour chaque joueur. Capture de groupe et récompenses individuelles à détailler. Évolutions adaptées au solo, rencontres au stade légal, règles Tactica à expliciter. Reproduction, chromatiques, fossiles, talents cachés et localisation Pokédex demandés. Sources C20, J4–J5.

IV/EV/natures modifiables dans le résumé ; modification des valeurs réelles, IV à 0 et indicateur du type de Puissance Cachée. Multiplicateur d’EXP optionnel et Œuf Chance au début. Cela remplace les PNJ d’édition envisagés précédemment ; prix/disponibilité et limites à préciser. CT réutilisables, rappel gratuit, économie inspirée d’Alola sous occupation. Sources C27, K3.

Défaite : argent perdu et retour au Centre Pokémon. Nuzlocke solo et Soul-link coop demandés ; KO d’un membre d’un groupe lié rend les autres inutilisables. Règles exactes, cadeaux, doublons et captures manquées à approuver ; restauration des sauvegardes reste libre. Sources K4, C28.

Plusieurs sauvegardes, autosave, commandes reconfigurables, réglages audio et accessibilité demandés ; paramètres détaillés à définir. Photos et pêche demandées ; autres activités au backlog. Sources K5, L3.

## Coopération

Campagne jusqu’à trois joueurs, sauvegardée chez l’hôte, séparée des campagnes solo. Copies de secours chez les invités, importables pour restaurer ou changer d’hôte ; pas de conversion automatique en campagne solo. Session close quand l’hôte quitte. Exploration et activités libres entre deux étapes, scénario bloqué jusqu’au regroupement de tous les joueurs attendus. Identités et effectif du groupe à fixer. Sources C08–C11, R06–R07.

Chaque joueur a son avatar et six Pokémon. Duo : un actif par joueur, joueur éliminé spectateur, survivant continue. Coopération en renfort à la place des rivaux. Échanges et combats entre joueurs de la même campagne dès V1. Spectateur parmi les participants, choix de l’ami visibles immédiatement mais aucune information ennemie secrète supplémentaire. Sources C13, C15–C16.

Pas d’entrée dans un combat déjà commencé. Déconnexion pendant un combat : arrêt, retour à l’état avant combat. Les combats scénaristiques ne démarrent pas sans tous les participants ; remplacement IA pour absence avant combat normal à préciser. Format figé au lancement, délai de décision accepté mais durée non fixée. Sources C14, R08.

Hébergement joueur et réseau sans service payant présupposé. LAN/direct = première option à éprouver, invitations Internet et serveur dédié à étudier. Ne pas promettre un fonctionnement universel derrière tous les routeurs. Source C10.

## Graphismes et livraison

3D stylisée, décors nets en 1920×1080 ; références DEPS/Z-A, proportions USUL, caméra contrôlée à distance moyenne, angles dédiés aux scènes. Thèmes de couleurs de l’interface demandés. Éclairage, eau, météo et mouvement de végétation selon faisabilité, pas de liste aveuglément promise. Sources C1–C5, C21–C23.

Godot et Blender acceptés pour essai, pas figés ni vérifiés. Modèles provisoires admis pour valider l’intégration ; inventaire de provenance et droits obligatoire. Recréation d’un modèle inspiré n’accorde pas automatiquement de droits sur l’univers ou les designs représentés. Pas de bibliothèque graphique déjà disponible. Sources B4, D1–D3, C22.

Windows d’abord, ZIP/exe pour tests. Objectif 60 FPS ; 120/240 facultatif. Configuration minimale à mesurer ; PC de validation propriétaire : i7 13e génération, RTX 4060 Ti, 32 Go. FR/EN complets V1 ; Linux/Android plus tard, macOS non prioritaire faute de machine. Pas de ROM. Sources B1–B3, C24–C25, R02.

Prototypes : recommencement autorisé avec avertissement. Alpha publique : migrations ascendantes, sauvegarde avant conversion, explication de l’emplacement et restauration ; retour vers une ancienne version non garanti, copie ancienne conservée. Sources R03–R05.

## Validation préalable

1. Relecture et approbation du présent document, avec les questions structurantes signalées.
2. Essais ciblés réseau/combats/sauvegardes et petite scène graphique, avant d’engager la première île.
3. Validation séparée des résultats techniques et du rendu par le propriétaire.
4. Construction progressive de la première île puis jalons suivants, avec suivi des changements de périmètre.

## Complément confirmé Q01–Q16

Les réponses Q sont des décisions explicites qui complètent le cahier approuvé ; les propositions de scénario et de règles annexes restent à valider séparément.

- RR occupe les îles habitées mais pas la réserve draconique ni l’île céleste. La résistance locale et les Pokémon draconiques rendent impossible une occupation durable par les sbires (Q02).
- Un biome correspond à un boss/champion ; au minimum une arène et un défi par île ordinaire, hors repaire et île céleste. Ne pas confondre ces combats avec le boss légendaire final. Défi divin : quatre combats très difficiles, pause pour soins/objets/CT, pas de départ de l’île pendant l’épreuve. Place du gardien final par rapport aux quatre combats à préciser (Q05).
- Raids : inspiration Dynamax/Téracristal, PV et résistances augmentés demandés ; pas de friendly fire en raid. Ne pas supposer que les règles officielles augmentent systématiquement les statistiques Défense/Défense Spéciale, ni importer la Téracristallisation ou un déroulement asynchrone sans décision (Q08–Q09).
- Campagne coop réajustable ; un nouveau joueur peut rejoindre mais doit rattraper l’histoire. La séparation de ce rattrapage et de la sauvegarde commune reste à concevoir avant code (Q10).
- Combat coop ordinaire avec absent : proposer attente ou bot. Combat scénaristique : tous présents. Délai de choix 60 secondes, action automatique à expiration ; politique automatique à proposer (Q11–Q12).
- Épreuves de raid non légendaires possibles ; capture individuelle garantie après victoire, légendaires capturables seulement postgame. Refaire le raid tant que la capture n’est pas faite ; répétabilité après capture à décider (Q13).
- Soul-link optionnel, jamais imposé au multijoueur ; caps désactivables et modes chill permis. Régime des options partagé par campagne à préciser, sans transformer désactivation du cap en baisse du palier stocké (Q14).
- Référence combat : Écarlate/Violet avec DLC, exceptions Méga et anciennes attaques. Certaines formes delta auront une Méga, sélection fournie par le propriétaire (Q15).
- IV/EV/natures gratuits dans le résumé dès le départ, uniquement hors combat. Difficulté, shiny, vitesse, audio et commandes modifiables. Distinguer réglages individuels de présentation et paramètres communs de campagne ; vitesse graphique ne doit pas accélérer les tours d’un seul client (Q16).
