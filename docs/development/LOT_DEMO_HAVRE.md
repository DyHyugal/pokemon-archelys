# Démo du havre — D69

Demande owner du 12 octobre 2026 : monde, graphismes et services réunis dans une démo jouable d'une portion de la première île. Référence graphique : personnages Pokémon DS/USUL, décor net en FHD, concepts D67 approuvés. Autonomie autorisée, propositions à ajuster après playtest ; aucune validation visuelle implicite.

## Livraison

Une ville tropicale avec façades crème, toits turquoise, arcades, horloge, port et terrasses ; un sentier ; trois intérieurs (Centre, boutique, maison). Choix unique Bulbizarre/Salamèche/Carapuce niveau6, provisoire pour la démo. Avatar animé remodélisé à11os, personnalisation avec aperçu3D. PNJ, dialogues manuels, balise, défi de dresseur, conclusion auprès de Vyna. Rencontres sauvages, captures, soins, achats confirmés, sac/équipe/PC. Combats réellement simulés par Showdown avec arène3D, commandes et barres de PV.

Sauvegarde autonome `archelys-demo-v1.json`, copie précédente `.backup`, aucune conversion des anciennes parties. L'atelier reste accessible. Préférences locales communes (langue, caméra, confort), campagne distincte. Le programme exporté ouvre directement l'accueil de la démo.

## Showdown

Cause identifiée : recherche du runtime avec l'ancien indicateur `standalone` au lieu de `template` de Godot4. L'export recherche maintenant bridge et Node à côté de l'exécutable. Erreurs distinctes pour fichiers absents, lancement refusé et équipe sans combattant apte ; journal `user://showdown-diagnostic.log`. Le dossier complet reste nécessaire. Aucun changement de version Showdown ni de licence.

## Assets et limites

11GLB originaux générés dans Blender4.3.2, sources dans `art/source/demo`, script `tools/create_demo_assets.py`, empreintes dans `game/assets/demo/provenance.json`. Géométrie originale ; designs et noms Pokémon restent les droits de leurs titulaires. Aucun modèle officiel extrait. Ancien kit conservé dans l'atelier.

Ce rendu est un premier passage, pas encore la qualité finale demandée : personnages, végétation, modèles Pokémon et détails des décors requièrent une poursuite artistique. Les animations d'attaques finales et l'ensemble de l'île ne sont pas livrés. La fidélité détaillée aux illustrations n'est pas acquise. La résolution FHD ne constitue pas à elle seule une qualité DS modernisée. Génération limitée à cinq Pokémon visibles dans ce parcours. Les autres espèces de l'atelier restent disponibles avec leur présentation antérieure.

## Vérification

Parcours automatique réel dans `demo_scene.gd` (interfaces, starter, achats, soins, quête, combat, disque et isolation de l'atelier). Contrats dans `demo_contracts.gd` (refus des états incohérents, round-trip, sauvegarde atomique, équipe KO, runtime et requête réelle Showdown). Suite complète via `tools/check_prototype.py`. Captures du moteur dans Comparatifs. Export non-éditeur Linux vérifié séparément avec le même PCK et Node Linux ; cela ne remplace pas le lancement Windows propriétaire, ni une mesure de performance GPU.

Résultats locaux : suite complète réussie (`ALL PROTOTYPE CHECKS PASSED`) ; démo scène29 contrôles, contrats20 contrôles, rendu réel36 contrôles/7captures, tous sans échec. Export officiel Linux release avec le PCK Windows : sonde intégrée isolée `--demo-runtime-check`, retour0, `template=true`, `standalone=false`, requête réelle Showdown reçue et dossier runtime correct. Aucun playtest Windows effectué ici.

Contrôle ciblé additionnel : distance de caméra mémorisée appliquée à l’ouverture de la démo ; parcours scène30 contrôles/0échec après correction. Les captures36 contrôles précèdent uniquement ce réglage de reprise.
