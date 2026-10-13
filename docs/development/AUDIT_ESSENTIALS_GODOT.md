# Archélys — audit Essentials / Godot

Date : 14 octobre 2026. Recherche documentaire et lecture de code, sans migration ni nouveau build. HeartGold/ROM DS exclu du choix à la demande du propriétaire. Exigences immuables : histoire d'Archélys et direction graphique 2D dessinée HD, références B approuvées ; le prototype jouable n'est pas encore un rendu final accepté.

## Conclusion

Essentials est une base Pokémon beaucoup plus complète qu'un moteur généraliste. Il peut accueillir un archipel original et notre histoire, sans reprendre un scénario officiel. Mais Essentials + Pokémon DS Map Studio ne constitue pas une chaîne de production compatible : Map Studio crée des modèles de cartes DS, Essentials consomme des cartes 2D RPG Maker. Il faudrait un convertisseur et du travail de reprise ; les collisions, événements, raccords et scripts ne se transfèrent pas automatiquement.

Pour la cible graphique immuable, Godot reste le chemin techniquement le plus direct. Cette conclusion ne valide pas la qualité de notre démo actuelle. Notre méthode de production doit changer : un fond peint avec des collisions écrites à la main n'est pas encore un kit de carte réutilisable. Essentials offre un socle de cartes/événements plus standard, mais son renderer et son éditeur sont à adapter/éprouver pour des assets réellement HD.

## Ce qui a été vérifié

- Code public de Pokémon Essentials, basé sur v21.1 selon son README ; audit des réglages, carte, connexions, renderer et spriteset. Pas d'exécution d'Essentials ni de prototype HD dans ce moteur.
- README officiel de Pokémon DS Map Studio : interface ressemblant à un tilemap, conversion en modèle 3D, jeux DS générations 4/5, export NSBMD ; ne modifie ni n'importe directement les cartes originales.
- README mkxp-z : runtime orienté compatibilité RGSS/Essentials, plateformes Windows/Linux/macOS, limites de bitmaps liées au GPU. Ce runtime moderne ne fournit pas automatiquement un nouveau renderer de cartes HD ni un nouvel éditeur.
- Godot : lecture des scripts réellement utilisés par la démo Archélys et des spécifications ; tests et captures D79 disponibles. Pas de benchmark comparatif Essentials/Godot, pas de chiffrage fiable de migration.

## Compatibilité de DS Map Studio

DS Map Studio ne produit pas une carte RPG Maker/Essentials. Sa sortie principale est une géométrie 3D DS ; Essentials attend données de cartes/événements et images de tilesets 2D. Une éventuelle image de la carte exportée servirait de référence ou de fond précalculé, pas de carte jouable complète. Il faudrait reconstruire les règles de passage, priorités, portes, triggers, PNJ et transitions. Rendre ce fond en HD ne crée pas les détails absents des textures sources.

La combinaison pertinente pour Essentials serait RPG Maker XP et des graphismes préparés pour son renderer, ou un renderer de fonds HD et de couches développé spécifiquement. Pour Godot, ce serait son éditeur 2D avec TileMapLayer/scènes, ou un outil 2D externe avec un import explicitement vérifié. Ajouter DS Map Studio aux deux chemins introduirait une conversion sans bénéfice démontré pour notre cible.

## Comparaison

