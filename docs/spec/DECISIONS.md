# Registre des décisions

Complément du 13 octobre 2026 : le propriétaire autorise un POC pratique **Codex/Blender sans API 3D payante**, isolé, avec source, GLB, plusieurs vues et import Godot ; aucun remplacement d'asset/scène/gameplay et aucune fusion main sans validation. [Livraison et bilan](../development/poc-boutique/README.md). Cette demande ne valide ni sa finition artistique ni l'abandon de Tripo/Meshy.

Complément graphique après D73 : le propriétaire demande explicitement les références « une asset à chaque fois ». [35 modèles maîtres en images individuelles](../design/ASSETS_ISOLES_PREMIERE_ILE.md) préparés avec prompts et catalogue ; aucune validation de modèles 3D, avatar, rendu en jeu ou détails architecturaux déduite de cette demande.

Complément après D73 : le propriétaire demande un fichier Excel de prompts pour chaque asset prévisible de la première île, avec zone, déclinaison, prompt et commentaire. [Catalogue préparatoire](../design/PROMPTS_PREMIERE_ILE.md) : ne vaut ni validation de nouvelles tenues/designs ni production de modèles. Pokédex/starters/divinité toujours à recevoir.

Décisions explicites transcrites ; le cahier V0.1 a été approuvé le 11 octobre 2026. Les exemples de noms et d’espèces ne valent pas choix définitif.

| ID | Décision | Provenance |
|---|---|---|
| D01 | Nom de travail Pokémon Archélys ; dépôt public distinct créé | Conversation du 11 octobre 2026 |
| D02 | Archipel distinct, nouvelle histoire et nouveau casting | A1, C04, F2 |
| D03 | Solo et coop jusqu’à 3 dès V1 ; solo testable séparément | C01, L2 |
| D04 | Campagne hébergée et copies invités de secours ; pas de transformation automatique en solo | C08, R07 |
| D05 | Exploration libre, étapes du scénario attendent tout le groupe | R06, R08 |
| D06 | Déconnexion pendant combat = abandon et état avant combat | R08 |
| D07 | Base 9G, Méga uniquement ; attaques absentes à réintroduire et auditer | C17 |
| D08 | Caps communs non décroissants ; comportements Tactica à porter et tester | C18 |
| D09 | Boss : phases et format simultané, jusqu’à 3 joueurs | R01 |
| D10 | Environ 500 entrées hors Méga ; 9 Fakemons envisagés, 50–100 créations avec deltas | C19 |
| D11 | Légendaires capturables seulement postgame, par chaque joueur | C20 |
| D12 | Édition IV/EV/natures dans le résumé, EXP optionnelle et Œuf Chance initial | C27 |
| D13 | Actions terrain contextuelles, Vol depuis carte | C32 |
| D14 | Windows ZIP/exe ; PC fourni est une machine de test, pas le minimum requis | R02, C24 |
| D15 | Prototypes réinitialisables ; alpha publique avec migration et backup expliqués | R03–R05 |
| D16 | Branches main/develop et branche temporaire isolée, validées | C29 |
| D17 | Cahier approuvé avant développement, essais techniques/visuels approuvés séparément | C30 |
| D18 | Rendu stylisé 3D, proportions USUL, caméra contrôlée moyenne | C21 |
| D19 | Français et anglais complets V1 ; ports autres non datés | C25 |
| D20 | Nuzlocke solo et Soul-link coop ; restauration libre | C28 |
| D21 | Cahier des charges V0.1 approuvé ; questions explicitement ouvertes non tranchées | Conversation du 11 octobre 2026 : « je confirme le cahier des charges » |

Recommandations non assimilées à une approbation : neige 9G, première approche LAN/direct, nombre final d’îles, disposition des boss, version Godot, licence du code, synchronisation automatique du wiki. Elles attendent étude ou arbitrage.

## Complément Q — décisions explicites

| ID | Décision | Provenance |
|---|---|---|
| D22 | Six îles thématiques plus site Æther ; départ tropical, ordre confié pour proposition | Q01 |
| D23 | Îles draconique et céleste hors occupation ; résistance draconique empêche occupation durable | Q02 |
| D24 | Silver antagoniste Rocket ; casting et scénario complets à proposer | Q03–Q04 |
| D25 | Boss/champion par biome ; arène et défi minimum par île ordinaire ; quatre combats divins sans quitter l’île | Q05 |
| D26 | Cinématiques non passables, scènes secondaires passables | Q06 |
| D27 | Formats raid fixes par île, répartition équilibrée ; PV/résistances renforcés ; pas de friendly fire | Q07–Q09 |
| D28 | Campagne réajustable, nouveaux membres autorisés avec rattrapage | Q10 |
| D29 | Attente ou bot pour combat non scénaristique ; délai 60 s puis action automatique | Q11–Q12 |
| D30 | Captures raid individuelles garanties, raids rejouables avant capture | Q13 |
| D31 | Soul-link et caps facultatifs, aventure chill permise | Q14 |
| D32 | Référence Écarlate/Violet DLC ; deltas Méga selon future liste owner | Q15 |
| D33 | Édition IV/EV/natures gratuite initialement, hors combat ; options modifiables | Q16 |

