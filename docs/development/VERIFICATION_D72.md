# Vérification et livraison D72

12 octobre 2026, Europe/Paris. Source : `a732c7c9f3500f195f95266753601800509f18ac`, branche `docs/cadrage-valide`. Aucun merge main/develop, aucune branche de développement supplémentaire.

Douze blocs : [portée détaillée](LOT_DEMO_PROGRESSION_SERVICES.md). Pokédex/starters finaux et premier export Meshy toujours attendus. Le lot demeure une démo de portion d’île, avec maquettes graphiques.

## Contrôles locaux exécutés

- `tools/check_prototype.py` : `ALL PROTOTYPE CHECKS PASSED`. Nouveau parcours intégré : 58 contrôles, zéro échec. Préflight de 22 espèces et huit cas de refus du contenu exécutés ; régressions Showdown (78 contrôles) et systèmes/menus antérieurs réussies. La fixture tactique et la sortie lors d’un remplacement obligatoire sont corrigées après l’échec de la CI 38306730975 ; 26 contrôles UI tactiques passent. Voir la reproduction documentée dans le rapport du lot.
- Même parcours en OpenGL llvmpipe, 1920×1080 : 63 contrôles, zéro échec ; cinq PNG réels. Avertissement VSync du pilote logiciel conservé, aucune erreur script/moteur. Capture/inspection effective de scène, sauvegardes, Pokédex, GLB et combat. Pas de mesure représentative de la RTX 4060 Ti.
- Export Windows réussi ; PCK externe et dépendances Showdown/Node offline conservées. ZIP local vérifié : 116728109 octets ; PE officiel Godot identique au template vérifié, Node identique au hash de provenance. Nom fixe `Archelys-Laboratoire.exe`.
- PCK compilé exécuté avec le template Linux release : diagnostic `ok=true`, `template=true`, `standalone=false`, erreur vide, Showdown trouvé dans le dossier de distribution. Cette vérification ne remplace pas une exécution Windows.
- `git diff --check` et compilation des outils Python réussis.

## Publication

CI de cette source : [38307537252](https://github.com/DyHyugal/pokemon-archelys/actions/runs/38307537252). **Réussie** : préparation, régressions, export Windows, archive et publication automatiques. Le ZIP et SHA256SUMS sont présents dans la release publique `lab-a732c7c`.

[Télécharger la démo Windows](https://github.com/DyHyugal/pokemon-archelys/releases/download/lab-a732c7c/Archelys-Laboratoire-Windows.zip). Le LIRE-MOI embarqué identifie la source a732c7c et détaille les tests groupés.

## Test propriétaire à regrouper

Le LIRE-MOI du ZIP détaille un parcours unique : Vyna/scènes, sentier/obstacles/relevés, professeur, Vol, services et PC sur place, Pokédex, sauvegardes séparées/export/import, combat. Les sélecteurs natifs de fichiers, ouverture du dossier, manette physique, performances et rendu Windows attendent le propriétaire. Aucun résultat Windows/artistique n’est déduit des demandes de continuation. Les lots D69–D71 restent à tester ensemble si nécessaire.

Les anciens fichiers de démo sont lisibles. Nouvelle partie/import synchronisent le fichier auto pour ne pas reprendre une campagne antérieure par erreur. Première sauvegarde manuelle du starter conservée ; ensuite les écritures automatiques vont dans `.auto` quand activées. Auto OFF exige une sauvegarde manuelle pour conserver les changements. Import confirmé préserve l’ancien fichier manuel valide en `.backup` ; les préférences globales de présentation restent indépendantes des archives.
