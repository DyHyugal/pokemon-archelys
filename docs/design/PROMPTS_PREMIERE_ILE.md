# Prompts des assets de la première île

SPOILERS DEV. Catalogue préparatoire demandé par le propriétaire après D73 ; aucun modèle généré/importé et aucun changement du jeu ou des sauvegardes dans cette tâche.

[Télécharger le classeur Excel](https://raw.githubusercontent.com/DyHyugal/pokemon-archelys/refs/heads/docs/cadrage-valide/docs/design/Prompts-assets-premiere-ile-Archelys.xlsx)

Le classeur comporte **181 fiches** : 115 décors/accessoires 3D, 18 personnages, 22 textures/effets, 16 éléments d'interface et 10 briefs d'animation. Une fiche n'est pas nécessairement une génération payante : beaucoup d'éléments se réutilisent, et les modules architecturaux sont une alternative de production après les bâtiments pilotes. Le catalogue est prévisionnel ; il ne prétend pas énumérer les espèces encore inconnues ou toutes leurs animations d'attaques.

Les cinq colonnes demandées sont présentes : zone concernée, déclinaison possible (Oui/Non/Condition), condition détaillée, prompt et commentaire. Des colonnes supplémentaires identifient l'asset, la priorité, l'outil, le livrable, le statut et le retour/export du propriétaire. Filtres, en-têtes figés, textes renvoyés à la ligne et listes déroulantes facilitent le suivi ; aucune macro ni protection de feuille.

Commencer par **D001, boutique côtière**, puis **P001, avatar masculin pilote**. Télécharger de vrais GLB avec textures intégrées, inspecter les faces et tester en jeu avant une production en série. Une planche de quatre vues doit servir de direction artistique ; elle ne doit pas être envoyée entière pour obtenir un bâtiment isolé. Le premier bâtiment peut utiliser la référence boutique appréciée dans la conversation.

Les prompts des décors/personnages sont autonomes et en anglais, avec une direction commune crème/turquoise/bois/basalte, des formes anime naturelles et des exclusions contre les socles, scènes fusionnées et ombres précalculées. Les colonnes explicatives sont en français. Les raccords, matériaux séparés, topologie, rig, collisions et animations restent des travaux à vérifier dans Blender/Godot : les mots du prompt ne garantissent pas ces caractéristiques.

Le port, le village de basalte et la raffinerie suivent le [canvas tropical approuvé](concepts/01-tropicale.png). Les détails de façades, les tenues et visages, l'implantation des services et le tracé de la carte restent des propositions. Le poste local est distingué du repaire secondaire de fin d'île ; le sanctuaire ne choisit aucune divinité et n'introduit aucun Gardien céleste.

Les textures peuvent utiliser une IA d'image. Les shaders, particules et animations sont identifiés comme des briefs de production, pas comme des fonctionnalités assurées par Meshy. L'interface sépare les images des textes FR/EN, jauges et interactions. Les fichiers JSON associés permettent de chercher/copier les mêmes prompts sans Excel : [inventaire structuré](Prompts-assets-premiere-ile-Archelys.json).

L'onglet **Couverture** indique les zones déjà jouables en maquette et celles restant à construire. Pokémon, starters, deltas, Fakemons, Méga et divinité attendent les espèces/designs du propriétaire ; leurs fiches individuelles devront être ajoutées ensuite. L'audio est signalé comme un lot distinct, hors génération d'assets visuels Meshy.

Vérification du livrable : réouverture avec openpyxl, 181 identifiants uniques, prompts/zones/conditions/commentaires non vides, exactitude des cellules de prompt par rapport à l'inventaire, présence des filtres/listes, limites Excel et intégrité ZIP. Aucun playtest ou build Windows nouveau n'est requis pour ces documents seuls.