Ces décisions n’approuvent pas encore les noms d’îles, nouveaux dirigeants, scénario proposé, formule des résistances ni les règles Soul-link détaillées.

## Autorisation de la session technique

| ID | Décision | Provenance |
|---|---|---|
| D34 | Autorisation de commencer la conception et les essais techniques en autonomie, préparer questionnaire complet et plan de développement | Conversation du 11 octobre 2026 |

## Retour propriétaire et priorité solo — 11 octobre 2026

| ID | Décision | Provenance |
|---|---|---|
| D35 | Laboratoire `lab-09897ca` : lancement Windows, déplacement, fluidité, sauvegarde et combat factice confirmés OK ; multijoueur non testé | Retour explicite dans la conversation |
| D36 | Construire le jeu en solo d’abord ; reporter connexion, sauvegardes et autres travaux multijoueurs, tout en gardant une architecture adaptable | Conversation : « construction du jeu en solo d’abord […] adaptation en multi après » |
| D37 | Rapprocher la caméra du laboratoire ; rendu final toujours à valider séparément | Retour explicite : caméra encore un peu loin |

D36 change l’ordre de réalisation. La coopération demeure un objectif demandé ; sa date et son inclusion au jalon V1 seront réévaluées, sans prétendre qu’elle est déjà fonctionnelle ou la supprimer du périmètre silencieusement. Le propriétaire remplit le questionnaire complémentaire pendant la poursuite des systèmes solo indépendants des arbitrages.

## Distribution Windows — retour sur le blocage d’exécution

| ID | Décision | Provenance |
|---|---|---|
| D38 | Garder le nom de l’exécutable identique entre versions ; version dans le LIRE-MOI | Demande explicite du propriétaire |
| D39 | Mettre les changements et tests précis attendus dans le LIRE-MOI de chaque ZIP pour éviter de devoir les demander dans le chat | Demande explicite du propriétaire |
| D40 | Signature Windows demandée ; aucun certificat de signature/service disponible ici, build toujours non signé | Demande propriétaire et constat de l’environnement ; résolution en attente de moyens de signature |

Le nom était déjà fixe sur les premiers ZIP : `Archelys-Laboratoire.exe`, conservé. Les tags de releases identifient les versions, pas le nom du fichier. Un certificat auto-signé ne résout pas la confiance Windows ; un SHA256 n’est pas une signature Authenticode. Même un certificat reconnu ne garantit pas l’absence de SmartScreen. Le nouveau retour indique un blocage Windows sur la suite solo : cette exécution reste non validée.

## Essai de distribution gratuite

| ID | Décision | Provenance |
|---|---|---|
| D41 | Essayer une distribution gratuite non signée pour la version de test, avec retour du propriétaire sur le lancement | Conversation : « essayons la distribution gratuite pour la version de test » |

Choix technique pour cet essai : moteur officiel Godot non modifié et données de jeu dans un PCK séparé. Ce conditionnement ne signe pas le moteur et ne garantit pas une autorisation du Contrôle intelligent. Nom EXE fixe et LIRE-MOI par version conservés ; aucune modification des protections Windows demandée pour mesurer le résultat.

## Validation portable et cadence de développement

| ID | Décision | Provenance |
|---|---|---|
| D42 | Variante portable lab-477caad confirmée Windows : pas d’avertissement, dialogue FR/EN, save, duel/reset et fluidité OK | Retour explicite du propriétaire |
| D43 | Corriger la persistance de langue signalée ; poursuivre par lots de plusieurs fonctionnalités avec playtests moins fréquents | Demande explicite du propriétaire |

D42 est un constat sur son PC, pas une garantie sur tous les PC. Le moteur non modifié est conservé. Prochain lot solo : préférences persistantes, interactions panneau/caisse, sac de test et journal sauvegardé ; ce contenu technique ne valide aucun scénario ou catalogue final. Les contrôles automatisés restent réalisés à chaque lot, les demandes de retour owner sont regroupées.

