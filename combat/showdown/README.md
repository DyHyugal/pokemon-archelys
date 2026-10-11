# Showdown dans Archélys

`bridge.cjs` est un adaptateur original ; `policy.cjs` est une politique d'IA à observations limitées. Les sources amont ne sont pas copiées dans Git : `tools/prepare_showdown.py` récupère le commit épinglé, installe son lockfile et compile, puis prépare `builds/showdown`. Seule la dépendance d'exécution `ts-chacha20` est redistribuée avec le simulateur. Les sources maps, outils serveur et équipes aléatoires sont exclus. Les notices amont sont copiées sans modification.

Prérequis développement : Node24.19.0, npm et Godot4.6.3.

```sh
python tools/prepare_showdown.py
python tools/check_prototype.py
# Ajouter le runtime Windows officiel vérifié avant packaging :
python tools/prepare_showdown.py --windows
```

Le préparateur utilise `artifacts/dependencies` (ignoré par Git), ou `ARCHELYS_DEPENDENCY_CACHE`. Un checkout déjà compilé et inchangé peut être fourni avec `--source`. Les joueurs reçoivent le runtime et n'installent rien. En développement Linux, le vérificateur fournit `ARCHELYS_NODE_BIN` ; pour lancer manuellement Godot, définir cette variable au chemin absolu de Node.

Protocole JSON par lignes, version1, identifiant monotone, entrée64KiB et réponse256KiB maximum. Une bataille par processus ; start, act, external et close. Godot écrit/lit depuis un thread et poll les réponses sans bloquer son rendu, avec délai10s et destruction du processus à la sortie. Les champs de réponse destinés à synchroniser la campagne ne constituent **pas** une vue autorisée de l'IA. La politique reçoit seulement la projection construite par `aiView()` ; aucun set, objet ou choix caché du joueur.

Le format Archélys utilise la9G, des éléments historiques autorisés dans un catalogue explicite, les PP de base et une Méga. Aucune clause compétitive National Dex OU importée. Téra, Dynamax et capacités Z sont interdits. Les évolutions/rencontres/apprentissages restent contrôlés par le catalogue de campagne, pas par une validation Smogon de légalité compétitive.

Les actions external sont des soins du sac ou un tour de capture échouée, réservés au solo simple. Elles utilisent les objets Pokémon de Showdown et remplacent l'action du joueur par une passe ; l'adversaire et les effets de fin de tour restent résolus par Showdown. Les ressources du sac sont engagées après acquittement, sauf le lancer de Ball dont le résultat appartient à l'aventure ; une panne restaure l'ensemble du snapshot d'avant combat.

Les anciens moteurs GDScript restent seulement pour comparaison de tests, sans accès depuis les combats Pokémon jouables et sans fallback. Le modèle Showdown hérite d'un module séparé de règles d'aventure, sans calcul d'attaque. La petite simulation factice historique à trois participants du panneau labo est un autre outil, pas un combat Pokémon réel.
