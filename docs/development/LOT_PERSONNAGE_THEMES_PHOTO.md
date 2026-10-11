# Lot D62 — personnage, thèmes et photo

Objectif : développer les exigences solo déjà retenues qui ne dépendent pas du casting, des assets finaux ou du retour de playtest D61. Une livraison avec le parcours précédent et les nouveautés. Aucune île de production, réseau, raid, défi ou reproduction ajoutés.

## Personnage de laboratoire

Menu Personnage FR/EN : quatre tons de peau, quatre palettes de haut, trois de pantalon, quatre couleurs de cheveux, trois silhouettes de coiffure et deux expressions minimales. Choix gratuits d'essai, pas un assortiment final ou une règle d'économie. Le modèle est toujours le mannequin original ; les cheveux/yeux sont des primitives originales attachées à l'os Head, et les vêtements correspondent aux matériaux du mannequin.

L'apparence est sauvegardée dans la campagne, remise à l'écran au chargement et réinitialisée pour une nouvelle campagne. Pas un réglage global qui remplace les autres slots. Réglages refusés en combat. Paramètres bornés et campagne JSON invalide refusée sans modifier l'état. Anciennes campagnes sans `appearance` reçoivent les choix initiaux. Schéma5 inchangé ; conserver les anciennes sauvegardes avant utilisation. Boutiques/vêtements/modèles définitifs restent à produire après sélection propriétaire.

## Thèmes locaux

Paramètres : sombre, clair et contraste renforcé, avec boutons/focus/panneaux/textes communs aux interfaces. Écriture atomique dans comfort.json ; lecture des anciennes préférences sans thème préserve les touches/volumes/taille de texte. Le chargement d'une partie ne change pas le thème individuel. La palette claire a un contraste texte/panneau calculé supérieur à7:1 ; cela n'est pas une certification de toute l'accessibilité du jeu. Une capture réelle du menu clair a été inspectée.

## Mode photo

Menu Photo en exploration solo seulement : distance4–24, angle−180/+180 et hauteur de cadrage0–3 autour du personnage. Déplacement, interactions, voyages, scènes et changements de campagne bloqués ; incubation/rencontres/autosave ne progressent pas via le mode photo. Pas de mutation des PV/PP/sac/objectifs. Les décors animés restent animés. La caméra et la visibilité des interfaces/étiquettes sont restaurées à la sortie ; Échap et bouton Retour restent disponibles.

Export PNG à la résolution de la fenêtre, image rendue sans UI ni étiquettes3D. Fichiers distincts sous `user://photos`, bouton pour ouvrir le dossier ; chemin concret affiché après export. Aucune connexion ni upload. Export refusé en mode headless plutôt qu'annoncer une photo réussie. Aucune galerie permanente supplémentaire ou filtre final introduit.

Provenance des ajouts : palettes, matériaux, cheveux/yeux géométriques et UI créés dans ce dépôt ; aucune nouvelle ressource tierce/officielle importée. Le GLB original sept os/une animation est conservé, la silhouette finale n'est pas choisie.

## Vérification et limites

Tests domaine/préférences/PNG :17 contrôles, dont image rechargée et pixels/dimensions vérifiés, second fichier sans écrasement. Tests de scène :13 contrôles, vrais menus/styles/matériaux/attachement au rig et contrôles photo, restauration et verrouillages. Le même parcours est exécuté avec rendu GL llvmpipe : PNG du viewport créé et inspecté, menu clair capturé et inspecté. Le contrôle headless teste explicitement le refus d'export sans affichage, distinct du contrôle graphique.

Le test existant Showdown du raccordement Potion/PP pouvait perdre le Pokémon par un KO aléatoire, alors qu'il cherchait à tester les transactions. Sa fixture utilise désormais un Magicarpe niveau100 avec Trempette, sans danger et assez résistant pour laisser se résoudre les deux tours. Les assertions de Potion/PP/tour sont conservées, pas relâchées ; les autres tests KO/remplacements restent séparés.

`tools/check_prototype.py` conserve toutes les suites antérieures. Windows et appréciation artistique attendent le propriétaire ; aucune garantie60FPS ou validation Windows déduite de llvmpipe. D52 reste la dernière validation Windows reçue. Preuves/build/CI dans `verification/PRESENTATION_2026-10-11.txt` après publication.