## Validation du lot solo et menus demandés

| ID | Décision | Provenance |
|---|---|---|
| D44 | Lot lab-e84ee99 validé par le propriétaire : tout OK, sauf absence d'écran Sac pour consulter le jeton | Conversation du 11 octobre 2026 |
| D45 | Ajouter le menu Sac et garder une option de distance caméra dans Paramètres ; poursuivre le bloc suivant | Demande explicite du propriétaire |

Bloc technique retenu : Pause, Sac, Journal et Paramètres avec accès sauvegarde/chargement. Il présente les systèmes déjà éprouvés ; ni catalogue final, ni scénario, ni rendu artistique approuvés par cette validation.

## Lot solo regroupé

| ID | Décision | Provenance |
|---|---|---|
| D46 | lab-d33e5ee validé : ergonomie parfaite et fonctionnement correct | Retour explicite propriétaire du 11 octobre 2026 |
| D47 | Réunir les blocs 1 (équipe/PC), 2 (combat solo), 3 (rencontres/capture/progression), commencer et demander un seul playtest après l'ensemble | Demande explicite propriétaire |

Le petit catalogue et l'équipe fournie sont des données techniques provisoires, pas une décision sur les starters, le Pokédex final ou les assets. Le lot cible une boucle complète sur ce catalogue ; la conformité exhaustive 9G et la production graphique restent des chantiers suivis séparément, sans prétendre terminés.

## Validation du lot solo et réponses complémentaires

D48 : le propriétaire confirme lab-2816c71 entièrement fonctionnel. D49 : développer ensemble les blocs 4–6 (vie quotidienne/exploration, difficulté/règles avancées, quartier graphique représentatif). Provenance : conversation du 11 octobre 2026.

Les [réponses N01–N51](REPONSES_N01_N51.md) sont transcrites et font autorité sur leurs sujets. Notamment : pêche pour la démo ; 1G permise comme catalogue provisoire ; Méga existantes pour tests ; caps normal par défaut, OFF sans plafond et retour au cap sans réduire les niveaux existants ; défi désactivable sans réactivation ; KO équipe+PC définit le game over ; images comparatives avant validation puis intégration du style validé. La distribution portable actuelle doit rester inchangée. Les fonctionnalités multijoueurs décidées restent reportées selon la priorité solo.

Exécution technique de D49 : lot livré `lab-58819aa`, systèmes/services et règles de laboratoire développés,184assertions/CI/rendu PCK réussis. Pas d'approbation artistique implicite ; reprise du défi N35 et raids ouverts reportés ; doubles mono-cible à étendre. Rapport dans `docs/development/LOT_EXPLORATION_REGLES_VISUELS.md`. Les noms et divinités proposés ne sont pas des décisions.

## Retour Windows sur lab-58819aa

D50 — propriétaire : tout le reste fonctionne, notamment les CS ; accès Méga absent même avec kit, correction requise. Nuzlocke/Soul-link non testés et reportés, non prioritaires : aucun nouveau développement ou playtest de ces modes demandé maintenant. Thème/type de ville apprécié ; rendu graphique à retravailler, aucune variante A/B/C ni asset final approuvé. Provenance : retour et capture du 11 octobre 2026.

Correction technique : kit équipe aussi les individus compatibles déjà possédés, conserve leur identité/niveau/PV/PP et remet l'objet précédent au sac ; kit répété ne duplique plus les espèces déjà présentes. Case Méga visible en simple/double avec raison d'indisponibilité. Format de sauvegarde4 et moteur portable inchangés.

## D51 — continuer les lots solo pendant le test Méga

Provenance : conversation du 11 octobre 2026, « ok je teste ça après mais continue les blocs stp ». Le test propriétaire de la Méga reste attendu ; il ne bloque pas les systèmes indépendants. Lot technique suivant regroupé : Pokédex et localisations, cinématiques/galerie, emplacements solo/autosauvegarde. Il réutilise les exigences C25/J5/K5/Q06 et la cadence D43, sans choix implicite du Pokédex final ni validation artistique. Ordre de réalisation choisi techniquement dans le périmètre déjà demandé, pas nouvelle règle de game design. Nuzlocke/Soul-link et réseau restent reportés conformément à D50/D36.

La timeline de laboratoire sert uniquement à vérifier cadrages, avance manuelle, passage des scènes secondaires et replay des cinématiques terminées. Elle n'approuve ni le scénario final ni le casting. Le format5 ajoute l'historique vu/obtenu et des scènes ; lecture1/2/3/4 et conservation des originaux lors des écritures migrées. Trois slots et intervalle autosave60s sont des valeurs d'essai configurables/à éprouver, pas un engagement sur toutes les plateformes.