| Critère | Essentials | Godot + socle Archélys |
|---|---|---|
| Histoire originale et plusieurs îles | Compatible : cartes, connexions, transports, flags/événements ; aucune histoire officielle imposée | Compatible : scènes, progression et données ; archipel déjà prévu |
| Systèmes Pokémon de base | Avantage important : aventure, combat, équipe/PC, objets et événements Pokémon préexistants | Socle partiel déjà développé ; Showdown couvre les combats, pas toute l'aventure |
| Qualité B directement dessinée en HD | À éprouver : résolution, source des tuiles, acteurs, priorités et interface | Affichage HD déjà démontré ; assemblage et direction artistique encore insuffisants |
| Mapping standard | Éditeur RPG Maker XP et conventions Pokémon ; avantage pour des cartes classiques | Éditeur 2D disponible, mais notre démo utilise encore des coordonnées de collision manuelles |
| DS Map Studio | Pas d'import natif identifié/documenté | Pas de chaîne de production 2D appropriée démontrée |
| Personnalisation avatar | Adaptation/plugins et assets à prévoir ; ne pas confondre choix de personnage et vêtements composables | Adaptation/assets à prévoir ; nouvelle base dessinée encore fixe |
| Lore, cinématiques, compagnons | Faisable avec événements/Ruby ; mise en scène HD à adapter | Faisable avec scènes/animation/dialogues ; mise en scène finale à produire |
| Mécaniques spécifiques et raids | Extensions et vérification nécessaires ; aucune conformité exhaustive 9G déduite de v21.1 | Showdown intégré, logique particulière du fangame à conserver/vérifier |
| Coop ultérieure | Développement spécifique ; aucun mode campagne coop prête à l'emploi vérifié | Primitives réseau et séparation domaine/services déjà présentes ; campagne Internet non validée et reportée |
| Migration maintenant | Coût substantiel de réécriture/adaptation | Pas de migration ; chantier de production des cartes et assets demeure |
| Outils et coûts | Éditeur RPG Maker XP sous licence payante à prévoir ; plugins/outils compatibles à vérifier | Godot gratuit ; coûts de dessins et d'intégration toujours présents |

## Essentials : gain réel et contraintes HD

On gagnerait surtout une structure de fangame Pokémon éprouvée : conventions de carte, événements, progression, interactions et nombreux écrans/systèmes. Cela peut réduire le nombre de mécanismes génériques à écrire nous-mêmes. Les configurations de notre histoire peuvent être retranscrites ; une île n'est qu'un ensemble de cartes et de liaisons, pas une limitation de moteur.

Mais les réglages inspectés utilisent un écran interne de 512×384. `Game_Map` fixe les tuiles à 32×32 ; `TilemapRenderer` distingue taille d'affichage et taille source, cette dernière restant à 32×32 par défaut. Agrandir la fenêtre ou afficher ces tuiles plus grandes ne les rend pas réellement plus détaillées. Augmenter la résolution interne sans changer les proportions ferait apparaître beaucoup plus de cases et des personnages trop petits.

Une vraie direction B nécessiterait de vérifier : import de tuiles plus détaillées/fonds HD, renderer, mapping dans l'éditeur, autotiles/raccords, affichage et animation des personnages, couches devant/derrière eux, caméra et tous les écrans UI. Changer deux constantes ne prouve pas que l'ensemble fonctionne. Un fond complet en panorama ne suffit pas non plus : le spriteset standard fait défiler le panorama à la moitié de la vitesse de la carte, ce qui demande une adaptation pour en faire un sol parfaitement aligné.

mkxp-z est un runtime moderne utile ; ses capacités de GPU/fenêtre ne changent pas à elles seules les conventions de cartes et de ressources du projet. Aucun avis « HD impossible sur Essentials » n'est justifié par cet audit ; aucun avis « B clé en main » ne l'est davantage.

### Ce qu'une migration ne récupérerait pas automatiquement

Les scripts GDScript de progression, services, menus, sauvegardes et transports ne sont pas des plugins Ruby Essentials. Les idées, règles, dessins et données peuvent servir de sources ; leur format et leur implémentation doivent être adaptés. Les sauvegardes ne deviennent pas compatibles par copie. L'intégration actuelle de Showdown nécessite soit un pont spécifique Ruby/Node, soit le choix du simulateur natif d'Essentials et une nouvelle vérification des règles. Les fonctionnalités annoncées par des plugins doivent être examinées version par version.

Le dépôt public d'Essentials ne contient pas le projet complet : le README demande une copie d'Essentials v21.1, et exclut notamment Graphics/Audio/Plugins et une partie des données. Un fork Git seul ne fournit donc pas immédiatement une démo complète prête à lancer.

## Godot : capacité réelle et défauts de notre approche

Godot peut afficher les dessins HD et gérer un monde 2D en couches, des collisions, acteurs, animations et changements de scènes. Une région à plusieurs îles et notre scénario ne constituent pas un point de blocage moteur identifié. Cela ne transforme pas automatiquement nos concepts en assets cohérents ni nos cartes en zones bien construites.

