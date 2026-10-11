# Architecture — socle technique initial

État : laboratoire Godot 4.6.3, pas moteur Pokémon complet. Les versions sont figées pour reproduire cet essai, pas pour interdire une réévaluation avant production. Blender 4.3.2 produit le mannequin original.

## Séparation mise en place

| Couche | Fichiers | Responsabilité |
|---|---|---|
| Domaine | campaign.gd, battle.gd, world_rules.gd, dialogue.gd | Règles de campagne, simulation de tour minimale, limites/collisions et dialogue manuel |
| Services | session.gd, save_store.gd | Hôte ENet, entrées/snapshots, stockage vérifié et backup |
| Présentation | laboratory.gd, main.tscn | Géométrie provisoire, caméra, avatars, interface de test |
| Assets | assets/prototypes/mannequin.glb | Original Blender, rig et animation d’essai |
| Vérification | tests et tools/check_prototype.py | Comportements de domaine, scène réelle, import et trois processus réseau |

Le renderer ne décide pas les dégâts ; le client transmet une direction, pas une téléportation ni une hausse de cap. L’hôte simule les positions et les limites. Les collisions sont rectangulaires/circulaires logiques, pas encore un système de navigation des maps finales. Les données des maisons et arbres sont communes à la scène et aux collisions.

## Limites importantes

IDs ENet transitoires : ils ne sont pas des identités de compte stables. Import réseau, rattrapage des nouveaux joueurs, campagne de production et migration de schema >1 non implémentés. Les RPC du laboratoire ne forment pas un service public authentifié. Serveur volontairement localhost.

Les snapshots sont envoyés à 10 Hz ; commandes de mouvement bornées et anciennes entrées expirant après 500 ms. Aucun benchmark réseau réel entre PC. Une porte factice n’avance qu’une fois quand tous les participants attendus sont dans sa zone. Le cap 10→12 est une valeur de laboratoire, pas un cap final.

BattleModel vérifie commandes uniques, KO, priorité/vitesse, interdiction de dégâts alliés en raid et abandon/restauration. Pas de types, talents, météo, stats 9G, IA Tactica, captures, Soul-link ou raid final. Le départage des égalités stable par ID est un choix de laboratoire, pas une règle Pokémon à conserver.

## Suite solo confirmée

Le dialogue est un modèle sans dépendance au renderer ni au réseau : lignes validées, langue et avance manuelle. Les textes FR/EN du guide sont dans `game/data/dialogues/laboratory_guide.json`, inclus explicitement dans l’export. Ce socle ne constitue pas la localisation complète du jeu. La présentation ouvre le dialogue à proximité, bloque le mouvement et ignore les répétitions de touche ; aucune avance chronométrée. Les conversations restent transitoires ; le journal de laboratoire ajouté dans le lot suivant est sauvegardé en schéma 2, avec lecture du schéma 1 et copie originale. Caméra orthographique de taille 16 au lieu de 22, suit le joueur ; curseur 12–22 pour affiner le test, préférence désormais persistée avec la langue dans le lot solo décrit ci-dessous.

La simulation affichée passe de trois alliés contre un boss à un duel factice. Les règles du domaine et l’ancien réseau restent disponibles mais le panneau réseau est masqué par défaut. Aucun travail supplémentaire sur connexion ou sauvegardes coop. Le test courant est solo ; `--network` permet seulement de réexécuter l’ancienne régression localhost si une modification réseau la justifie.

## Étapes d’architecture suivantes

Identités persistantes et commandes versionnées ; données espèces/attaques/items localisées FR/EN ; simulateur de combat pur et événements rejouables ; stockage atomique et migrations ; orchestrateur narratif et checkpoints ; instances de combat ; registre des liens Soul-link ; inventaire et transactions. Chaque élément est ajouté quand sa règle et son usage sont définis, pas comme cent abstractions vides dès le départ.

## Lot solo : progression de laboratoire et préférences

`LaboratoryProgress` contient les trois objectifs de test et l’unique récompense de caisse ; il valide les identifiants et la cohérence caisse/jeton. `CampaignModel` inclut son snapshot dans le schéma 2 ; lit aussi le schéma 1 sans effacer position ou palier, en initialisant ce nouveau modèle. `SaveStore` préserve une copie `.v1.backup` au premier remplacement d’une version 1 par 2, distincte de la backup roulante. Les versions futures inconnues et les états incohérents sont refusés avant mutation.

`PreferencesStore` lit/écrit langue et caméra dans `preferences.json`, indépendamment de la campagne. Écriture temporaire puis remplacement ; données invalides refusées et fichier corrompu récupéré aux valeurs par défaut. Le chargement d’une campagne ne remplace pas ces choix personnels. Préférences automatiques ; campagne encore chargée/enregistrée par boutons, pas autosave de production.

La présentation choisit l’interaction la plus proche, lit les dialogues localisés, suspend le mouvement et affiche journal/sac. Panneau et caisse sont des géométries originales provisoires. Les nouvelles interactions restent solo, sans développement de synchronisation multijoueur.

Contrôles : 19 originaux, 18 progression/préférences/migration, 6 dialogues, import du modèle et scène réelle (clavier, panneau, caisse, journal, stockage et nouvelle scène). Le moteur portable reste identique, seules les données PCK changent. Les anciennes descriptions schéma 1 et préférences non persistées décrivent les builds précédents et sont remplacées par ce lot.
