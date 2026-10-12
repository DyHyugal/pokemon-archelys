# Vérification D69 — démo du havre

Source de livraison : `ea06c88`, branche `docs/cadrage-valide`, 12 octobre2026. Aucun merge main/develop ni nouvelle branche.

- Suite complète locale réussie, puis nouvelle exécution avec répertoire utilisateur neuf réussie.
- Parcours démo réel répété30fois avec combats Showdown : aucun échec.
- Contrats de sauvegarde/runtime20contrôles, sans échec.
- Sept captures du moteur en1920×1080,36contrôles sans échec ; mêmes modèles après correction ciblée de reprise caméra.
- Export officiel Linux release avec PCK du jeu, sonde isolée : code0, template=true, standalone=false, runtime trouvé à côté de l’exécutable, réponse réelle Showdown reçue.
- ZIP portable local vérifié : EXE officiel Godot inchangé, Node officiel vérifié, pack externe, archive intègre, version dans le LIRE-MOI et manifest. Nom EXE fixe.
- [CI de la livraison réussie](https://github.com/DyHyugal/pokemon-archelys/actions/runs/38256124102), export Windows et publication inclus.
- [ZIP Windows publié](https://github.com/DyHyugal/pokemon-archelys/releases/download/lab-ea06c88/Archelys-Laboratoire-Windows.zip), SHA256SUMS disponible sur la même release.

Deux exécutions GitHub précédentes ont échoué sur les contrôles sans détail consultable par cet accès public. Échec non reproduit localement, y compris avec données utilisateur neuves et30répétitions. Les sorties d’erreur sont désormais exposées en annotations CI ; cela améliore le diagnostic et ne désactive aucun contrôle. La dernière CI a passé toute la suite.

Windows, manette physique et performance GPU n’ont pas été testés dans cet environnement. Les captures llvmpipe Linux ne valident pas la qualité graphique finale. Dernier playtest Windows owner antérieur : D52. L’interface et le parcours sont développés ; la fidélité DS/USUL et le détail des concepts restent à poursuivre.
