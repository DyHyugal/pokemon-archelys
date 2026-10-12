# D70 — exploration et sauvegardes de la démo

Demande du propriétaire, 12 octobre 2026 : essai de Meshy Pro pendant un mois et poursuite des autres blocs en autonomie. Le retour précédent rejette la qualité graphique actuelle, jugée trop proche de Roblox. Les concepts restent approuvés ; les modèles de D69 ne sont pas approuvés comme résultat final. Le lot ne génère aucun nouvel asset graphique.

## Quatre blocs regroupés

- Journal de démo : étapes réellement réalisées, objectif courant, fin explicitement indiquée, raccourci J ou touche reconfigurée. Aucun objectif du laboratoire affiché dans cette page.
- Carte locale : coordonnées du joueur, bâtiments, interactions et prochain objectif dans la ville, le sentier et les intérieurs. Plan schématique fonctionnel ; aucun Vol ou déplacement automatique supplémentaire ni carte finale de l’archipel.
- Trois sauvegardes de démo : sélection à l’accueil, création/chargement confirmés depuis le menu, copie précédente par emplacement et restauration depuis l’accueil même si le fichier principal est corrompu. Le premier emplacement conserve exactement l’ancien fichier `archelys-demo-v1.json` ; deuxième/troisième fichiers distincts. L’autosave vise la partie chargée, jamais un emplacement simplement surligné à l’accueil. Les sauvegardes du laboratoire restent séparées.
- Continuité de l’exploration : retour à la porte du Centre/boutique/maison, retour à l’entrée du sentier, libellé d’interaction contextuel, langue des menus actualisée immédiatement. Le sac de démo n’affiche plus la consigne du jeton de laboratoire absent.

## Portée

Enveloppe de sauvegarde `archelys-demo-1` inchangée. Les anciens fichiers de démo restent lisibles sans conversion. Une nouvelle partie/remplacement demande confirmation ; les copies .backup gardent la dernière sauvegarde précédente, pas un historique illimité. Charger une partie peut remplacer une progression non sauvegardée, ce qui est indiqué dans le menu. L’accueil commence par l’emplacement1 ; pas de synchronisation ni cloud save.

Mono uniquement ; multi/raids/défis toujours reportés, reproduction toujours retirée. L’équilibrage, le contenu narratif final et les assets restent distincts. Les modèles primitifs servent encore à tester ces fonctionnalités, aucune promesse d’amélioration artistique dans ce lot.

## Vérification

`demo_navigation.gd` : 20 contrôles de comportement après durcissement des copies de secours, tous réussis. Le rendu GL précédent a passé 19 contrôles plus 3 exports PNG. Journal/carte réels, guidage selon les flags, porte accessible, indépendance des parties, copie précédente conservée même après récupération d’un fichier principal corrompu, chargement invalide sans mutation, récupération d’un fichier corrompu, traduction immédiate et campagne de laboratoire inchangée. La suite complète locale est passée. Rendu exécuté sous llvmpipe Linux ; Windows et manette physique non testés ici. Dernier playtest Windows validé du propriétaire reste D52.

Voir les captures `d70-*.png` dans Comparatifs. Tests et publication ne valent pas validation artistique.
