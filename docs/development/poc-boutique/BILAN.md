# POC pratique — ce qui est démontré et ce qui ne l'est pas

## Verdict

**Je peux produire une architecture régulière complète, texturée, éditable et importable dans Godot sans Tripo/Meshy. Ce test ne démontre pas encore la qualité artistique de l'illustration cible. Je ne recommande pas de remplacer la génération spécialisée pour toute l'île sur cette seule base.**

La boutique est reconnaissable : façade crème, tuiles turquoise courbes, auvent rayé à bord festonné, fenêtres cintrées et volets, petite annexe, porte, jardinières et clocheton. Le fichier est réellement 3D sous tous les angles ; les vues de profil et d'arrière sont livrées. L'arrière est une interprétation cohérente, car l'image ne le définit pas.

Graphiquement, le résultat dépasse l'ancienne coque à quelques cubes, mais reste un **POC intermédiaire insuffisant pour certifier un asset final au niveau du concept**. Les matériaux sont plus uniformes, les détails plus répétitifs, les fleurs simplifiées et la silhouette diffère. Une illustration comporte une peinture et des déformations artistiques que ce script ne reconstitue pas automatiquement. La compatibilité du GLB ne doit pas masquer cet écart.

## Mesures réelles

| Mesure | Résultat |
|---|---:|
| Blender / Godot testés | 4.3.2 / 4.6.3 officiel |
| Triangles de la première version | 96 790 |
| Triangles de la version livrée, instances comprises | 48 328 |
| Pièces éditables dans Blender | 965 |
| Modules / meshes dans le GLB regroupé | 23 / 23 |
| Matériaux utilisés par le GLB | 14 |
| Surfaces/material slots cumulés | 93 |
| Textures albedo originales intégrées | 9 × 512×512 |
| GLB autonome | 4 208 892 octets |
| Arêtes non-manifold par composant de source | 0 |
| UV sur chaque composant | Oui |
| Dimensions du modèle importé, environ | 8,72 × 8,44 × 7,14 unités |
| Rendus | 6 Blender + 6 Godot, tous FHD |
| Contrôles Godot finaux | 114 conditions, 0 échec |

L'audit rouvre réellement le `.blend` et vérifie les textures emballées, la géométrie et les modules. Le GLB contient images et buffers intégrés, normales et UV, sans Draco requis, sans caméra/lumières/sol du studio. La porte a un module de vantail et un pivot distincts ; son mouvement ne déplace ni cadre, ni marches, ni toiture. Le rendu porte ouverte en apporte une preuve supplémentaire.

**23 meshes ne signifie pas 23 draw calls.** La scène de contrôle a mesuré 188 appels de dessin avec le sol et les passes d'ombres dans cette configuration. L'asset de 48k triangles est une base détaillée, pas un modèle léger à répéter partout sans LOD, réduction de matériaux et atlases. Aucun benchmark de ville entière ou de GPU Windows n'a été fait.

Zéro arête non-manifold vaut pour les composants séparés, pas pour un unique volume sans intersections. L'assemblage comporte des recouvrements structurels intentionnels. Les collisions de gameplay, les points d'interaction et les intérieurs d'aventure ne sont pas ajoutés par ce POC. Les vitres sont opaques et stylisées, pas une simulation d'intérieur visible.

Les 114 conditions portent surtout sur les matériaux de chaque surface, l'import, les dimensions des captures, la géométrie, les modules et la porte. Ce nombre ne mesure ni beauté, ni performance, ni conformité au jeu complet.

## Itérations et corrections constatées

Trois générations de la géométrie, puis préparation de l'export regroupé :

1. Source complète, 96,8k triangles. Premier rendu recadré trop serré et pignon turquoise incorrect.
2. Biseaux/arches/tuiles simplifiés, 48,3k triangles, pignon crème, tour mieux proportionnée et cadrage complet. Regroupement par module et correction des noms d'export. Le premier rendu moteur révélait des tuiles coplanaires qui scintillaient et un éclairage surexposé.
3. Tuiles légèrement inclinées et séparées latéralement pour supprimer ces recouvrements coplanaires ; calibration de l'éclairage Godot. Audit et captures finaux.

Le premier rendu Cycles a échoué parce que le Blender installé n'a pas OpenImageDenoise. Denoising désactivé, rendu CPU effectué à 48 échantillons. Certaines captures Blender gardent du grain de rendu ; les captures Godot n'utilisent pas ce rendu Monte Carlo. Le GLB n'est pas compressé Draco : le message du plugin Blender sur cette bibliothèque optionnelle n'a pas empêché l'export non compressé, vérifié après coup.

## Temps et coût