## D52 — validation Windows du lot D51 et de la Méga

Provenance : conversation du 11 octobre 2026, « ok je valide le fonctionnement des 3 implémentations et de la mega, continue sur le prochain bloc stp ». Pokédex de laboratoire, cinématique/galerie, slots/autosave de lab-04a2317 et parcours Méga sont validés fonctionnellement par le propriétaire. Cette validation ne sélectionne pas le Pokédex final ni de nouveaux assets artistiques. Nuzlocke/Soul-link et réseau restent reportés.

## D53 — prochain bloc solo : réglages de confort

Suite technique dans les exigences déjà demandées K5/L3/Q16 : commandes clavier personnalisables, volumes Général/Musique/Effets avec sons de calibration originaux, taille des textes. Préférences individuelles séparées de la campagne, conservées au chargement et entre sessions. Échap reste un retour permanent, Entrée/Espace des confirmations permanentes, F3 réservé au laboratoire ; conflits de touches entre commandes refusés. Valeurs de laboratoire à éprouver, pas une validation exhaustive d'accessibilité ou de contrôle manette. Format de campagne5 inchangé, aucun travail réseau ni nouvelle règle narrative.

## D54 — poursuite autonome sans nouveau retour Windows

Provenance : conversation du 11 octobre 2026, « pour l'instant je peux pas tester donc avance en autonomie sur les blocs ». Bloc10 confort livré mais toujours **à tester par le propriétaire** ; D52 reste la dernière validation Windows reçue. Continuer les systèmes solo du cahier, sans solliciter d'interaction ni développer Nuzlocke/Soul-link/réseau.

Lot technique suivant (bloc11, trois sous-blocs regroupés) : protection temporaire Abri en simple/double ; attaques de zone et ciblage allié en double ; Coup d'Main et interface de test isolée. Référence N27/Q15 : règles officielles, pas nouvelles règles produit. Catalogue de laboratoire17 espèces,42 attaques, paramètres issus des CSV PokéAPI déjà épinglés. Les cibles et comportements sont confrontés à Poképédia. Format de campagne5 inchangé, états de combat jamais sérialisés. Aucun choix du Pokédex final ni nouvelle île/art/scénario. L'essai tactique utilise une aventure séparée pour éviter de remplacer l'équipe ou dépenser les ressources du propriétaire.

## D55 — étude Showdown et comparaison Tactica

Provenance : demande propriétaire du 11 octobre 2026 d'étudier une base solide pour éviter de recoder chaque interaction, puis question sur les conditions de licence. Étude et sondes hors jeu autorisées ; **aucune adoption définitive du nouveau moteur déduite de cette demande**. Showdown MIT permet utilisation/modification/redistribution en conservant copyright et licence ; droits sur assets/marques distincts. Recommandation technique : Showdown pour les combats, Godot pour l'aventure, Tactica comme référence des règles/données après vérification de provenance. 25 sondes et 6 contrôles Godot réussis, tests amont ciblés61 réussis/2 ignorés. Aucun code Tactica importé ; jeu et release inchangés. Rapport : `docs/development/ETUDE_MOTEUR_SHOWDOWN.md`. D52 reste la dernière validation Windows ; D53/D54 attendent toujours ce retour.

## D56 — intégration Showdown approuvée

Provenance : demande explicite du propriétaire, « procède à l'intégration de showdown pour la partie combat et intéraction des attaques etc.. »,11 octobre2026. Adopter Showdown pour les combats Pokémon et interactions, conserver Godot pour aventure/présentation et les règles de campagne. D55 n'est plus un choix moteur ouvert. Pas de portage de code Tactica, pas de nouveau périmètre réseau/raids/défis/catalogue final. Runtime local portable et notices obligatoires ; sauvegardes5 préservées. Un lot de test Windows groupé avec même nom d'EXE et consignes embarquées. Rapport d'implémentation : `docs/development/INTEGRATION_SHOWDOWN.md`. Cette autorisation ne constitue pas encore une validation Windows de l'intégration.

## D57 — continuation des blocs solo

Provenance : demande propriétaire « ok je te laisse continuer sur les blocs alors »,11 octobre2026. Poursuite autorisée ; aucune nouvelle validation Windows déduite. D52 reste la dernière validation reçue. Bloc12 acquisitions, première partie : cadeaux d'œufs, incubation par déplacement et éclosion, sauvegarde comprise. N40 impose de fixer les caractéristiques à la création de l'œuf.

