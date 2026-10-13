# Vérification D81 — calibration 2D

Exécuté le 14 octobre 2026, Godot 4.6.3.

- `calibration_scene.gd` : 39 contrôles headless, 46 graphiques avec captures et comparaison de pixels, aucun échec après correction des coordonnées de la région capturée (canvas logique versus FHD). Assertion de mouvement du feuillage maintenue.
- `drawn_demo.gd` : 61 contrôles headless / 68 graphiques, aucun échec. La carte locale a été adaptée aux éléments modulaires ; pas de recherche d’un faux `modular.png`.
- Suite complète `tools/check_prototype.py` réussie localement. Export/paquet final et CI : résultats à consigner après exécution.

La vitesse est vérifiée sur les deux axes et la diagonale, en marche/course et ×1/×4 à 15/30/60 FPS. Les shaders sont vérifiés sur leur résultat rendu, pas seulement sur leurs paramètres : eau et couronne changent, réduction des mouvements fige leurs pixels, lave-preview bouge. Tri aux pieds et accès avant/arrière arbre, maintien du domaine/sauvegardes vérifiés.

Captures dans `calibration/` : parcours, avant/arrière arbre et aperçu lave avec grille. Pas de benchmark matériel Windows ni validation artistique owner acquise. Sources, limites et parcours propriétaire dans LOT_CALIBRATION_2D et LIRE-MOI.
