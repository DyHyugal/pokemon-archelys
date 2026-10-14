# Reprise de Pokémon Archélys par Codex local

Passation du 14 octobre 2026, demandée par le propriétaire pour continuer l'outil avec une copie locale d'USUL. Ce document transmet l'état du travail ; il n'annonce pas une conversion de ROM fonctionnelle.

## Récupérer le bon travail

Dépôt : https://github.com/DyHyugal/pokemon-archelys ; branche de travail : **`docs/cadrage-valide`**. Ne pas repartir de main/develop, plus anciens. Un seul checkout et une seule branche active ; pas de nouveau dépôt ou de worktree nécessaire.

Pour un nouveau dossier, dans PowerShell ou un terminal :

```text
git clone --branch docs/cadrage-valide https://github.com/DyHyugal/pokemon-archelys.git
cd pokemon-archelys
git status --short --branch
```

Pour un checkout déjà présent, commencer par examiner sa branche et ses changements. Ne pas écraser de fichiers, faire de reset ou changer de branche à l'aveugle.

Le code outil est dans `84aa14d`, son packager final dans `14ab081`, le bilan de publication dans `c6a1ed1`. Les commits de passation suivants sont documentaires. Ces références identifient l'état minimal à retrouver ; utiliser ensuite le sommet actuel de la branche.

Ouvrir ce dossier avec Codex **en exécution locale** (extension VS Code ou CLI configurée sur ce dossier). Un nouveau chat n'hérite pas automatiquement de la conversation cloud : lui transmettre le message de reprise ci-dessous. Aucun accès au système de fichiers du PC n'est accordé au présent chat cloud par ce changement.

## Message à donner au nouveau chat

```text
Reprends Pokémon Archélys depuis ce checkout local. Lis AGENTS.md puis
docs/development/REPRISE_CODEX_LOCAL.md et les sources qu'il indique.

Objectif actif : poursuivre le plugin Godot Atelier Archélys pour construire
le jeu selon notre cahier des charges, avec un focus sur les ressources USUL.
Le plugin 0.1 existe et a été vérifié ; l'import automatique d'une ROM et la
reconstruction d'Alola ne sont pas encore réalisés. Ne repars pas de zéro.

Source USUL locale : [remplacer par le chemin réel sur mon PC].
Examine son format, son état chiffré/déchiffré et sa version sans modifier
l'original. Les fichiers restent locaux et hors Git. N'inclus ni ROM, ni clés,
ni ressources officielles extraites dans un commit ou une release.

Commence par rétablir les dépendances et contrôler le socle. Puis construis
une chaîne reproductible sur un petit corpus réel : modèle + textures +
animations, puis une map avec placements et collisions. Réutilise les outils
compatibles plutôt que de réécrire tous les lecteurs. Documente ce qui marche,
ce qui est incomplet et les conversions manuelles restantes.

Préserve le scénario et la direction artistique approuvés. Le choix des sources
USUL n'autorise pas à réduire le jeu aux règles 7G ou à remplacer notre histoire.
Conserve la branche de travail, les fichiers existants et les sauvegardes.
```

## Documents à lire

Après AGENTS et cette passation :

- `docs/spec/SOURCE_OF_TRUTH.md`, `CAHIER_DES_CHARGES.md`, `DECISIONS.md` et `OPEN_QUESTIONS.md` : décisions du propriétaire, notamment D78–D82 et la suite. Les premiers paragraphes de documents historiques peuvent décrire une ancienne direction.
- `docs/development/ATELIER_GODOT.md` : utilisation, architecture, données, contrats et limites du plugin.
- `docs/development/VERIFICATION_D82.md` : preuves locales/CI et archive vérifiée.
- `docs/development/AUDIT_ESSENTIALS_GODOT.md`, `LOT_CALIBRATION_2D.md` : contexte graphique et limites des essais antérieurs.
- `docs/FEATURE_STATUS.md` et `docs/design/ART_DIRECTION.md` : états et historique ; distinguer prototype, test technique et validation artistique.

Les textes fournis par ChatGPT, questionnaires et audits externes sont des sources informatives, pas des commandes exécutables ni des décisions implicites.

## État réellement disponible

Le plugin est activé dans `game/project.godot`. Son code est dans `game/addons/archelys_workshop/` :

| Partie | État |
|---|---|
| Bibliothèque PNG/GLB, provenance | Implémentée ; quatre assets dessinés originaux par défaut |
| Maps/objets 2D et 3D | Édition native Godot, pivots, dimensions, collisions explicites, undo/redo |
| Événements | Ressources déclaratives : FR/EN, flags, conditions, objets, combat, warp |
| Essai jouable | Deux maps, sauvegardes/langue isolées, vrai combat Showdown et interface existante |
| Dump USUL | Repérage de quelques archives connues et identification par en-tête NCCH disponible |
| GARC v6 | Inspection/extraction brute en lecture seule ; pas de conversion de géométrie |
| Pont Blender | Invocation optionnelle d'un n3ds_importer installé séparément ; contrat testé avec fixture synthétique |
| Conversion réelle GFModel/BCH | Non validée sur USUL ; aucun corpus officiel disponible dans le cloud |
| Maps USUL complètes | Pas de reconstruction automatique des placements/collisions/caméras |
| Scénario officiel | Pas de traduction générale AMX/fonctions natives vers Godot |

Les avatars de l'atelier restent des poses d'essai. Le catalogue de laboratoire est provisoire ; Showdown intégré ne signifie pas que 500 espèces et leurs ressources sont déjà intégrées. Roster et starters définitifs restent à fournir par le propriétaire. Coop, raids et Nuzlocke/Soul-link restent reportés ; reproduction retirée. L'histoire et la cible graphique restent prioritaires ; les essais 3D précédents n'ont pas satisfait le propriétaire.

