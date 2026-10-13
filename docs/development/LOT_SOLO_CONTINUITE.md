# Lot solo : continuité, inventaire et préparation du catalogue (D76)

Propriétaire, 13 octobre 2026 : poursuite autonome des blocs disponibles, une seule livraison et un résumé final. Graphismes et Pokédex définitif seront repris avec lui ; aucun choix de roster ou nouveau scénario n'est effectué ici. Les 22 espèces et 43 attaques restent des fixtures.

## Huit blocs intégrés

| Bloc | Résultat | Vérification |
|---|---|---|
| Commandes de course | Maj devient reconfigurable ; RB permet de courir à la manette. Une ancienne touche Maj affectée à une autre action est conservée. | Événements clavier et manette injectés dans Godot ; reprise des anciennes préférences. |
| Vitesse globale | ×1–×4 est sauvegardé dans les préférences locales, partagé entre atelier et démo, restauré au redémarrage. L'ancien fichier de vitesse est lu sans être supprimé. | Changement via le vrai sélecteur, fermeture/réouverture, refus des valeurs invalides. |
| Cadeaux atomiques | Cadeaux, fossiles, relevés et caches utilisent un contrôle commun : si un stock dépasse 999, rien n'est donné ni marqué acquis. Le dialogue du coffre reflète réellement le résultat. | Sac plein, objet inconnu et lot valide ; refus sans perte ni faux drapeau. |
| Équipement et kit Méga | Un ancien objet ne disparaît plus si son stock de retour est plein. Kit Méga préparé sur copie et appliqué seulement si tout réussit, sans remplacer les références des individus existants. Capture refusée avant consommation si les identifiants sont épuisés. | Échec puis succès ; identité, sac et cap conservés en cas de refus. |
| Courbes d'EXP | Ajout des courbes Erratique et Fluctuante ; les six courbes officielles sont disponibles. | Seuils de référence et croissance des niveaux 1 à 100 ; aucune redistribution d'EXP des saves existantes. |
| Évolutions et choix | Le slot du talent est conservé à l'évolution si disponible. Les attaques du nouveau stade entre son seuil d'évolution et le niveau actuel sont proposées explicitement. Le menu montre les choix restants. Les EV de PV conservent les dégâts déjà subis. | Talent caché, évolution retardée, choix accessibles, évolution sans soin gratuit et gain d'EV PV. |
| Poison grave | Le statut toxique n'est plus aplati en poison simple lors de la sortie Showdown. Au combat suivant, le compteur de dégâts repart à zéro ; l'Antidote soigne les deux poisons. | Quatre contrôles avec le véritable simulateur Showdown, persistance JSON et soin hors combat. |
| Préparation du Pokédex | Audit en lecture seule des métadonnées : traductions, stats, types, talents, courbes, attaques et liens d'évolution. Les cycles/missing stages sont refusés et ne bloquent plus les parcours de généalogie. | 17 catalogues volontairement invalides rejetés ; catalogue courant intact et sans erreur. |

## Sauvegardes et dépendances

Campagne toujours au schéma 5 ; anciennes parties lisibles, aucun reset. Les préférences de vitesse et de touches sont locales au PC, indépendantes des parties. Le nouveau statut `toxic` est accepté dans les sauvegardes de ce build ; ne pas relire de nouvelles saves avec un ancien binaire ne le connaissant pas. Les originaux ne sont pas effacés par la migration des préférences.

Showdown conserve son commit épinglé `942cda71d14bf0618bd57991708a2e2734b6daba` et son code amont intact ; seul le pont Archélys change. Godot 4.6.3, Node et le dossier offline existants sont conservés. L'EXE Windows reste le template officiel non modifié, au nom fixe ; cette méthode n'est pas une nouvelle signature Authenticode.

## Contrôles exécutés

`tools/check_prototype.py` : suite complète réussie sous Linux. Nouveau test `solo_continuity.gd` : **50 contrôles, 0 échec**. Pont Showdown : **82 contrôles, 0 échec**, dont quatre nouveaux contrôles toxiques sur le simulateur réel. Contrats du catalogue : **17 erreurs réelles rejetées**, fichier d'origine inchangé. Ces résultats ne valent pas playtest Windows, test de manette physique ou validation exhaustive de toutes les interactions Pokémon.

Une première exécution complète avait échoué sur l'attente de messages de démarrage dans `comfort_scene`. Le test ciblé et la seconde exécution complète passent ; le message d'échec contient désormais le diagnostic et le démarrage est vérifié explicitement. La cause du premier échec n'est pas établie ; ne pas présenter cet événement comme un défaut corrigé avec certitude.

## Outils pour le futur catalogue

`python3 tools/check_pokemon_catalog.py` vérifie les métadonnées actuelles ; `--catalog chemin.json` contrôle un candidat et `--report rapport.json` produit ses erreurs. Il ne sélectionne ni ne corrige aucune espèce. Ce préflight vérifie la structure et les références, pas la conformité de chaque donnée au jeu officiel ou à Showdown. Le schéma actuel n'accepte qu'une branche d'évolution par espèce, par niveau ou objet : évolutions multiples, conditions spéciales et Fakemons nécessiteront un travail distinct après réception du Pokédex.

## Retour propriétaire attendu

Parcours unique en tête de `LIRE-MOI.txt` du ZIP : remappage de course, vitesse conservée après redémarrage, reprise de partie, sac/objets, combat et choix restants si présents. Ne pas remplir artificiellement le sac ni modifier les sauvegardes pour reproduire les limites déjà automatisées.

Graphismes et Pokédex reportés à la reprise. Combats Pokémon 2D, contenus définitifs, îles complètes et fin de campagne restent à produire ; multi/raids/Nuzlocke/Soul-link reportés et reproduction retirée.