Paramètres purement techniques de laboratoire : trois cadeaux uniques (starters1G déjà autorisés comme fixtures), incubateur séparé de l'équipe,20m de marche et éclosion confirmée dans le menu. Aucun choix des starters finaux, distribution narrative ou durée officielle. La reproduction, héritages/compatibilités et restauration des fossiles ne sont pas implémentés dans cette partie. Nuzlocke/Soul-link et réseau restent reportés.

## D58 — suppression du bloc reproduction

Provenance : demande explicite du propriétaire,11 octobre2026 : « la reproduction n'a pas d'intéret puisse que les IV, le shiny et les capacités sont gérables […] retire ce bloc de repro ». La reproduction et ses héritages sont retirés du périmètre et de la roadmap, en remplacement de la demande antérieure sur ce sujet. Le travail local commencé n'a pas été livré et est annulé : aucun système de parents, sexe, groupes d'œufs, héritage IV/talents/attaques ni nouveaux cadeaux de parents intégré.

Le bloc déjà livré des œufs cadeaux/incubation/éclosion est conservé ; cette décision ne le retire pas. Les fossiles restent le prochain bloc d'acquisitions. Aucun nouveau retour de validation Windows déduit de cette décision.

## D59 — bloc fossiles autorisé

Provenance : demande du propriétaire « ok fais le bloc sur les fossiles alors »,11 octobre2026. Restauration solo intégrée au Centre du village de laboratoire. Essai provisoire : trois échantillons reçus une fois, Fossile Nautile/Amonita, Fossile Dôme/Kabuto, Vieil Ambre/Ptéra ; niveau5 et service gratuit pour tester les transactions, pas lieu/prix/niveau/distribution finaux. Équipe prioritaire puis PC ; aucun objet consommé si l'acquisition échoue. Caractéristiques tirées au moment de la restauration ; origine village conservée dans le Pokémon et Pokédex mis à jour seulement après réception.

Catalogue technique étendu à22 espèces/43 attaques (Amonita/Amonistar, Kabuto/Kabutops, Ptéra et Roulade), depuis le même snapshot PokéAPI épinglé ; évolutions niveau40. Aucun asset officiel importé, pas choix du Pokédex final. Les quotas N31 ne sont pas implémentés maintenant : service refusé en Nuzlocke actif, conformément au report des défis. Reproduction toujours retirée selon D58. Anciennes campagnes lisibles avec drapeau d'échantillons absent considéré faux ; sauvegarde5 inchangée. Les anciennes versions du jeu ne doivent pas être utilisées pour relire une nouvelle campagne contenant les nouvelles espèces. Tests techniques distincts du retour Windows encore attendu.

## D60 — augmenter la taille des lots

Provenance : demande propriétaire du11 octobre2026 : « c'est quoi les prochains bloc ? essaye de les faire un peu plus conséquent ». Regrouper les prochains travaux en livraisons comportant plusieurs sous-chantiers et un seul parcours owner par lot. Ce retour ne valide pas Windows les fossiles ni les propositions artistiques/narratives. Le découpage ci-dessous est une proposition technique de suite, pas l'autorisation de produire les îles ou de choisir le catalogue final.

## D61 — les quatre lots en autonomie

Provenance : propriétaire, « ok alors enchaine ses 4 blocs en autonomie stp »,11 octobre2026. Réaliser ensemble combat/IA, aventure continue, référence graphique FHD et préparation de l'ouverture. Une seule livraison et un parcours owner. Cette autorisation ne choisit pas une variante graphique, des espèces définitives ou les propositions narratives encore ouvertes. Le quatrième lot est donc une **ouverture jouable proposée**, pas une première île de production approuvée. D52 reste le dernier retour Windows de validation.

Exécution : politique IA coordonnée en double (poseurs, dégâts alliés, Abri/soutien), présentation des champs ; village→sentier→épreuve→épilogue avec journal, cinématiques FR/EN, fournitures et récompense uniques, sauvegarde. Comparatifs procéduraux FHD enrichis, avatar original conservé ; dialogues Vyna explicitement proposés. Catalogue22/43 et Showdown épinglés inchangés. Format5 conserve la lecture des campagnes sans état d'aventure ; sauvegardes originales préservées. Reproduction retirée, multi/raids/défis reportés. Voir LOT_AVENTURE_IA_VISUELS.md pour preuves et limites.

## D62 — continuation autonome avant le playtest de demain

Provenance : propriétaire, « ok continue sur les prochains blocs, je test demain matin »,11 octobre2026. Continuer les exigences solo déjà retenues sans attendre un retour Windows sur D61. Cela n'est ni une validation de lab-484ec66 ni une sélection graphique/narrative. D52 reste la dernière validation fonctionnelle Windows reçue.

