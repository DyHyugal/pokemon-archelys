# Registre des décisions

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
