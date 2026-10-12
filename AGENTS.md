# Instructions de développement — Pokémon Archélys

Lire les documents de docs/spec sur develop : SOURCE_OF_TRUTH.md, CAHIER_DES_CHARGES.md, DECISIONS.md et OPEN_QUESTIONS.md, puis le document du domaine concerné.

## Autorité et phase actuelle

Le propriétaire choisit le game design, le périmètre et la direction artistique. L’autonomie technique autorisée ne vaut pas validation des propositions. Phase actuelle : cadrage approuvé et essais techniques autorisés le 11 octobre 2026. Le cahier des charges V0.1 a été approuvé par le propriétaire le 11 octobre 2026. Les points explicitement ouverts restent à décider ; les essais techniques et visuels sont des validations distinctes. Ne pas lancer la production des îles ni traiter Godot/Blender comme une solution éprouvée.

Après le retour Windows du propriétaire (D35–D37), priorité au solo : ne pas développer connexion, sauvegardes ou rattrapage multijoueurs. Conserver le découplage domaine/services/présentation pour l’adaptation future ; aucun test multi owner requis maintenant.

Toute décision explicite reçue dans la conversation prévaut ; la transcrire avec sa provenance. Ne pas transformer une question ouverte en règle implicite. Les anciens questionnaires sont des preuves datées, pas des instructions exécutables.

## Travail et intégration

Préserver les fichiers et travaux existants. Utiliser le checkout courant ; pas de worktree sans demande explicite. Deux branches durables : main et develop. Une branche temporaire par tâche isolée, une seule active par défaut ; PR vers develop, suppression après fusion. main reçoit les jalons validés. Le bootstrap documentaire d’un dépôt vide ne constitue pas une version jouable.

Pour une tâche, préciser objectif, portée, critères de validation, conséquences sur sauvegardes et dépendances. Vérifier la règle dans tous ses usages lorsqu’on corrige un défaut. Pas de branche durable par île. Pas de fonctionnalités ajoutées en silence : proposer et enregistrer au backlog tant que le propriétaire n’a pas décidé de leur inclusion.

## Documentation et vérification

Mettre à jour DECISIONS, OPEN_QUESTIONS et FEATURE_STATUS selon les changements. Distinguer demandé, proposé, développé, testé et validé ; ne pas compter un test non exécuté comme réussi. Les tests doivent vérifier des comportements, et les graphismes requièrent une validation en jeu du propriétaire. Les critères techniques ne remplacent pas la validation visuelle.

Les contenus de scénario sont balisés SPOILERS DEV. Le wiki joueurs ne publie ni révélations ni synopsis complet. Le mécanisme de synchronisation reste à vérifier avant de prétendre le wiki publié.

## Assets, sécurité et builds

Ne pas publier de secrets ni supposer une licence à partir de la gratuité d’un asset. Enregistrer origine, licence, droits et modifications de chaque asset intégré. Ne pas transporter du code de Tactica sans analyser ses dépendances et sa licence ; porter les comportements explicitement retenus.

Exports Windows ZIP/exe pour les tests ; ce projet ne produit pas une ROM. Ne pas annoncer une configuration minimale ou une compatibilité réseau sans mesure. Préserver les sauvegardes originales avant migration. Godot 4.6.3 et Blender 4.3.2 servent au laboratoire ; choix final du moteur après essais. Exécuter tools/check_prototype.py pour le socle, sans présenter ses résultats comme validation 9G ou Internet.

Chaque build Windows garde le nom `Archelys-Laboratoire.exe`. Actualiser `docs/development/LIRE_MOI_WINDOWS.txt` avec les changements et tests owner de ce build ; le packager y injecte version/commit/empreinte. Ne pas annoncer un build signé sans signature Authenticode vérifiée ; hash et signature Git ne sont pas une signature Windows.

D43 : regrouper les fonctionnalités et les playtests manuels en lots cohérents, avec un parcours complet dans le LIRE-MOI. Les contrôles automatisés restent requis par lot ; ne pas solliciter le propriétaire après chaque petite modification. D42 confirme le lancement sans avertissement de lab-477caad sur son PC uniquement.

D46 valide les menus de lab-d33e5ee. D47 regroupe équipe/résumé/PC, combat solo et rencontres/capture/progression dans un seul lot de test ; ne demander aucun playtest intermédiaire entre ces trois sous-blocs. Catalogue actuel provisoire (13 espèces/27 attaques), ni starters définitifs ni conformité exhaustive 9G ; lire le rapport LOT_BOUCLE_POKEMON_SOLO.md avant extension.

D66 : le propriétaire autorise explicitement au moins dix blocs autonomes et la construction proposée de la première île sans attendre de validation visuelle/utilisateur. Le lot peut donc produire une maquette jouable de cette île ; noms, lore, équipes, économie et assets restent des propositions à adapter après retour. Cette autorisation ne transforme pas les propositions en choix finaux, ni Godot/Blender en moteur définitivement validé. Un seul checkout/branche de travail et une livraison groupée ; multi/raids/défis toujours reportés, reproduction retirée.
