# Essais préalables — plan à approuver

État : aucun moteur installé pour Archélys, aucun prototype exécuté. Git HTTPS et lecture des questionnaires sont vérifiés. Aucun test de jeu n’existe encore.

## G0 — Cadrage

Le propriétaire relit V0.1 ; décisions explicites et questions sont séparées. Les formats de raid, progression coop et sauvegardes sont suffisamment précis pour démarrer l’essai. Cela n’exige pas de connaître chaque dialogue de la région.

## G1 — Faisabilité technique

Évaluer bases existantes Godot Pokémon versus structure propre : version, licence, activité, règles couvertes, séparation combat/rendu, réseau, export Windows. Ne pas qualifier une base de solide sans inspection et lancement. Godot/Blender = candidats acceptés pour essai seulement.

Petit essai comportant : import et animation de modèles morphologiquement variés ; mouvements, caméra et intérieur ; combat Solo/Duo ; représentation de raids phasés et simultanés ; trois participants réseau ; sauvegarde, déconnexion et reprise ; Windows ZIP.

Critères : mêmes événements de combat côté clients, pas d’action avant choix validé, informations adverses cachées, transactions sans duplication, progressions scénaristiques bloquées en absence, sauvegardes intactes après interruption. Tester plusieurs clients locaux puis machines séparées, LAN puis Internet si accessible. Simulation locale ne valide pas routeurs et invitations publiques.

Définir un socle performance après scène réelle : CPU/GPU/RAM/OS identifiés, FPS et temps de frame mesurés. Objectif 1080p/60, pas preuve existante. PC owner : i7 13e gen, RTX 4060 Ti, 32 Go ; ce n’est pas le minimum.

## G2 — Validation visuelle

Petite scène puis ensemble de la première île après accord : captures et exécutable, caméra, décors, éclairage, eau, animations et interface. Vérification par le propriétaire ; résultat ne vaut pas validation de cinq autres biomes jamais fabriqués.

## G3 — Production

Outils et versions choisis, architecture des données et save stable, bilan des assets disponibles, périmètre du premier jalon fixé. Chaque feature est livrée avec preuves adaptées. Aucun test trivial pour prétendre prêt.