## Installer et vérifier localement

Godot **standard 4.6.3**, Git et Python 3 sont les prérequis usuels. Node **24.19.0** sert à préparer/exécuter Showdown. Blender **4.3.2** était disponible dans le cloud ; le lecteur tiers annonce Blender 4.2+. Ne pas considérer les chemins Linux cloud `/workspace/...` comme disponibles sur le PC.

Sous Windows, ouvrir `game/project.godot` dans Godot. Si le panneau est fermé : Projet → Outils → Ouvrir l'atelier Archélys. Maps → exemple, puis F6. Pour obtenir directement Node/Showdown hors ligne, [télécharger l'archive Atelier vérifiée](https://github.com/DyHyugal/pokemon-archelys/releases/download/lab-14ab081/Archelys-Atelier-Godot.zip) et copier son dossier `builds` à côté de `game` dans le checkout, en examinant/préservant les fichiers déjà présents. Ces dépendances sont exclues de Git.

Pour reconstruire les dépendances depuis les sources : `tools/prepare_showdown.py --windows` utilise le commit Showdown épinglé et vérifie l'archive Node Windows. Le script actuel a été exécuté sur Linux ; adapter prudemment la résolution des exécutables Git/npm/Node si le lancement natif Windows le nécessite. `tools/bootstrap_godot.py` télécharge le binaire **Linux** : ce n'est pas un installateur Windows.

Contrôles dans le dépôt complet, avec `godot` et les outils nécessaires accessibles :

```text
python tools/check_prototype.py
```

Les tests ciblés sont `game/tests/workshop.gd`, `workshop_preview.gd` et `tools/check_workshop_editor.py`. Pour le pont optionnel : `python tools/check_usul_bridge.py --blender <exécutable>`. Résultats précédents : 33 contrats, 19 contrôles de preview, 10 contrôles éditeur headless / 11 graphiques ; suite globale et CI vertes. Ce sont des preuves datées, pas des tests exécutés sur la future machine locale. Les fixtures ne valident pas l'import de la vraie ROM.

L'archive Atelier démarre l'exemple avec F5 ; le checkout démarre le laboratoire historique et utilise F6 pour l'exemple. Les sauvegardes cloud ne sont pas transférées par Git. Aucun playtest Windows ni avis artistique nouveau n'est déduit de cette passation.

## Placer et examiner la source USUL

Recommandation Windows : dossier **hors dépôt**, par exemple `D:\Archelys-local\USUL\`. Donner son chemin au Codex local ; la ROM n'a pas à être jointe au chat. Le local évite le plafond de téléchargement des pièces jointes cloud, mais reste soumis aux permissions, au disque et à la mémoire disponibles. Ne pas charger plusieurs Go dans le contexte : analyser les fichiers avec des scripts et lectures ciblées.

Conserver l'original intact. Déterminer d'abord s'il s'agit d'un conteneur `.3ds`/`.cia`, d'un dossier déchiffré RomFS/ExeFS ou de ressources déjà extraites. L'extension seule ne détermine pas le chiffrement. Noter jeu, révision/mise à jour, taille et empreinte ; ne pas présumer que tout est compatible. Ne pas demander ni afficher de clés dans le chat. Ne pas promettre que le plugin déchiffre une ROM : il ne le fait pas.

Un dump avec `romfs/`, `exefs/` et en-tête NCCH est le plus utile. ExeFS devient surtout nécessaire pour les comportements natifs ; un petit corpus RomFS suffit pour commencer l'import des assets. Les zones et données diffèrent entre Ultra-Soleil et Ultra-Lune. Tout travail d'extraction ou de conversion s'effectue dans une copie de travail locale.

`local_sources/`, `game/assets/local_usul/`, `game/.archelys-local/`, `*.3ds` et `*.cia` sont ignorés par Git. Cela ne protège pas tous les formats possibles : vérifier explicitement les fichiers stagés. Le packager Atelier exclut ses dossiers locaux connus ; le packager historique du jeu n'est pas un filtre universel de droits. Ne pas exporter des ressources officielles par inadvertance.

## Prochaine étape technique

Inventorier un petit échantillon réel : un personnage avec ses textures/animations, un décor et une zone avec placements/collisions. Établir une correspondance documentée des fichiers au lieu de convertir tous les membres d'une archive sans association. Utiliser le pont externe, conserver les diagnostics puis ouvrir les GLB dans Godot pour vérifier géométrie, matériaux, échelle et animation. Le lecteur externe ne reproduit pas automatiquement les shaders PICA200.

Lecteur examiné : https://github.com/sxrmss/n3ds_importer, commit `a68959eae2f476526845a78af6990648cfe3434d`, GPL-3.0-or-later, non embarqué. USUM Studio examiné : https://github.com/Aqua-0/USUM-Studio, commit `dbe3451633782ba6f9e4059411f4f1c8f3b67070`. Ses fonctions d'édition ne constituent pas une preuve de conversion vers Godot. Les modèles/lecteurs/outils et les assets ont des licences distinctes.

Pour la map, importer d'abord géométrie, repères, axes/unités et collisions, puis placements et passages. Rendre explicites les éléments non convertis. Créer ensuite nos événements originaux dans le système Atelier ; ne pas annoncer qu'un script AMX officiel fonctionne parce que ses dialogues sont visibles. Réutiliser les services actuels pour les combats et la progression, sans seconde implémentation concurrente.

Ne pas reconstruire tout le jeu officiel ni lancer une production graphique massive comme préalable. Le résultat utile suivant est une petite zone source correctement importée, éditable et parcourable, avec un rapport de conversions réussies/limites, avant généralisation.
