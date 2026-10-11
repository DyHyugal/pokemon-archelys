# Jouer au laboratoire technique

Une [prerelease Windows de laboratoire](https://github.com/DyHyugal/pokemon-archelys/releases/tag/lab-d33e5ee) est disponible. [Télécharger le ZIP](https://github.com/DyHyugal/pokemon-archelys/releases/download/lab-d33e5ee/Archelys-Laboratoire-Windows.zip), le décompresser entièrement et ouvrir Archelys-Laboratoire.exe ; aucune installation de Godot n’est nécessaire.

Il s’agit d’un essai de faisabilité avec décors et mannequin provisoires. Aucun Pokémon final ni histoire n’est disponible ; le premier build a été essayé avec succès sous Windows par le propriétaire. Chaque build suivant reste à tester. Ce n’est pas la démo de la première île ni une validation du rendu final.

Les contrôles et limites sont décrits dans le LIRE-MOI du ZIP. La réalisation est maintenant prioritairement solo. L’ancien essai réseau localhost reste masqué par défaut ; aucun essai multijoueur n’est demandé actuellement. La configuration minimale sera déterminée plus tard. Le jeu ne nécessite pas de ROM.

Les sauvegardes des premiers prototypes peuvent être réinitialisées. Le laboratoire indique son fichier et sa copie précédente dans le LIRE-MOI. À partir de l’alpha publique, les migrations et la restauration seront expliquées avec le format final.

Cette page est une source documentaire du dépôt ; elle n’est pas encore publiée automatiquement dans un wiki joueurs.

Cette suite solo ajoute une caméra rapprochée avec réglage de distance et un PNJ guide dont les phrases avancent manuellement. La sauvegarde du premier laboratoire reste utilisable. La présentation actuelle passe aux menus solo ; son rendu final demeure à valider.

Le nom `Archelys-Laboratoire.exe` reste fixe. Chaque ZIP inclut un LIRE-MOI indiquant sa version, les changements, les tests précis et les résultats attendus. L’exécutable demeure non signé : aucune identité/certificat de signature de code n’est configuré ; les possibilités de lancement dépendent du message de protection affiché par Windows.

Cette livraison est une variante portable gratuite : décompresser entièrement le ZIP et conserver `Archelys-Laboratoire.exe` et `Archelys-Laboratoire.pck` ensemble. Le moteur est l’exécutable officiel Godot non modifié ; il reste non signé et le Contrôle intelligent peut encore le bloquer. Le premier test consiste à lancer normalement sans modifier les protections Windows, puis à suivre le LIRE-MOI si le jeu démarre.

Le lot actuel propose un menu Pause (Échap), un Sac (I) avec quantité et description du jeton, un Journal (J) et des Paramètres conservant langue et distance caméra. Sauvegarder et Charger sont accessibles dans ce menu ; F3 affiche les outils du laboratoire. Le propriétaire a validé le lot précédent lab-e84ee99. Le moteur reste identique ; les changements de ce bloc attendent son retour Windows. Le LIRE-MOI décrit un parcours regroupé.
