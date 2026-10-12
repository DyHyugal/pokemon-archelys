# Vérification D71 — dix systèmes solo

Source : `d942a08`, branche `docs/cadrage-valide`, 12 octobre 2026. Source poussée sans nouvelle branche ou fusion.

- Suite complète locale passée ; contrôles services 29/0 échec et bridge Showdown74/0 échec.
- GL Linux : services33/0 échec, trois captures de menus et un export photo PNG réel. Captures inspectées ; cadrage initial démo ajusté, position/caméra restaurées.
- Régression photo/personnage/thèmes du laboratoire :13/0 échec après adaptation de la photo de démo.
- Import GLB original dans un répertoire temporaire : géométrie/empreinte/provenance vérifiées, PNG et paramètres invalides refusés sans mutation du registre. Aucun asset Meshy réellement testé.
- Sonde export officiel Linux release avec PCK du jeu : Showdown répond, template=true et chemin de runtime correct.
- ZIP Windows local intègre, EXE officiel inchangé, Node officiel vérifié ; extension Œuf Chance explicitée dans la provenance.
- [CI complète réussie](https://github.com/DyHyugal/pokemon-archelys/actions/runs/38302672779) : suite, export Windows, packaging et publication.
- [ZIP publié](https://github.com/DyHyugal/pokemon-archelys/releases/download/lab-d942a08/Archelys-Laboratoire-Windows.zip) avec SHA256SUMS sur la release.

Les nouveaux contrôles couvrent états sauvés/chargés, règles, refus en combat, usage et équipement, absence de dépense sans effet, cadeau unique/éclosion, fossiles, photo, pêche réelle et climat/terrain. Le laboratoire conserve sa campagne.

Windows et manette physique non exécutés ici ; B manette simulé seulement. Catalogue22espèces et starters demeurent fixtures. Textures chromatiques, modèles supplémentaires, animations d’attaques et production finale de l’archipel restent distincts. Graphismes de maquette rejetés comme résultat final, concepts approuvés conservés, Meshy attendu. Dernier playtest Windows fonctionnel explicitement validé : D52.