La démo D79 utilise surtout des images de cartes complètes, cinq dispositions écrites à la main, un héros fixe et des PNJ issus du même dessin. Les silhouettes et distances visuelles peuvent varier entre intérieur et extérieur. Les objets peints ne sont pas indépendants : ils ne peuvent pas disparaître ou passer devant le héros proprement. Cette approche démontre un rendu et un petit parcours, mais ne prouve pas une fabrication fiable de dizaines de zones.

Pour continuer, il faut un petit kit graphique de référence : sols raccordables, maison/boutique/Centre séparés, arbres et éléments de premier plan, un héros sur quatre directions, proportions constantes. La carte doit assembler ces éléments avec collisions et points d'interaction dans l'éditeur, plutôt qu'un tableau différent d'une image peinte. Certaines scènes peuvent conserver des fonds illustrés, avec sol et couches foreground correctement séparés. Même règle pour des panoramas Essentials.

La richesse de B peut se concentrer sur les bâtiments, éléments remarquables et végétation, avec sols moins chargés et mieux répétables : cela préserve la direction approuvée sans imposer que chaque pixel de chaque zone soit une illustration différente. Ce compromis d'organisation doit être montré au propriétaire, pas tenu pour déjà approuvé.

## Recommandation et critères de décision

Pas de migration immédiate fondée sur la seule réputation d'Essentials. Pas de production supplémentaire de plusieurs îles avant de prouver la méthode graphique. Godot reste le candidat privilégié pour la vraie HD, conditionné à une petite scène de qualité reproductible. Essentials devient un concurrent crédible si son adaptation HD s'avère limitée et qu'elle conserve son avantage de mapping/systèmes.

Une comparaison utile réemploierait les mêmes dessins dans les deux moteurs : une rue, un intérieur, un avatar et un arbre de premier plan. Même résolution et même taille visible de personnage. Elle vérifierait : détail réellement conservé, collisions correspondant au dessin, passage derrière l'arbre, entrée/sortie à la bonne porte, mouvement directionnel, dialogue et un combat. D'abord faire cette scène dans Essentials sans migrer toute la campagne ; identifier les adaptations du renderer/éditeur nécessaires. Ne pas reprendre DS Map Studio pour cet essai.

Si Essentials exige un renderer de cartes, un système d'avatar et une interface HD largement nouveaux, son gain sur le socle ne signifie plus un gain global assuré. Si ces adaptations restent petites et l'éditeur est pratique, migrer peut devenir raisonnable. Aucun budget en jours ou pourcentage d'économies ne peut être affirmé avant cet essai. Le coût déjà engagé sur Godot ne doit pas imposer sa conservation ; les graphismes et l'histoire priment.

Cet audit propose un critère de choix, sans autoriser silencieusement une migration ou une baisse de qualité graphique. Aucune installation d'Essentials, modification du gameplay ou nouveau ZIP effectuée dans ce lot.

## Sources examinées

- [Pokémon DS Map Studio — README](https://github.com/Trifindo/Pokemon-DS-Map-Studio).
- [Essentials — README et périmètre du dépôt](https://github.com/Maruno17/pokemon-essentials).
- [Essentials — réglages d'écran](https://github.com/Maruno17/pokemon-essentials/blob/master/Data/Scripts/001_Settings.rb).
- [Essentials — Game_Map](https://github.com/Maruno17/pokemon-essentials/blob/master/Data/Scripts/004_Game%20classes/004_Game_Map.rb).
- [Essentials — renderer de cartes](https://github.com/Maruno17/pokemon-essentials/blob/master/Data/Scripts/006_Map%20renderer/001_TilemapRenderer.rb).
- [Essentials — connexions de cartes](https://github.com/Maruno17/pokemon-essentials/blob/master/Data/Scripts/004_Game%20classes/005_Game_MapFactory.rb).
- [Essentials — spriteset/panoramas](https://github.com/Maruno17/pokemon-essentials/blob/master/Data/Scripts/005_Sprites/007_Spriteset_Map.rb).
- [mkxp-z — README](https://github.com/mkxp-z/mkxp-z).
- [Godot — édition TileMap](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html).
- [Démo actuelle : méthode et limites](LOT_2D_DESSINEE.md), [vérification D79](VERIFICATION_D79.md), `game/scripts/world/drawn_view.gd` et `drawn_layouts.gd`.
