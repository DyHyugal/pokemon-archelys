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

D68 : le propriétaire approuve les sept planches D67 et demande explicitement la production/intégration d'assets et d'avatars de style Pokémon, ainsi que la visite graphique des régions. Cette autorisation remplace l'attente de choix des concepts ; ne pas la redemander. Les meshes/avatars restent des prototypes à tester, pas des assets finaux automatiquement validés. Kit original Blender, sources et provenance conservées ; aucun asset officiel extrait. Conserver campagne et apparence ; visites graphiques isolées, sans déblocage narratif implicite.

D69 : demande explicite de démo intégrée (ville, PNJ, starters, combats, personnalisation et services), cible DS/USUL en FHD. Production de cette portion autorisée en autonomie ; campagne démo séparée. Ne pas annoncer qualité finale ou île complète. Voir LOT_DEMO_HAVRE.md.

D70 : Meshy Pro choisi pour essai d’un mois ; les assets primitifs D69 sont rejetés comme rendu final. Continuer les blocs solo en autonomie en conservant les concepts validés. Pas de production massive de nouveaux modèles primitifs. Aucun modèle Meshy fourni pour l’instant ; préserver séparation décors/gameplay et sauvegardes.

D71 : dix blocs autonomes demandés ; Pokédex et starters seront fournis ensuite. Ne pas les choisir à la place du propriétaire. Tables de démo clairement provisoires et sauvegardes historiques conservées. Voir LOT_DEMO_DIX_SYSTEMES.md.

D72 : poursuite autonome de 10 à 20 blocs autorisée ; lot de douze blocs solo documenté dans LOT_DEMO_PROGRESSION_SERVICES.md. Conserver les saves, distinction atelier/démo, fixtures et sélection owner en attente. Pas de validation Windows/visuelle implicite.
