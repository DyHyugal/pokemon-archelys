# Catalogue technique provisoire

13 espèces : familles Bulbizarre, Salamèche et Carapuce ; Rattata/Rattatac ; Pikachu/Raichu. 27 attaques prises en charge. Les trois membres initiaux niveau 8 constituent une équipe d'essai : aucune sélection de starters ou du Pokédex final. Aucun modèle, sprite, son ou code de combat tiers importé.

Statistiques, noms FR/EN, talents ordinaires, taux de capture, EXP de base, EV gagnés, types et apprentissages sont extraits des CSV PokéAPI. Référence vérifiée octet par octet : https://github.com/PokeAPI/pokeapi/tree/c80757193bd0889054e36f4209762360bdaa4b95/data/v2/csv . Les empreintes des 16 CSV de travail sont dans reference.json ; le catalogue embarqué est laboratory.json. Les familles disponibles en Écarlate/Violet utilisent le groupe 27 (Disque Indigo). Rattata/Rattatac utilisent leur dernier groupe disponible avant 9G parmi les groupes ≤20 ; ce choix est indiqué par espèce. L'apprentissage est limité aux attaques réellement implémentées, pas une liste complète de tous les sets officiels.

Licence source PokéAPI BSD à trois clauses : [notice](../../../docs/licenses/PokeAPI-LICENSE.txt), conservée aussi dans le ZIP Windows. Les noms et designs Pokémon restent ceux de leurs titulaires ; la licence des données n'est pas une autorisation d'importer leurs assets graphiques. Le dépôt n'a toujours pas de licence générale choisie par le propriétaire.

Table des 18 types, évolutions, natures et effets des attaques retranscrits pour ce lot. Le moteur vise les règles retenues au cahier ; le rapport du lot précise ses limites (notamment calcul de capture conventionnel et arrondis de dégâts, catalogue incomplet). Aucune revendication de conformité exhaustive 9G.

Régénération reproductible : `python3 tools/import_laboratory_catalog.py` depuis le dépôt. Le script télécharge les CSV à ce commit précis et vérifie toutes leurs empreintes avant de produire le catalogue. `--source-dir` permet de réutiliser un dossier déjà vérifié. Aucune dépendance Python supplémentaire.
