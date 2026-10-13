> État courant D73 : havre/sentier et trois zones nouvelles connectées (canopée, sources, poste RR), 22 espèces de fixtures, Showdown intégré et dix blocs de continuation. Les tableaux initiaux décrivent les étapes historiques ; les sections D69–D73 précisent la démo. Graphismes finaux, divinité/raid et île complète à produire.

# État des fonctionnalités

POC graphique isolé du 13 octobre 2026 : [boutique Blender → GLB → Godot](development/poc-boutique/README.md) effectivement produite sans service 3D payant. Source/compatibilité/captures contrôlées ; aucun remplacement dans la démo, finition artistique encore insuffisante pour une validation finale. Les statuts de gameplay ci-dessous restent inchangés.

Les statuts portent sur les preuves, pas sur l’enthousiasme ou la présence dans une roadmap.

| Fonction | État | Preuve ou condition |
|---|---|---|
| Cadrage V0.1 | APPROUVÉ | Confirmation explicite du propriétaire, 11 octobre 2026 ; questions ouvertes conservées |
| Git main/develop | PRÉPARÉ | Branches initialisées ; vérifier push remote |
| Moteur Godot/Blender | LABORATOIRE TESTÉ | Godot 4.6.3, Blender 4.3.2 ; adéquation finale non validée |
| Assets 3D animés | PROTOTYPE ORIGINAL TESTÉ | Mannequin GLB, sept os/une animation ; aucun Pokémon intégré |
| Combat 9G + exceptions | SHOWDOWN INTÉGRÉ ET TESTÉ LOCALEMENT | D56 : simple/double, Méga, attaques/talents/objets/champs via simulateur ; catalogue22/43 après D59, conformité des règles originales à éprouver |
| IA difficile | POLITIQUE SHOWDOWN À VUES LIMITÉES TESTÉE | Poseur → bénéficiaire de talent/type → renouvellement ; coordination double/Abri/risque allié (D61) ; aucun set/choix adverses cachés ; stratégie experte non finalisée |
| Coopération 2/3 | REPORTÉ — ESSAI LOCALHOST CONSERVÉ | Trois processus ENet ; pas d’Internet ni combat réseau |
| Raids phasés/simultanés | DEMANDÉ | R01 ; règles détaillées ouvertes |
| Sauvegardes et migration | SOLO SCHÉMA 5 TESTÉ | Slots/autosave/Pokédex/scènes, lecture v1/v2/v3/v4 et copies originales ; réseau reporté |
| Soul-link | REPORTÉ | D50 : non prioritaire, aucun test Windows acquis |
| Région et scénario | OUVERTURE PROPOSÉE JOUABLE | D61 : village/sentier/épreuve/épilogue persistants FR/EN ; îles et contenu final non approuvés |
| Résumé IV/EV/natures/PC | SOCLE VALIDÉ WINDOWS | lab-2816c71, D48 ; extensions CT/talents/Méga du nouveau lot à retester |
| Actions terrain | LABORATOIRE DÉVELOPPÉ ET TESTÉ | Obstacles/collisions, Surf, Escalade et Vol carte ; déblocages provisoires, Flash sans grotte à tester |
| Wiki joueurs | PRÉPARÉ LOCAL | Rubriques documentaires ; non publié |
| Exports Windows | PORTABLE VALIDÉ JUSQU’À lab-04a2317 | D52 : blocs7–9 et Méga validés ; lots postérieurs à D52 à tester |
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

## Lot D51 — blocs 7 à 9 regroupés

Suite autorisée pendant que le correctif Méga reste à tester. Pokédex provisoire vu/obtenu, filtres et localisations légales ; timeline de caméra/texte manuelle FR/EN et galerie de replay ; trois emplacements solo et autosave distincte, récupération backup, migration5 préservant les originaux1/2/3/4. Développés et testés techniquement, **validation Windows propriétaire attendue**. Correctif Méga inclus.

Pas de scénario final ou animation narrative produits, pas de nouveaux assets, catalogue17 espèces inchangé. Les exigences de reproduction/fossiles/personnalisation/audio/commandes et interactions9G non couvertes demeurent à développer. Nuzlocke/Soul-link/multijoueur reportés. [Portée et preuves](development/LOT_COLLECTION_CINEMA_SAVES.md).

