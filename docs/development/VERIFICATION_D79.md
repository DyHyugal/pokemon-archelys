# Vérification D79 — démo 2D dessinée

Contrôles locaux exécutés le 13 octobre 2026 avec Godot 4.6.3 :

- `tools/check_prototype.py` : suite complète du socle réussie, incluant le nouveau parcours dessiné et les régressions des anciens modes.
- `game/tests/drawn_demo.gd` : 61 contrôles headless, aucun échec.
- Même parcours avec Xvfb/llvmpipe et captures FHD : 68 contrôles, aucun échec après correction des attentes de fin de frame. Les assertions restent identiques : mouvement visible et suppression effective du marqueur/collider.
- Captures : havre, maison, Centre, boutique, sac, sentier et combat. Les positions de l'infirmière et des portraits ont été corrigées après inspection des images.
- Export Windows local réalisé ; le paquet exporté passe aussi les 61 contrôles du parcours. Livraison publique et CI du commit final à consigner après publication.
- La première CI (`38471307566`, commit `6ded144`) a échoué sur l’assertion PP : son adversaire Pikachu pouvait empêcher une attaque par statut. Fixture remplacée par Magicarpe, sans neutraliser les règles du simulateur ni retirer l’assertion. La consommation d’un PP doit toujours être observée après une possibilité d’agir sans interruption.

Les contrôles de connectivité globale/passages concernent les collisions réellement utilisées ; un service visible mais inapprochable échoue. L'attaque observée consomme exactement un PP dans le vrai simulateur Showdown. Les sauvegardes graphiques sont isolées ; la campagne atelier ne change pas.

Anciennes zones canopée/sources/poste explicitement hors de ce lot. Héros et portraits fixes ; fonds précomposés. Aucun playtest Windows ou benchmark propriétaire déduit des résultats Linux. Voir LOT_2D_DESSINEE et LIRE-MOI.
