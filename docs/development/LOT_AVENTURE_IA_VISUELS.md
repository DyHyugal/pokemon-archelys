# Lot groupé D61 — combat, aventure, visuels et ouverture

**SPOILERS DEV — textes d'ouverture proposés.** Objectif : relier les systèmes existants dans une aventure de démonstration persistante, sans choisir silencieusement les contenus finaux. Les quatre chantiers sont réunis dans un ZIP ; la vraie production d'îles reste conditionnée à l'approbation artistique/narrative.

## Combat et IA

Showdown résout toujours les mécaniques officielles ; son commit et le catalogue22 espèces/43 attaques restent inchangés. La politique difficile coordonne les décisions doubles : éviter deux poses du même terrain/climat, passage poseur/bénéficiaire, évaluer les deux cibles d'une zone, pénaliser le risque pour un allié blessé et privilégier Abri pour le partenaire d'une attaque de zone. Coup d'Main nécessite un partenaire capable d'attaquer. Les champs/durées et restrictions d'attaques sont présentés plus clairement, en FR/EN.

L'IA connaît son équipe et les informations adverses visibles, pas les sets/statistiques/talents cachés ni les futurs choix du joueur. Ce sont des heuristiques testées, pas une garantie de stratégie experte ou un audit exhaustif de toutes les interactions Pokémon. Les effets/dégâts ne sont pas réimplémentés dans Godot.

## Parcours persistant

Menu Aventure : prologue manuel FR/EN et cinq Balls/trois Potions une fois. Sortie nord du village vers le sentier ; balise à l'est ; sortie nord vers l'épreuve. Rencontre et capture réutilisent les systèmes légaux du laboratoire. Le gardien possède deux Pokémon niveau10 (Vulpix soleil/Bulbasaur) et utilise le moteur Showdown. Victoire :500 pièces une fois, cap au moins18 sans jamais diminuer un cap supérieur. Épilogue manuel puis retour au village ; Centre/boutique/PC restent disponibles.

Journal et portes suivent les drapeaux ordonnés de l'aventure. Sauvegarde5 inclut un état optionnel `journey` ; anciennes campagnes sans état lisibles. Les scènes de l'ouverture ne peuvent être rejouées par la galerie avant leur découverte. Ni cadeau ni récompense ne se répètent au rechargement. Pas de sauvegarde de combat en cours. Garder les anciennes sauvegardes ; une ancienne version du binaire ne sait pas lire les nouvelles zones.

## Référence graphique

Trois variantes procédurales actualisées : façades/volets/jardinières, marches/pavage/bancs, végétation et eau animée originale. Géographie du village conservée ; sentier et arène d'essai construits sur des primitives cohérentes. Avatar GLB original existant conservé. Captures1920×1080 dans `docs/design/comparatifs` et dans le ZIP.

Provenance : code géométrique et shader créés dans ce dépôt ; aucun nouvel asset officiel ou tiers importé. Ce rendu reste un prototype stylisé avec mannequin, pas des graphismes finaux ni un budget d'assets500 Pokémon. Aucune variante approuvée implicitement.

Mesure réelle :30 images rendues après10 de chauffe,187,9ms/image soit5,3fps en Full HD sur **llvmpipe, rendu logiciel CPU Linux**. D'autres contrôles étaient simultanés. Cette mesure n'est ni une mesure GPU Windows ni une configuration minimale. Contrôler la fluidité sur le PC du propriétaire avant engagement de production.

## Ouverture proposée et limites

Reprise des points narratifs confirmés (occupation et père emprisonné), avec des répliques Vyna proposées et balisées. Ni casting final, ni espèces/starters définitifs, ni nouvelle divinité imposée. Les niveaux/économie sont des paramètres d'essai. Le quatrième lot livre une maquette jouable et non une île finale : scénario/art encore ouverts dans OPEN_QUESTIONS.

Les œufs cadeaux et fossiles restent disponibles. Reproduction supprimée ; réseau, raids, Nuzlocke et Soul-link reportés. Une suite automatique de tests ne remplace pas l'appréciation artistique ou la validation Windows.

## Vérification

`tools/check_prototype.py` : toutes les suites réussies, dont41 contrôles adaptateur Showdown,33 intégration,17 règles de parcours et14 contrôles de la scène réelle. Tests de cadeaux/recompenses uniques, ordre des portes, restauration JSON et anciennes campagnes, cap non décroissant, boss réel et épilogue. Contrôles antérieurs combat/capture/PC/Méga/confort et slots conservés. Quatre captures GL réelles produites, A et sentier inspectés ; rendu distinct des contrôles headless. Le ZIP vérifie le PE Godot non modifié, Node épinglé et l'intégrité ZIP.

Le parcours propriétaire est dans LIRE-MOI. Validation Windows de cette livraison toujours attendue ; D52 reste la dernière reçue. Lien/build/CI seront consignés dans `verification/LOT4_2026-10-11.txt` après publication.
