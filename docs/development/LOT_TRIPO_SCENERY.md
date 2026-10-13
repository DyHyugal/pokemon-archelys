# Intégration de 34 exports Tripo — D77

Demande propriétaire du 13 octobre 2026 : intégrer les 34 modèles fournis pour juger une première refonte graphique directement dans la démo. Travail sur le même checkout/branche, livraison unique. Aucune nouvelle sélection Pokémon, aucun scénario final inventé.

## Placement réel

Les **34 modèles sont présents dans les huit lieux de la démo** : havre, sentier, Centre, boutique, maison, canopée, sources et poste RR. Le bâtiment fourni avec un nom UUID est utilisé comme Centre provisoire. Le fichier `gazebo` est visuellement une forteresse sombre : il est placé au poste RR ; `gazebo (1)` est le kiosque du havre. `fantasy furniture` est un mobilier de soins, utilisé au Centre.

Le havre reçoit maisons, Centre, bâtiment public, tour, arche, bateau, kiosque, palmiers, lampadaires, bancs, plantes et rochers. La boutique et le héros D74/D75 sont conservés. Temple et plateforme vont aux sources ; tente/fougères au camp ; forteresse, garde et barrières au poste RR. Les intérieurs reçoivent comptoirs, lit, matériel, caisses et coffre.

Chaque modèle est aussi inspectable dans **Menu → Modèles importés**. Les noms d'affichage sont français/anglais, l'aperçu tourne avec le curseur. Les dimensions de l'aperçu ne sont pas celles de toutes les instances du monde, qui ont chacune leur échelle.

## Adaptations

Les GLB fournis sont copiés sans modifier leur géométrie ni leurs textures intégrées. Pivot ramené au sol, échelle uniforme ajustée aux empreintes de gameplay, orientations corrigées pour les façades/comptoirs/arche/bancs. Réglages de rugosité et de métal locaux aux instances ; aucun matériau source écrasé. Collisions des meubles calculées depuis leurs dimensions réellement affichées pour éviter les anciens murs invisibles ; collisions simples adaptées aux nouveaux props ; les portes, services et objectifs existants restent accessibles. Une ancienne position située dans un nouveau obstacle est déplacée vers un point libre proche, sans reset de campagne.

Le kit partagé remplace aussi les anciens palmiers, arbres, rochers, lampes, bancs et maisons tropicales dans certaines visites de l'atlas et autres lieux d'atelier. Cela ne constitue pas la refonte artistique de toutes les îles. PNJ actuels, terrains, routes, eau, murs d'intérieur et une partie des petits éléments restent provisoires. Aucun nouveau modèle de personnage fourni dans ce lot ; ne pas appeler le rendu final approuvé.

## Poids et optimisation

34 sources : **116 801 220 octets (117 Mo)** ; **741 698 triangles uniques**, entre 17 358 et 42 776 par modèle. Ce chiffre n'est pas le nombre de triangles affichés simultanément : instancier le même arbre plusieurs fois le multiplie. Textures extraites automatiquement par Godot conservées ; poids disque supplémentaire réel supérieur à celui des seuls GLB.

Godot génère les LODs à l'import ; visibilité des meshes limitée à 85 unités avec marge de 5. Instances partageant les ressources du modèle, matériaux spécifiques pour éviter la mutation globale. Pas de décimation destructrice ni baisse générale de résolution sans contrôle visuel. Le rendu a été contrôlé en FHD sous Linux avec llvmpipe (CPU logiciel) ; **aucune configuration minimale Windows ni promesse de 60 FPS**. Le prochain retour doit préciser résolution, fluidité et matériel.

## Vérification

Nouveau test `tests/tripo_scenery.gd` : **120 contrôles headless réussis**, puis **128 avec captures**. Chargement des 34 vrais fichiers, normalisation/sol/empreintes, présence effective des 34 dans les lieux, arrivée libre et recherche d'un chemin praticable vers les interactions, reprise d'une position devenue bloquée, campagne intacte. Le test n'approuve pas artistiquement les placements ni les meshes. Les contrôles D75 des proportions boutique et du déplacement ×1/×2/×4 restent présents. L’import initial de la suite dispose désormais d’un délai borné de 600 s pour ces 34 modèles et leurs LODs ; les tests fonctionnels gardent leur limite de 60 s.

Captures réelles du monde Godot en 1920×1080 dans [tripo-batch](tripo-batch), sans montage conceptuel : vues d'ensemble des huit lieux et cadrage joueur au havre. Les captures isolent le monde ; l'interface habituelle est toujours présente dans la démo jouable.

## Sources, sauvegardes et dépendances

Provenance, noms des fichiers originaux, SHA256, comptages et affectations : `game/assets/tripo/scenery-provenance.json`. Exports fournis par le propriétaire ; conditions précises du service non vérifiées indépendamment, pas de droits généraux sur les marques ou designs tiers déduits.

Schéma campagne 5 conservé. Pas de reset, pas de nouvelles espèces ou attaques ; Showdown et Node offline conservés. Même EXE officiel Godot non modifié, nom fixe. Un seul parcours owner en tête du LIRE-MOI : visite des lieux accessibles, portes/services, proportions, obstacles, caméra et fluidité. Les zones non débloquées restent soumises à la progression, les aperçus des 34 fichiers restent accessibles depuis le menu.
