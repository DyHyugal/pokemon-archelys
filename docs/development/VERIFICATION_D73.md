# Vérification et livraison D73

12 octobre 2026, Europe/Paris. Source `8da0f6fbcf509086ce4d891ef8b3af9b4f2fbd41`, branche `docs/cadrage-valide`. Dix blocs : [portée et limites](LOT_DEMO_CANOPY_DIX_BLOCS.md). Pas de merge main/develop ni de branche supplémentaire.

## Contrôles exécutés

- `tools/check_prototype.py` : `ALL PROTOTYPE CHECKS PASSED`. Nouveau parcours de chapitre :90 contrôles, zéro échec dans la dernière exécution locale. Régressions D69–D72, Showdown78, menus, sauvegardes et ancien laboratoire réussies. Le nombre d’assertions du parcours peut varier avec les tours natifs ; les conditions de réussite ne sont pas assouplies.
- Même parcours en OpenGL Mesa llvmpipe, FHD :95 contrôles, zéro échec, cinq captures PNG. Avertissement VSync du pilote logiciel, aucune erreur script/moteur. Capture canopée, carte régionale, soleil en combat, poste et journal. Le test emploie une équipe renforcée pour vérifier le parcours, pas l’équilibrage ou les performances GPU Windows.
- Échantillon de100 rencontres avec graine fixée : conditions Magicarpe18–19 et Léviator20–22 vérifiées indépendamment du calcul de génération. Refus de sets illégaux, cap distinct pour le second responsable, dépendances/sauvegardes incohérentes.
- Source exportée en Windows ; présence de `res://data/demo/chapter.json` dans le PCK vérifiée. ZIP local :117227994 octets, intégrité vérifiée. EXE inchangé par rapport au template officiel vérifié, Node correspond au hash de provenance, PCK externe, nom fixe `Archelys-Laboratoire.exe`.
- PCK exporté exécuté avec le template Linux release : `ok=true`, `template=true`, `standalone=false`, erreur vide, Showdown résolu dans le dossier de distribution. Ce probe valide le lancement du simulateur du pack, pas un playtest Windows du chapitre entier.
- `git diff --check` et compilation des outils Python réussis.

## Publication

CI [38313303857](https://github.com/DyHyugal/pokemon-archelys/actions/runs/38313303857) **réussie** : contrôles, export, archive et publication automatiques. Release publique `lab-8da0f6f`.

[Télécharger la démo Windows](https://github.com/DyHyugal/pokemon-archelys/releases/download/lab-8da0f6f/Archelys-Laboratoire-Windows.zip). LIRE-MOI identifie la source et le parcours groupé.

## Reprise et test propriétaire

Reprendre la sauvegarde de démo existante, terminer la scène de retour si nécessaire puis reparler à Vyna : Continuer vers la canopée. Le LIRE-MOI contient un seul parcours pour les dix blocs. Vérifier les quatre combats, les relais, les différents points d’eau/chargement en Surf, les soins, le retour au Centre, la carte/Vol, la scène de rapport/reprise et l’absence de duplication après rechargement. Aucun test multi/raid/défi demandé.

Anciennes saves conservées : champ de chapitre facultatif, aucune progression nouvelle inventée ; paliers/visites/étapes sont persistés et validés, copies D72 inchangées. Une scène interrompue reste reprenable et la présentation principale doit être terminée avant le contrôle RR. La défaite et une interruption de Showdown ne complètent aucun boss.

Dernière validation fonctionnelle Windows owner reste D52. D73 ne valide pas les nouveaux graphismes, le scénario ou les noms, la durée du jeu, la conformité exhaustive9G ou l’équilibrage. Les modèles restent des maquettes, plusieurs Pokémon ont un modèle en attente, aucun export Meshy reçu. Le poste de contrôle proposé est une intervention locale RR : il ne remplace pas le repaire secondaire de fin d’île qui doit suivre la divinité selon N01. Divinité/raid, caldeira et libération restent à construire ; Pokédex et starters finaux attendus.
