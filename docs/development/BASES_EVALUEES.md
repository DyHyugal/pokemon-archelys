# Recherche initiale de bases Godot

Recherche GitHub du 11 octobre 2026. Inspection limitée aux fichiers ci-dessous ; aucun de ces projets n’a été installé ou validé fonctionnellement dans cette session. Il s’agit d’un premier tri, pas d’un audit complet de tous les frameworks.

| Projet | Élément réellement consulté | Observation |
|---|---|---|
| [arkeve/Godot-Pokemon](https://github.com/arkeve/Godot-Pokemon) | project.godot sur master | Format Godot 3, écran 240×160, layers de physique 2D ; pas une base 3D Godot 4 directement utilisable |
| [samsface/godot-pokemon](https://github.com/samsface/godot-pokemon) | project.godot sur master | Projet 2D 160×144, format Godot 3, classes Resource et Node2D ; migration nécessaire |
| [Project-Uranium-Godot](https://github.com/acedogblast/Project-Uranium-Godot) | README.md sur master | Se décrit comme partiellement jouable et demande les assets du jeu original ; aucune coopération 3D complète vérifiée |

Ces observations ne prouvent pas qu’aucun framework approprié n’existe. Reprendre un domaine de combat pourrait être utile après inspection du code, licence, tests et interfaces. Aucun code de ces dépôts n’est copié dans le laboratoire.

Décision technique provisoire : petit socle original sous Godot 4.6.3 pour vérifier réseau et pipeline 3D sans dépendre d’une migration de projet 2D. Ne pas réécrire aveuglément tout Pokémon si une bibliothèque testable et compatible peut servir ensuite. Le choix final reste conditionné par les essais et le périmètre.