Livraison D51 : [lab-04a2317](https://github.com/DyHyugal/pokemon-archelys/releases/tag/lab-04a2317), CI verte et ZIP publié vérifié. 216 assertions de domaine, 27 contrôles du nouveau parcours et autres scènes du socle réussis. Validation Windows du lot et de la Méga attendue, sans test des modes reportés.

## D52 : validation propriétaire et bloc10

Retour explicite Windows : **Pokédex, cinématique/galerie, emplacements/autosave et Méga validés** sur lab-04a2317. Ne plus présenter leur fonctionnement comme en attente. Leur portée de laboratoire et la validation artistique séparée demeurent.

Bloc10 développé : touches clavier reconfigurables avec refus des conflits et retour Échap permanent ; volumes Général/Musique/Effets réels avec calibration originale ; texte16/20/24 et préférences locales conservées indépendamment de la campagne5. Test technique réalisé, **nouvelle validation Windows attendue**, pas de musique finale ni manette/accessibilité exhaustive. [Rapport](development/LOT_CONFORT.md).

Livraison bloc10 : [lab-d9b3d8d](https://github.com/DyHyugal/pokemon-archelys/releases/tag/lab-d9b3d8d), CI verte/ZIP vérifié.46nouveaux contrôles réussis (21services,25scène), suite antérieure également réussie. Test Windows ciblé du confort attendu ; aucune attente répétée sur les fonctionnalités déjà validées par D52.

## D54 : bloc11 — combat tactique solo

Poursuite autonome autorisée pendant l'indisponibilité du propriétaire. **Bloc10 reste non validé Windows** ; blocs7–9 et Méga restent validés selon D52.

Abri, Surf/Éboulement/Tranch'Herbe et baisses de statistiques de zone, ciblage allié volontaire, Coup d'Main : développés et contrôlés sur le laboratoire. UI FR/EN avec cibles explicites, essai tactique à équipe temporaire, sortie sans modifier la campagne. Catalogue17 espèces/42 attaques, CT légales dans le résumé, campagne5 inchangée. [Portée et preuves](development/LOT_COMBAT_TACTIQUE.md). Pas une conformité exhaustive9G : redirection, choix d'objets en double, IA double avancée et attaques/talents hors catalogue restent à développer. Le rendu, les sons et le fonctionnement Windows des nouveaux blocs attendent un retour ultérieur, sans sollicitation immédiate.

Livraison D54 : [lab-53f5baa](https://github.com/DyHyugal/pokemon-archelys/releases/tag/lab-53f5baa), CI verte/ZIP publié vérifié.62 nouveaux contrôles (46domaine,16scène) et suite précédente réussis. LIRE-MOI commun blocs10–11 conservé pour plus tard. Dernière validation propriétaire toujours D52 ; aucune exigence de test immédiat.

## Étude D55 — base de combat

D55, état historique avant D56 : Showdown **FAISABILITÉ TESTÉE, NON INTÉGRÉ**. 25 sondes du simulateur, 6 contrôles de liaison locale Godot ; suite amont ciblée61 réussis/2 ignorés. Recommandation et conditions MIT dans [l'étude](development/ETUDE_MOTEUR_SHOWDOWN.md). Aucun changement du moteur actuel ou de la release ; Windows avec Node non testé. Tactica consulté en lecture seule, aucun code importé. IA stratégique, adaptations de campagne et format Archélys restent à développer si cette base est adoptée.

## D56 — combat Showdown

**DÉVELOPPÉ ET TESTÉ LOCALEMENT, WINDOWS À VALIDER** : combats Pokémon jouables simples/doubles raccordés au simulateur local, états de campagne et PP préservés, runtime portable, panne avec restauration ; [rapport](development/INTEGRATION_SHOWDOWN.md). Format9G + Méga, catalogue17/42 conservé. IA à vues limitées intégrée, stratégie experte encore incomplète. Ancien moteur seulement en comparaison ; aucun code Tactica importé. Réseau/raids/défis restent reportés.

Livraison D56 : lab-5e8ed1b publiée, CI38168553600 réussie.36 contrôles Node,33 Godot et parcours de scènes réussis. Windows propriétaire toujours à valider ; D52 reste la dernière validation reçue.

## Bloc12 — première partie acquisitions solo

Cadeaux d'œufs/incubation/éclosion : implémentés dans un incubateur de laboratoire séparé de l'équipe. Caractéristiques fixées à la réception selon N40, sauvegarde JSON et anciennes campagnes compatibles, aucune identité dupliquée à l'éclosion.18 assertions spécifiques plus suite complète requise. Reproduction et fossiles **restent à développer**. Validation Windows **attendue**, aucune validation implicite par D57.

Livraison bloc12 première partie : [lab-bd216d3](https://github.com/DyHyugal/pokemon-archelys/releases/tag/lab-bd216d3), CI verte. Preuve : `docs/development/verification/EGGS_2026-10-11.txt`. Le README embarque les tests groupés œufs + Showdown ; EXE toujours `Archelys-Laboratoire.exe`.

## Changement de périmètre D58

**Reproduction / héritages : RETIRÉS**, décision propriétaire du11 octobre2026. Travail local annulé avant commit/livraison ; code du jeu et données identiques à lab-bd216d3. Œufs cadeaux/incubation/éclosion conservés. Fossiles toujours à développer, prochain bloc solo. Les mentions antérieures « reproduction à développer » sont remplacées par cette décision.

## Bloc fossiles D59

**Implémenté et testé localement** : restauration de3 fossiles au Centre, échantillons uniques, coût d'un objet après livraison seulement, destination équipe/PC, origine village et Pokédex, sauvegardes compatibles en lecture, anciennes campagnes sans drapeau acceptées.23 assertions spécifiques et suite complète réussies. Catalogue provisoire22 espèces/43 attaques ; pas de nouveaux modèles. Nuzlocke indisponible pour ce service tant que ses quotas sont reportés. Niveau5/gratuité/distribution d'essai non définitifs. Validation Windows attendue ; D52 reste la dernière validation propriétaire. Reproduction retirée selon D58.

Livraison fossiles : [lab-1830ec4](https://github.com/DyHyugal/pokemon-archelys/releases/tag/lab-1830ec4), CI verte, ZIP et empreintes publiés. Preuve dans `docs/development/verification/FOSSILS_2026-10-11.txt`. README embarqué mis à jour ; même EXE portable. Validation Windows attendue.

## Livraison groupée D61

Combat/IA, parcours solo et maquette d'ouverture : développés et tests locaux réussis. Comparatifs FHD originaux actualisés, sentier ajouté ; direction artistique non validée. Mesure llvmpipe logiciel5,3fps à1920×1080, ne décrit pas un GPU joueur. Preuves et limites : [rapport](development/LOT_AVENTURE_IA_VISUELS.md). Dernière validation owner D52 ; aucun nouveau retour Windows acquis.

## Livraison groupée D62 — personnage, interface, photo

| Fonction | État | Preuve / limite |
|---|---|---|
| Personnage personnalisé | PROTOTYPE ORIGINAL TESTÉ | Peau/haut/pantalon/couleur et forme de cheveux/visage, sélection par campagne ; rig et matériaux réels ; modèle/shops finaux non produits |
| Thèmes d'interface | LOCAL DÉVELOPPÉ ET TESTÉ | Sombre/clair/contraste, menus/dialogues/combat/photo, migration des préférences sans perte des touches/volumes ; aucune certification accessibilité |
| Photo | EXPORT PNG DÉVELOPPÉ ET TESTÉ | Cadrage autour du héros, résolution courante, UI/étiquettes masquées, caméra restaurée ; fichier réellement rendu sous GL Linux |

D61 conservé dans cette version et toujours à valider Windows. D52 reste le dernier retour propriétaire reçu. Rapport : [lot personnage/thèmes/photo](development/LOT_PERSONNAGE_THEMES_PHOTO.md).

## D63 — gestion et préparation des équipes

**Développé et testé localement** : huit boîtes de trente emplacements stables, déplacements et échanges internes, échange direct avec équipe pleine, recherche nom/type/talent FR/EN et UID exact, résumé PC sans retrait, CT/rappel filtrés avec détail et confirmation, ordre d'attaques avec PP. Captures/éclosions/fossiles utilisent le rangement central. Sauvegardes5 anciennes compatibles en lecture ; slot corrompu/ref UID incohérente refusés. Catalogue22/43 inchangé.

31 contrôles domaine/Showdown/capacité et16 contrôles menus/parcours ; suite précédente réussie. PC rendu sous GL Linux et inspecté. Windows à tester avec D61/D62 ; D52 reste la dernière validation reçue. [Rapport](development/LOT_GESTION_EQUIPES.md).

## D64 — lisibilité des combats solo

Messages publics FR/EN, historique paginé sans messages futurs, fiches d'attaques simples/doubles et statut des remplaçants : développés et testés localement :52 contrôles spécifiques,53 sous rendu GL avec export PNG, suite complète réussie. Lecture sans action ni consommation de PP ; choix doubles conservés. Historique temporaire, pas de modification du schéma5 ni de replay sauvegardé. Styles/animations configurables restent à développer ; aucune conformité exhaustive à toutes les traductions Showdown revendiquée. [Portée](development/LOT_LISIBILITE_COMBATS.md). Retour Windows groupé attendu, dernière validation D52.

## D65 — styles, soins et retour au Centre

Lot solo : Défini/Choix, remplacement gratuit orchestré par Showdown, soins du sac ON/OFF et défaite au Centre avec pénalité unique. Champs optionnels campagne5, anciennes sauvegardes compatibles ; aucun nouveau quota de soins ni règle de raid. Développé et testé :29 nouveaux contrôles bridge,44 contrôles domaine/menus/disque,45 sous rendu GL avec PNG ; suite complète réussie. Windows à tester. [Portée et limites](development/LOT_OPTIONS_COMBAT_DEFAITE.md). Animations configurables restent à développer, D52 dernière validation propriétaire.

## D66 — première île proposée, douze blocs

B01–B12 développés : chapitre persistant, huit zones dont intérieurs, collisions/chemins, dialogues FR/EN et arrivée, rencontres/Dex par biomes, quatre combats Showdown, relais, quête botaniste, caches, services/défaite locale, carte/Vol et guidance, libération/replay. **Proposition jouable**, pas première île finale ni validation graphique. 103 contrôles domaine/chemins,46 contrôles scène et suite complète réussis ;51 sous GL avec cinq captures. Preuve de publication dans [le rapport](development/LOT_PREMIERE_ILE_12_BLOCS.md). Dernier retour Windows D52 ; nouveau parcours à tester. Réseau/raids/défis reportés ; reproduction retirée.

## D67 — dix blocs supplémentaires

| Bloc | État de livraison | Limite |
|---|---|---|
| Atlas six îles + Æther /28sites | PROPOSITION INTÉGRÉE | Noms descriptifs et premiers lieux habités, pas carte finale |
| Studio3D isolé | MAQUETTES PROCÉDURALES TESTABLES | Pas28zones jouables, aucun déblocage en campagne |
| Boutique vêtements | PALETTES D'ESSAI | Haut/pantalon100₽ au havre ; modèles finalisés ultérieurs |
| Donneur d'œuf | PNJ PHYSIQUE | Cadeau Carapuce unique commun à l'incubateur existant |
| Commerce quantités | UI AVEC CONFIRMATION | Refus atomique, pas catalogue/économie finaux |
| Fenêtre/FHD/FPS/vsync | PRÉFÉRENCES PC | Résolution d'affichage, pas mesure de fluidité Windows |
| Manette standard | ROUTAGE INTÉGRÉ | A/B/Start/X/Y et stick/croix ; manette physique à tester |
| Effets combat optionnels | TRANSITION UI | Ne remplace pas modèles/animations d'attaques |
| Lisibilité/mouvements réduits | PRÉFÉRENCES INTÉGRÉES | Repères3D, caméra/décors, dialogue adapté aux dimensions |
| Coupe/Éclate-Roc/Force île | OBSTACLES NARRATIFS | Trois fixtures persistantes sans Pokémon compatible |

Concepts : docs/design/ATLAS_PROPOSE_2026-10-12.md, sept PNG avec source/empreintes. Vérification du lot : docs/development/LOT_ATLAS_SERVICES_10_BLOCS.md et dossier verification. Tests techniques distincts de la validation propriétaire ; D52 reste le dernier retour Windows acquis.

## D68 — kit graphique et visites

| Fonction | État | Preuve / limite |
|---|---|---|
| Sept concepts des régions D67 | APPROUVÉS OWNER | D68 explicite |
| Kit Blender21GLB | GÉNÉRÉ ET INTÉGRÉ | Sept maisons/sept repères/six props/un avatar, source .blend et empreintes |
| Héros et PNJ | PROTOTYPES ANIMÉS INTÉGRÉS | Sept os, marche, visage/cheveux/vêtements/sac ; personnalisation sauvegardée conservée |
|28visites à pied | PROTOTYPE GRAPHIQUE | Six îles+Æther depuis Atlas, déplacement/collision indépendants de campagne |
| Havre / laboratoire | MODÈLES AMÉLIORÉS | Maisons, volcans et PNJ remplacés ; gameplay/progression conservés |
| Fidélité artistique / Windows | À VALIDER EN JEU | Illustrations approuvées, modèle3D encore prototype ; aucun test owner supplémentaire déduit |

Documentation : docs/design/ASSETS_3D_D68.md et docs/development/LOT_ASSETS_VISITES.md. Les îles de campagne complètes, intérieurs des nouvelles régions et assets Pokémon/combats animés restent à construire.


## D69 — démo intégrée et cible DS en FHD

Demande owner du 12 octobre 2026 : monde, graphismes et services réunis dans une démo jouable d'une portion de la première île. Référence graphique : personnages Pokémon DS/USUL, décor net en FHD, concepts D67 approuvés. Autonomie autorisée, propositions à ajuster après playtest ; aucune validation visuelle implicite.


Voir [LOT_DEMO_HAVRE](development/LOT_DEMO_HAVRE.md). Développé et contrôlé techniquement, retour Windows/visuel attendu. Noms, starters, équilibrage et rendu restent provisoires ; cible graphique demandée pas encore atteinte.


## D70 — Meshy choisi pour essai, poursuite des blocs solo

Propriétaire, 12 octobre 2026 : « Meshy Pro pendant un mois […] Continue sur les autres blocs en autonomie ». Les assets D69 sont rejetés comme qualité finale ; concepts D67/D68 conservés. Essai Meshy choisi, modèle exporté/textures pas encore fournis. Aucun asset payant généré ou importé dans ce lot.

Journal, carte locale, trois parties de démo et continuité des portes/interactions développés et testés localement. [Portée, sauvegardes et limites](development/LOT_EXPLORATION_SAUVES_DEMO.md). Playtest Windows et validation visuelle distincts ; multi/raids/défis reportés, reproduction retirée.


## D71 — dix blocs autonomes, sélection Pokémon attendue

Propriétaire : « idéalement 10 […] en autonomie […] pokédex et starters demain », 12 octobre 2026. Autorise la poursuite des systèmes solo avec fixtures ; aucune sélection finale implicite. Dix blocs développés et contrôlés : [portée et limites](development/LOT_DEMO_DIX_SYSTEMES.md). Graphismes de maquette conservés, rejetés comme rendu final ; registre d’assets vide. Pokédex/starters futurs restent à recevoir. Aucun playtest Windows supplémentaire déduit.


## D72 — lot autonome de douze blocs

Propriétaire, 12 octobre 2026 : « enchaine sur les 10/20 prochains blocs […] 20 […] jouable ». Poursuite solo autonome avec fixtures, sans figer Pokédex, starters ni modèles Meshy attendus. Douze blocs intégrés : expédition, actions contextuelles, Vol, services locaux, Pokédex de démo, scènes/replay, autosave séparée, archives portables, diagnostic des sauvegardes, inspection GLB, préflight de contenu et lisibilité du combat. [Portée et limites](development/LOT_DEMO_PROGRESSION_SERVICES.md). Développé/testé techniquement ; playtest Windows et choix artistiques restent distincts.

Livraison D72 : source `a732c7c`, CI [38307537252](https://github.com/DyHyugal/pokemon-archelys/actions/runs/38307537252) réussie, ZIP `lab-a732c7c` publié. [Vérification et test groupé](development/VERIFICATION_D72.md). Retour Windows/visuel propriétaire toujours attendu ; aucun lot suivant validé implicitement.


## D73 — dix blocs de prolongement

Owner : « Ok enchaine sur les 10 prochjains blocs », 12 octobre 2026. Poursuite autonome du solo avec fixtures. Canopée/sources/poste secondaire, contrôle RR, relais, championne climat, responsables au palier commun, Surf, camp, rencontres/habitats, carte/guidage et scènes/reprise : [lot détaillé](development/LOT_DEMO_CANOPY_DIX_BLOCS.md). Développé/testé techniquement, pas de validation Windows/graphique déduite. Pokédex/starters et Meshy toujours attendus ; noms/équilibrage/récit proposés, divinité et libération de l’île non implémentées par ce lot.

Livraison D73 : source `8da0f6f`, CI [38313303857](https://github.com/DyHyugal/pokemon-archelys/actions/runs/38313303857) réussie, ZIP `lab-8da0f6f` publié. [Preuves et reprise](development/VERIFICATION_D73.md). Aucun nouveau retour Windows/graphique owner déduit.
