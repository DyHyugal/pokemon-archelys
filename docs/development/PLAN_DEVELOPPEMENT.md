# Ordre de développement

L’autorisation du 11 octobre 2026 permet de commencer la conception et les essais en autonomie. Le cahier est approuvé ; les propositions et les validations de rendu restent distinctes.

## 1. Socle et laboratoire — commencé

Architecture séparant domaine, services et présentation ; outils reproductibles ; projet Godot ; zone provisoire ; déplacement, caméra, modèle animé, sauvegarde et trois processus réseau. Vérifier rapidement ce qui est coûteux avant de produire la région.

## 2. Stabiliser les systèmes qui conditionnent tout le jeu

Règles de raids et rattrapage ; identités de campagne, progression et migrations ; données Pokémon, localisation, inventaire et résumés ; actions de combat Solo/Duo puis raids ; informations IA ; échanges et spectateur. L’objectif est une petite boucle fonctionnelle vérifiée, pas de couvrir immédiatement 500 espèces.

## 3. Éprouver la direction artistique

Comparer quelques rendus sur le même quartier : matériaux, caméra, éclairage, avatar, végétation et eau. Choisir le style et le niveau de détail avec le propriétaire. Vérifier pipeline Blender/glTF, rig, animations et budget performance. Le décor du laboratoire ne fixe pas le niveau graphique demandé.

## 4. Mapping de la première île

Plan des routes, villes, biomes, transitions, points d’intérêt et blocages ; graybox d’abord pour distances et exploration ; modularité des bâtiments ; remplacement progressif par assets validés. Ne pas produire la carte entière avant de contrôler un quartier représentatif.

## 5. Première boucle d’aventure

Prologue, PNJ, journal, première route, rencontres, capture, soins, boutique, arène/épreuve, boss et ouverture draconique. Version solo testable indépendamment ; coop sur les mêmes événements avec contrôles de regroupement. Réglages et progression comparés aux règles retenues de Tactica.

## 6. Extension par île

Chaque île reprend les systèmes éprouvés et ajoute ses biomes/événements propres. Revalidation des évolutions, caps, données et IA sur toute la plage de progression, pas uniquement la première rencontre. Retours draconiques construits au rythme des étapes.

## 7. Fin principale et postgame

Défi divin, repaire RR, libération du père et conséquences visibles ; portails célestes, huit arènes Ultra-Dimension, revanches, Tour de Combat et visiteurs mystère. Périmètre réévalué sans ajouter des années silencieusement.

## 8. Finalisation V1

FR/EN complets, playtests solo/coop, équilibrage, performances PC de référence, compatibilité save, documentation joueurs et publication. Windows exécutables, pas ROM. Ports autres après bilan V1.

## Cycle de travail

Une tâche → critères d’acceptation → courte branche de travail → tests adaptés et build si pertinent → mise à jour des preuves → PR vers develop → validation des jalons sur main. Une seule branche temporaire active par défaut. La branche actuelle réunit le cadrage et le laboratoire de cette session ; elle n’est pas encore fusionnée dans develop.

Le questionnaire restant contient des choix avant le système concerné ; ses 51 réponses ne sont pas toutes nécessaires pour déplacer un avatar dans le laboratoire. En cas d’inconnue, utiliser un comportement d’essai explicitement balisé, pas une règle finale supposée.
