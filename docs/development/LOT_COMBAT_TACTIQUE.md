# Bloc11 — protection, zones et soutien

Suite autorisée par D54 sans playtest intermédiaire. Trois sous-blocs forment une seule livraison ; confort10 reste à tester. Exigences Q15/N27 : mécanique officielle sur un catalogue provisoire, pas raids ni réseau.

## Portée et critères

Abri (priorité4) protège son utilisateur des attaques/status/baisses adverses pour le tour, pas des dégâts de poison/climat. Réussite initiale sauf si le lanceur agit en dernier ; répétitions divisées par3 jusqu'à1/729 ; échec/autre attaque/changement réinitialisent la chaîne. État indexé par UID, effacé après combat et jamais enregistré dans les Pokémon.

Surf atteint les deux adversaires et l'allié présent ; Éboulement et Tranch'Herbe seulement les adversaires. Rugissement/Mimi-Queue atteignent aussi les deux adversaires. PP et vérification d'aptitude à agir une fois par attaque ; précision, critique, immunité, statut/peur et baie calculés séparément pour chaque cible. Réduction0,75 sur les dégâts de zone si plusieurs cibles vivantes sont présentes avant l'attaque, y compris les cibles protégées/immunisées. Avec un seul adversaire présent, Éboulement retrouve sa puissance entière. Les attaques individuelles permettent de choisir l'allié, sans possibilité de se viser soi-même.

Coup d'Main (priorité5) augmente la puissance de l'allié de50% pour le tour, échoue en simple ou après l'action de cet allié ; ne sert pas à contourner les PP ou à faire jouer un acteur deux fois. Les effets transitoires sont vidés à la fin du tour. Terrain Psychique ne bloque que les priorités adverses, pas le soutien ni l'attaque volontaire de son allié.

Les formes et équipes existantes gardent leur identité et leurs anciennes attaques. Quatre nouvelles attaques, noms FR/EN, puissance/PP/précision/priorité et compatibilités CT proviennent du même commit PokéAPI contrôlé par SHA256. L'ajout d'Abri permet aussi son apprentissage naturel pour la famille de Carapuce ; aucun Pokémon déjà sauvegardé n'est rééquipé automatiquement. Format5 inchangé, aucune migration ni nouvelle dépendance.

## Essai et interface

F3 → Essai zones / Abri / soutien. Tortank, Florizarre, Dracaufeu niveau50 temporaires, adversaires Rattatac/Raichu50. Ce bouton initialise une aventure séparée ; aucun Pokémon ni objet n'est donné à la campagne. Affichage ESSAI SANS SAUVEGARDE, boutons une fois par attaque de zone avec avertissement « adversaires ET allié », cibles distinctes pour les attaques individuelles. Sortie « Terminer l'essai sans changer la partie » ; un essai relancé restaure son équipe. Défaite, gains, Pokédex et fin de combat ne déplacent ni ne modifient la véritable campagne. Sauvegarde/autosave bloquées pendant le combat.

Les mêmes règles s'appliquent aux vrais combats simple/double hors arène d'essai, aux deux camps ; CT enseignables depuis le résumé selon la compatibilité de l'espèce. Le rendu des combats reste textuel et provisoire.

## Sources consultées le 11 octobre 2026

- [Abri](https://www.pokepedia.fr/Abri) : priorité, protection et probabilité successive.
- [Surf](https://www.pokepedia.fr/Surf) : tous les Pokémon adjacents depuis les générations modernes.
- [Éboulement](https://www.pokepedia.fr/Éboulement) : adversaires adjacents,30% d'apeurement.
- [Coup d'Main](https://www.pokepedia.fr/Coup_d%27Main) : soutien, priorité et puissance50% pour le tour.
- [Référence PokéAPI épinglée](../../game/data/pokemon/reference.json) : paramètres/compatibilités, import reproductible `tools/import_laboratory_catalog.py`.

## Vérification et limites

46 contrôles de domaine et16 de scène vérifient les comportements et véritables boutons : PP unique, protection/status/résiduels/répétitions, fixtures indépendantes de dégâts72/54/81, précision indépendante, ciblage symétrique des ennemis, protection d'une cible sans annuler les autres, KO simultanés et récompenses uniques, priorité Abri/Coup d'Main, refus des commandes invalides, sortie/défaite sans mutation de campagne. Suite précédente réexécutée par `tools/check_prototype.py`. Preuve dans `validation/tactics-checks.log`.

Sous-ensemble de combat : pas toutes les capacités contournant Abri, pas toutes les subtilités d'arrondi officiel, pas de redirection, pas de choix d'objets en double, pas d'IA double avancée, pas de raids. Les talents et interactions non présents dans le catalogue ne sont pas simulés. Équilibrage et retour Windows/graphique restent à faire ; ne pas conclure « moteur9G terminé ».

Validation locale finale : `tools/check_prototype.py` entièrement réussi,283 assertions de domaine/services au total dont46 nouvelles,16 nouvelles vérifications de scène et parcours antérieurs conservés. Export Windows réussi ; trois vues du PCK exporté réellement lancées sous Godot/Linux et inspectées (zones, soutien, anglais, texte24). Captures dans `validation/tactics-area.png`, `tactics-support.png`, `tactics-english.png`. Avertissement V-Sync du pilote Mesa de rendu virtuel, sans erreur de script ; ce contrôle ne remplace pas un lancement Windows ni un playtest owner.