Le début du travail est enregistré à **2026-10-12 23:58:32 UTC**. L'heure de scellement du pack et la durée réelle de cette session figurent dans `provenance.json`. Cette durée comprend interprétation, écriture des scripts, reprises, rendus et vérifications ; elle ne constitue ni un tarif, ni une promesse pour les assets suivants.

Mesures des trois constructions sur cette machine : **49,43 s, 54,55 s et 78,59 s** jusqu'à la géométrie/audit. La troisième partageait des ressources CPU avec les rendus. La dernière série de six rendus Blender FHD prend **251,03 s**. Il faut ajouter l'écriture du code, l'export, les imports et l'inspection des images : le temps de calcul du script seul sous-estime fortement le coût de production.

**Zéro crédit Tripo/Meshy et zéro appel de génération 3D payant pour ce POC.** Le calcul, la conversation et les retouches ont néanmoins un coût. Je n'ai pas accès au coût facturé de cette session et ne le convertis pas fictivement en euros.

## Ce qu'il reste pour une production de qualité

- Valider ou ajuster la silhouette, le gabarit et la taille à l'écran avec le propriétaire.
- Reprendre artistiquement les textures : contours, contraste, patine contrôlée, variations cohérentes ; éviter simplement d'ajouter du bruit.
- Améliorer des détails ciblés : moulures, faîtage, dôme/finial, vitrine et végétation décorative. Le script actuel génère des bouteilles et plantes très simplifiées.
- Définir UV/atlas/matériaux communs au kit, LOD, budget de surfaces et collisions simples. Le regroupement des pièces ne suffit pas pour une ville entière.
- Distinguer des gabarits vraiment raccordables des composants simplement séparés. Le placement de cette façade reste en partie codé pour cet asset précis.

Je ne peux pas mesurer un « travail manuel restant » réellement exécuté par un artiste qui n'est pas intervenu. Pour cadrer un budget, prévoir encore **quelques heures de reprise ciblée** avant de qualifier ce bâtiment de final ; **2–6 h** est une hypothèse de planification, pas un devis ou la garantie d'atteindre le concept. Une direction artistique plus exigeante peut dépasser largement cette plage.

## Rentabilité par catégorie

| Catégorie | Ce que ce POC permet de dire | Choix conseillé |
|---|---|---|
| Architecture régulière / kit | Géométrie complète et modules effectivement produits ; finition artistique encore insuffisante | Blender utile pour structure, raccords et variantes ; valider un maître avant série |
| Bancs, panneaux, caisses, conduites | Formes compatibles avec les outils employés ; pas d'essai individuel de qualité finale dans ce lot | Bon candidat au procédural ; ne pas payer une génération par variante simple |
| Végétation | Seulement petites jardinières très simplifiées ici ; aucune preuve sur arbre animé optimisé | Génération spécialisée ou base autorisée à évaluer, puis optimisation |
| Rochers, falaises, terrain | Pas de rocher/falaise cible reproduit dans ce test | Blender pour topographie/continuité ; IA sélective pour silhouettes organiques |
| Personnages et animation | Aucun avatar/rig humain produit ou validé par cette boutique | Préserver le candidat Meshy/Tripo ; rig et déformations à tester séparément |

Pour plusieurs dizaines d'assets **de la même famille**, les composants/scripts/textures peuvent amortir le travail initial. Une déclinaison limitée après gabarit validé pourrait demander **20–60 min** d'adaptation technique, estimation à mesurer. Un bâtiment d'une autre famille peut exiger une nouvelle interprétation et **2–6 h ou plus** ; la peinture finale ajoute une charge propre. Il ne faut pas extrapoler « le script tourne en une minute » à cinquante créations artistiques abouties.

À titre de cadrage, 30 variantes très proches à 20–60 min représentent 10–30 h d'adaptation, hors création du maître et retours artistiques. 30 bâtiments distincts à 2–6 h représentent 60–180 h avant finition. Ce sont deux périmètres différents et des simulations, pas des délais constatés. Aucune conversion fictive en crédits ou en euros.

## Décision recommandée

**Conserver une stratégie hybride.** Utiliser Blender/Codex pour les éléments réguliers, les raccords, les déclinaisons et l'intégration. Garder Tripo/Meshy comme candidats pour les objets organiques, personnages et bâtiments singuliers dont une bonne génération ferait gagner du temps.

Ce POC ne compare pas un export Tripo réel au modèle Blender : je ne peux pas affirmer que Tripo sera moins cher ou meilleur pour cette boutique. Il démontre une alternative technique autonome, et révèle aussi que la finition graphique reste le facteur limitant. Le prochain choix doit comparer un export spécialisé du même concept au présent résultat, avec son coût de génération ET de reprise.

Il n'y a pas lieu de changer Godot sur ce résultat : le fichier s'affiche dans le moteur utilisé, avec textures, modules et captures réelles. Une décision de production graphique reste distincte de cet import réussi.
