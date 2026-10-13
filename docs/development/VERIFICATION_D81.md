# Vérification D81 — calibration 2D

Exécuté le 14 octobre 2026, Godot 4.6.3.

- `calibration_scene.gd` : 39 contrôles headless, 46 graphiques avec captures et comparaison de pixels, aucun échec après correction des coordonnées de la région capturée (canvas logique versus FHD). Assertion de mouvement du feuillage maintenue.
- `drawn_demo.gd` : 61 contrôles headless / 68 graphiques, aucun échec. La carte locale a été adaptée aux éléments modulaires ; pas de recherche d’un faux `modular.png`.
- Suite complète `tools/check_prototype.py` réussie localement. Export local et paquet exporté : 39 contrôles de calibration réussis. CI finale et publication confirmées ci-dessous.

La vitesse est vérifiée sur les deux axes et la diagonale, en marche/course et ×1/×4 à 15/30/60 FPS. Les shaders sont vérifiés sur leur résultat rendu, pas seulement sur leurs paramètres : eau et couronne changent, réduction des mouvements fige leurs pixels, lave-preview bouge. Tri aux pieds et accès avant/arrière arbre, maintien du domaine/sauvegardes vérifiés.

Captures dans `calibration/` : parcours, avant/arrière arbre et aperçu lave avec grille. Pas de benchmark matériel Windows ni validation artistique owner acquise. Sources, limites et parcours propriétaire dans LOT_CALIBRATION_2D et LIRE-MOI.

## Livraison vérifiée

Source `a38481bad0025a1d1d4712cd3f99d72e4386022c`, branche `docs/cadrage-valide`. [CI 38480229995](https://github.com/DyHyugal/pokemon-archelys/actions/runs/38480229995) verte : validation `115580727675`, publication `115582631250`. La suite complète du socle a été exécutée sur le commit livré.

[ZIP Windows](https://github.com/DyHyugal/pokemon-archelys/releases/download/lab-a38481b/Archelys-Laboratoire-Windows.zip) entièrement lu et SHA-256 comparé au fichier publié :

- Taille : 505 875 137 octets.
- SHA-256 : `62bae1b926e6c1e6a4a9b5cf4b58e9a6aba860a58084f9c77e709cd69a58e633`.

Nom fixe `Archelys-Laboratoire.exe`, template officiel inchangé et PCK externe. Sauvegardes de calibration isolées. Main non modifiée. Validation artistique/Windows propriétaire à recevoir ; le téléchargement vérifié ne constitue pas ce playtest.
