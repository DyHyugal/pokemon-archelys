# Bilan de reprise — 11 octobre 2026

## Livré dans la branche de travail

Réponses Q intégrées, propositions de scénario complet/casting/Soul-link ; questionnaire complémentaire de 51 questions, réponses en colonne C jaune. Plan de développement et architecture du laboratoire.

Projet Godot 4.6.3 : petite zone 3D procédurale, caméra contrôlée, déplacements et collisions logiques, mannequin original Blender 4.3.2 exporté GLB avec rig et animation, UI de test, campagne factice et porte de regroupement, ENet localhost, sauvegarde JSON vérifiée avec copie précédente.

Le simulateur de tour est volontairement minimal. Les règles complètes 9G, profils IA Tactica, raids, inventaire, captures, récit et Soul-link ne sont pas développés. Les valeurs de HP/cap ne sont pas des décisions de gameplay final.

## Preuves locales

- Import projet et exécution de la scène réussis.
- 19 contrôles de domaine : gate, caps, roster, save valide/corrompue/backup, identités/positions, collisions, ordre d’action, KO, commande unique, friendly fire et abandon.
- GLB : sept os et une animation, lecture exercée dans Godot.
- Scène : avatar, entrée clavier, mouvement autoritatif, UI combat et save/load exercés.
- Trois processus distincts : chaque processus observe trois participants et l’ouverture de la porte commune. Aucun essai entre PC/Internet à ce stade.
- Capture réelle via Xorg dummy + Mesa llvmpipe. Pas une image générée présentée comme rendu du jeu. Pas de mesure représentative d’un GPU joueur.
- Archives moteur et templates officielles vérifiées SHA-512. Export Windows créé ; runtime Windows non testé ici.

## Restant à valider

Choix de reprise des raids officiels, rattrapage des nouveaux joueurs et total des combats divins. Approbation du scénario/casting/règles Soul-link. Rendu final, LAN réel/Internet et distribution Windows en playtest. Aucun planning garanti déduit du laboratoire.

## Prochaine session

Lire le questionnaire et les trois propositions ; essais owner de l’export si disponible ; décider les règles structurantes ; choisir une petite référence artistique et le premier lot Pokémon avant mapping détaillé. Ne pas partir directement sur la fabrication de toutes les îles ou 500 modèles.

Les travaux sont conservés dans Git. Aucune activité autonome future n’est garantie après la fin de la session de l’assistant.

[Capture réelle du laboratoire](validation/laboratoire.png), [logs des contrôles](validation/prototype-checks.log) et [preuves structurées](validation/evidence.json).

## Publication confirmée

[CI GitHub réussie](https://github.com/DyHyugal/pokemon-archelys/actions/runs/38105074345) pour le commit 09897ca. Les contrôles, export Windows et publication ont terminé avec succès.

[Prerelease laboratoire](https://github.com/DyHyugal/pokemon-archelys/releases/tag/lab-09897ca) et [ZIP Windows](https://github.com/DyHyugal/pokemon-archelys/releases/download/lab-09897ca/Archelys-Laboratoire-Windows.zip). Archive distante téléchargée et vérifiée : SHA-256, CRC et manifeste de l’exe. Cela ne constitue pas un test d’exécution Windows.

La CI mentionne la transition des actions Node 20 vers Node 24 ; ce sont des warnings, pas des échecs. La mise à jour de ces actions pourra être traitée avec les dépendances, sans prétendre nécessaire une nouvelle architecture.

Git HTTPS permet de pousser ; l’API GitHub répond 403 depuis cet environnement. La branche docs/cadrage-valide est prête à revue mais n’est pas fusionnée dans develop ; aucune PR n’a pu être créée par cette API. Les sources et la prerelease sont accessibles indépendamment de cette intégration.
