# Vérification D70 — exploration et sauvegardes

Source de livraison : `acc15be`, branche `docs/cadrage-valide`, 12 octobre 2026. Aucune nouvelle branche ni fusion main/develop.

- Suite complète locale passée après les changements (`ALL PROTOTYPE CHECKS PASSED`).
- Navigation et sauvegardes : 20 contrôles réussis, incluant récupération du fichier principal corrompu et conservation de la copie valide après sauvegarde.
- Contrats de démo/Showdown : 20 contrôles réussis.
- Rendu GL Linux : 19 contrôles du parcours et 3 captures PNG réussis avant l’ajout du dernier contrôle de conservation de copie. Captures inspectées ; carte locale avec libellés.
- Export Windows préparé, ZIP local vérifié, nom EXE fixe et modèle officiel Godot inchangé. Aucun asset Meshy ajouté.
- Sonde depuis l’export officiel Linux release utilisant le pack du jeu : Showdown démarre et répond, template=true, runtime à côté de l’exécutable.
- [CI complète réussie](https://github.com/DyHyugal/pokemon-archelys/actions/runs/38299048331) : contrôles, export Windows, packaging et publication.
- [ZIP Windows publié](https://github.com/DyHyugal/pokemon-archelys/releases/download/lab-acc15be/Archelys-Laboratoire-Windows.zip), SHA256SUMS disponible sur la release.

Sauvegarde historique de démo conservée au premier emplacement, enveloppe inchangée. Deux fichiers supplémentaires et copies .backup distinctes. Aucun changement des sauvegardes du laboratoire ni intégration du multi.

Windows et manette physique non exécutés ici. Graphismes primitifs conservés pour les tests de gameplay, explicitement rejetés comme résultat final par le propriétaire. La cible DS/USUL en FHD demeure à réaliser avec des assets adaptés ; les concepts approuvés restent la référence.