Lot technique choisi dans C21–C23/L3/N46 et K5/N26 : personnalisation persistante du mannequin (peau/vêtements/coiffure/visage d'essai), thèmes d'interface locaux et mode photo PNG. La photo, prévue V1 non prioritaire, est réalisable ici sans chantier d'assets final ; production des îles et nouveaux contenus Pokémon demeurent en attente. Les palettes/formes sont des fixtures, pas le choix du héros, des vêtements finaux ou des boutiques. Apparence gratuite de laboratoire, pas économie définitive. Nuzlocke/Soul-link/multi/raids reportés ; reproduction retirée.

L'apparence appartient à la campagne ; thème et lisibilité appartiennent aux préférences locales. Sauvegarde5 avec champ optionnel `appearance` ; ancienne campagne sans champ reçoit le mannequin initial. Mode photo solo hors combat/dialogue/cinématique, verrouillage mouvement/interactions/changement de campagne, caméra restaurée à la sortie. PNG à la résolution courante, sans UI/étiquettes3D, fichiers distincts sans écrasement. Les décors animés continuent : aucun gel de la simulation de combat ni sauvegarde de photo dans la campagne.

## D63 — un gros bloc solo de préparation et gestion des équipes

Provenance : propriétaire, « ok top enchaine sur un gros bloc »,11 octobre2026. Continuation dans le périmètre PC/résumé/préparation du cahier, sans validation Windows de D61/D62 implicite. Lot : huit boîtes stables de trente emplacements correspondant à la capacité240 existante, déplacements/échanges équipe-PC sans perte d'individu, recherche multilingue, résumé depuis le PC, sélecteur CT/rappel avec détail et confirmation, ordre des attaques conservant leurs PP. Aucun système de relâchement ni suppression de Pokémon ajouté.

L'ordre de l'équipe et les données des individus restent séparés des emplacements ; `storage_slots` optionnel dans campagne5, anciennes sauvegardes reconstruites selon l'ordre de leur PC. Validation des UID/emplacements/unicité avant restauration. Captures, fossiles et éclosions réutilisent l'acquisition centrale et le premier emplacement libre. Dernier Pokémon apte protégé lors des transferts. Même coût/règles de CT/rappel/édition gratuits au laboratoire ; pas nouveau tarif final. Catalogue22/43 inchangé, aucun asset final ajouté. Multi/raids/défis reportés, reproduction retirée ; D52 dernier retour Windows validé.

## D64 — poursuivre les prochains blocs en autonomie

Provenance : propriétaire, « ok top continue en autonomie sur les prochains blocs »,11 octobre2026. Poursuivre le solo sans attendre le playtest des lots précédents. Ce retour ne vaut pas validation de leurs builds. Lot technique de présentation des combats : messages publics Showdown FR/EN, historique temporaire des messages déjà présentés, fiches des attaques et lisibilité des remplacements/choix doubles. Aucun calcul combat réimplémenté ni règle de difficulté/style de combat tranchée en silence.

Textes toujours manuels, clavier répété refusé ; historique sans avance du tour, sans messages futurs et sans suppression des choix alliés déjà verrouillés. Historique et affichage des fiches limités à la session, non enregistrés dans la campagne5 ; ancienne sauvegarde inchangée. Catalogue22/43, runtime et sources épinglés inchangés. Production artistique/îles toujours en attente ; multi/raids/défis reportés et reproduction retirée. D52 reste le dernier retour fonctionnel Windows reçu.

## D65 — lot regroupé options de combat et défaite

Provenance : propriétaire, « ok top, continue sur le prochain bloc alors, regroupe plusieurs points à aborder du cahier des charges »,12 octobre2026, Europe/Paris. Réaliser ensemble les styles classiques Défini/Choix, les soins du sac configurables demandés en I5 et le parcours de défaite au Centre demandé en K4/C28. Cela ne valide pas Windows D61–D64 ni leur direction artistique.

Choix limité aux KO adverses de dresseurs simples avec réserve apte et joueur non KO ; ennemi annoncé choisi avant la réponse, changement gratuit via requêtes de remplacement Showdown. Défini par défaut pour garder le comportement existant. Soins ON/OFF du sac en combat, autorisés par défaut ; pas quota chiffré inventé, aucun blocage des Centres, captures, soins hors combat ou objets tenus. Campagne5 avec champs optionnels validés, anciennes saves compatibles. Défaite au Centre après lecture manuelle, pénalité de laboratoire100₽ plafonnée centralisée une seule fois. Essais isolés de la campagne. Multi/raids/défis reportés, reproduction retirée ; animations et contenu définitif restent distincts.

## D66 — au moins dix blocs et première île proposée en autonomie

Provenance : propriétaire,12 octobre2026 : « objectif faire au moins 10 blocs […] base toi sur des prototypes/propositions […] construire la première ile comme tu l'entend […] retours pour qu'on adapte ». Autorisation explicite de construire la première île en maquette jouable sans attendre validation visuelle/utilisateur. Elle remplace le blocage précédent sur cette proposition, sans approuver ses assets, noms, lore ou équilibrage final. Ne pas attendre le réveil pour la vérification technique et la livraison groupée.

Douze blocs B01–B12 dans LOT_PREMIERE_ILE_12_BLOCS.md : chapitre/sauvegarde, zones, collisions, dialogues/arrivée, biomes/Dex, combats, relais, quête, caches, services/défaite, carte/Vol/objectifs, libération/replay. Catalogue22/43 et moteur Showdown conservés. Havre/jungle/volcan/galerie/sanctuaire/poste RR sont des noms de travail. Cadeau Pikachu8, caps14/18/22,300₽/victoire et objets d'essai sont provisoires ; admins au même cap22, non décroissant. Party/save existantes conservées, nouvel emplacement conseillé pour équilibrage. Multi/raids/défis reportés, reproduction retirée ; dernière validation Windows D52.

## D67 — dix blocs solo et propositions graphiques dans le chat

Provenance : propriétaire,12 octobre2026 : « ok enchaine sur 10 blocs et fais moi les propositions graphique directement dans ce chat pour chaque ile/ville/repère ». Continuer sur le même checkout/branche, en une livraison groupée, sans sollicitation intermédiaire. Sept planches de quatre vues proposées couvrent six îles plus ancien Æther : panorama, deux premières propositions de lieux habités, repère. Aucun choix de noms, style final ou inventaire complet de villes implicitement approuvé.

Blocs : atlas proposé28sites ; studio3D isolé ; boutique de palettes vêtements ; PNJ d'œuf cadeau ; quantités/confirmation du commerce ; affichage local fenêtre/FHD/FPS/vsync ; manette standard ; transitions de textes combat optionnelles ; repères/mouvements réduits et dialogue responsive ; obstacles contextuels persistants de première île. Boutique au havre100₽ et cadeau Carapuce réutilisent les fixtures : pas choix d'économie/distribution finale. Évolution campagne5 additive `island.cleared`, anciennes campagnes lisibles. Préférences PC distinctes des campagnes.

Images générées de conception conservées dans le dépôt/ZIP avec provenance, distinctes des maquettes primitives du laboratoire. Aucun asset officiel importé. Textes combat toujours manuels ; transitions UI ne valent pas animations d'attaques finales. Manette physique, performances GPU et rendu Windows attendent le retour owner. Multi/raids/défis toujours reportés, reproduction retirée ; D52 dernier playtest Windows validé.

## D68 — concepts approuvés, génération et intégration des assets3D

Provenance : propriétaire,12 octobre2026 : « je valide les concepts graphiques […] génère les assets et intègre […] bâtiments, pnj et personnage principal ressemble à du pokémon […] prototype pour les avatars […] visiter toutes les iles ». Les sept planches D67 sont maintenant approuvées comme direction artistique. Leur statut n'est plus « sélection artistique en attente ». Autorisation de produire/intégrer un premier kit et des avatars originaux de style aventure Pokémon, puis livrer un prototype de visite groupé. Pas d'approbation implicite des meshes finaux, noms définitifs ou de toute la V1.

Production :21GLB originaux depuis Blender4.3.2, sources .blend et générateur conservés. Sept bâtiments, sept grands repères, six props, un avatar à sept os/marche. Avatar avec yeux/cheveux/vêtements/chaussures/sac, palette campagne existante préservée ; PNJ variés, quatre profils de visite. Aucun modèle officiel extrait ou nouvelle espèce Pokémon ajouté. Nouvelle version du rendu de coiffure0 : cheveux courts naturels au lieu du mannequin sans ajout ; données d'apparence conservées.

Atlas : visites à pied des28lieux représentatifs des six îles et d'Æther, collisions locales et caméra, sans déblocage narratif ni déplacement du vrai joueur. La campagne actuelle garde ses lieux/progression, avec nouveaux bâtiments au havre, volcans et avatar/PNJ intégrés. Ces visites ne sont pas sept îles de campagne complètes connectées ni de nouvelles quêtes. Sources/sauvegardes conservées, réglages et équipe inchangés, aucune branche supplémentaire. Build Windows groupé avec instructions de visite et captures réelles. Validation en jeu owner du kit/avatars encore attendue ; dernière validation fonctionnelle Windows D52.


## D69 — démo intégrée et cible DS en FHD

Demande owner du 12 octobre 2026 : monde, graphismes et services réunis dans une démo jouable d'une portion de la première île. Référence graphique : personnages Pokémon DS/USUL, décor net en FHD, concepts D67 approuvés. Autonomie autorisée, propositions à ajuster après playtest ; aucune validation visuelle implicite.


Voir [LOT_DEMO_HAVRE](../development/LOT_DEMO_HAVRE.md). Développé et contrôlé techniquement, retour Windows/visuel attendu. Noms, starters, équilibrage et rendu restent provisoires ; cible graphique demandée pas encore atteinte.


## D70 — Meshy choisi pour essai, poursuite des blocs solo

Propriétaire, 12 octobre 2026 : « Meshy Pro pendant un mois […] Continue sur les autres blocs en autonomie ». Les assets D69 sont rejetés comme qualité finale ; concepts D67/D68 conservés. Essai Meshy choisi, modèle exporté/textures pas encore fournis. Aucun asset payant généré ou importé dans ce lot.

Journal, carte locale, trois parties de démo et continuité des portes/interactions développés et testés localement. [Portée, sauvegardes et limites](../development/LOT_EXPLORATION_SAUVES_DEMO.md). Playtest Windows et validation visuelle distincts ; multi/raids/défis reportés, reproduction retirée.


## D71 — dix blocs autonomes, sélection Pokémon attendue

Propriétaire : « idéalement 10 […] en autonomie […] pokédex et starters demain », 12 octobre 2026. Autorise la poursuite des systèmes solo avec fixtures ; aucune sélection finale implicite. Dix blocs développés et contrôlés : [portée et limites](../development/LOT_DEMO_DIX_SYSTEMES.md). Graphismes de maquette conservés, rejetés comme rendu final ; registre d’assets vide. Pokédex/starters futurs restent à recevoir. Aucun playtest Windows supplémentaire déduit.


## D72 — lot autonome de douze blocs

Propriétaire, 12 octobre 2026 : « enchaine sur les 10/20 prochains blocs […] 20 […] jouable ». Poursuite solo autonome avec fixtures, sans figer Pokédex, starters ni modèles Meshy attendus. Douze blocs intégrés : expédition, actions contextuelles, Vol, services locaux, Pokédex de démo, scènes/replay, autosave séparée, archives portables, diagnostic des sauvegardes, inspection GLB, préflight de contenu et lisibilité du combat. [Portée et limites](../development/LOT_DEMO_PROGRESSION_SERVICES.md). Développé/testé techniquement ; playtest Windows et choix artistiques restent distincts.


## D73 — dix blocs de prolongement

Owner : « Ok enchaine sur les 10 prochjains blocs », 12 octobre 2026. Poursuite autonome du solo avec fixtures. Canopée/sources/poste secondaire, contrôle RR, relais, championne climat, responsables au palier commun, Surf, camp, rencontres/habitats, carte/guidage et scènes/reprise : [lot détaillé](../development/LOT_DEMO_CANOPY_DIX_BLOCS.md). Développé/testé techniquement, pas de validation Windows/graphique déduite. Pokédex/starters et Meshy toujours attendus ; noms/équilibrage/récit proposés, divinité et libération de l’île non implémentées par ce lot.


## D74 — option A et pilotes Tripo

Propriétaire, 13 octobre 2026 : option A acceptée (exploration 3D chibi, présentation des Pokémon en combat 2D), Tripo choisi ; exports boutique et héros fournis, puis versions retopologisées et animées. Intégration/retouches et livraison de démo explicitement demandées. [Lot et limites](../development/LOT_TRIPO_PILOTES.md). Modèles dans la démo, pas de validation artistique ou Windows implicite.


## D75 — proportions boutique et vitesse de déplacement

Propriétaire, 13 octobre 2026 : D74 fonctionne ; demande boutique plus grande et course plus rapide, signale que ×4 accélère seulement le clip. Boutique +25 % proposée/intégrée, course 3,8 → 5,4 unités/s, déplacement démo et atlas soumis au multiplicateur au même titre que l’animation. Collision, entrée/sortie et reprise des anciennes positions de porte adaptées. Tests à 15/30/60 FPS pour ×1/×2/×4, course et marche, et anti-traversée des murs. Retour owner sur ce réglage à recevoir.
