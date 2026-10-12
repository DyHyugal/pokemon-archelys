# D66 — première île proposée, douze blocs regroupés

**SPOILERS DEV — proposition jouable, pas scénario ou graphismes approuvés.** Demande du propriétaire du12 octobre2026 : au moins dix blocs autonomes, première île construite en prototype sans attendre les validations. Ces noms et ce parcours peuvent être remplacés. Rien n'est présenté comme la V1 finale.

## Les douze blocs développés

| Bloc | Contenu livré | Critère de test |
|---|---|---|
| B01 Chapitre et sauvegarde | État d'île optionnel en campagne5, progression/dépendances, compatibilité anciennes parties | Sauver au milieu puis recharger sans perdre la quête ; données incohérentes rejetées |
| B02 Zones reliées | Havre, jungle, caldeira, galerie, sanctuaire, poste RR ; Centre/boutique intérieurs | Parcourir les panneaux sans téléportation arbitraire ni reset d'équipe |
| B03 Géométrie et collisions | Bâtiments, arbres, lave, limites et chemins latéraux ; règles communes aux mouvements | Chaque interaction accessible selon la grille des collisions ; lave non traversable |
| B04 Dialogues et arrivée | Vyna, habitant, botaniste FR/EN ; scène d'arrivée manuelle/rejouable | Arrivée vue avant contrôle RR ; habitant réagit à la libération |
| B05 Biomes et Pokédex | Herbes visibles, pools jungle/volcan/grotte du catalogue22/43, stades légaux, habitats dérivés | Rencontres cohérentes avec niveau ; pas forme item/échange forcée |
| B06 Combats de progression | Contrôle RR, gardien soleil/Chlorophylle, deux admins ; vrais combats Showdown | Victoires ouvrent les passages ; caps14/18/22 non décroissants |
| B07 Relais et accès | Deux relais, ordre libre, activation persistante, accès sanctuaire/caldera | Un seul relais ne suffit pas ; aucun contournement par menu de route |
| B08 Quête botaniste | Accepter, trois relevés uniques, retourner, compagnon Pikachu d'essai équipe/PC | Plein = aucun cadeau perdu ; réclamer à nouveau ne duplique rien |
| B09 Réserves de terrain | Trois caches uniques : Poké Balls, Potions, Super Balls ; coffre change d'état | Sac plein = aucune récompense partielle ; collecte sauvegardée |
| B10 Services et défaite | Centre/boutique réutilisent soins/transactions ; défaite sur l'île retourne à son Centre | Argent/objets conservés sauf transaction valide ou pénalité déjà prévue |
| B11 Carte, Vol, guidance | Menu Île proposée, schéma, lieux visités, Vol après libération, objectif HUD/journal | Pas de Vol vers lieu inconnu/intérieur ; aucune espèce compatible requise |
| B12 Libération et replay | Admins au même palier22, scène manuelle, drapeaux/consoles et dialogue changés | Pas +2 entre admins ; libération et scènes rejouables sans nouvelles récompenses |

## Entrée et parcours

Pause → Aventure → Explorer la première île proposée, ou onglet Île proposée. Ce lot conserve l'équipe existante. Pour juger les niveaux, préférer un nouvel emplacement : une ancienne équipe niveau50 rendra naturellement les équipes d'essai trop faciles. Aucun effacement automatique.

Au havre, parler à Vyna et finir l'arrivée. Le botaniste est facultatif ; prendre sa quête avant les relevés. Battre le contrôle RR au nord, suivre le panneau jungle. Deux relais sont à l'ouest et à l'est ; trois fleurs marquent les relevés. Le sanctuaire est à l'est. Après son gardien : reprendre la jungle, monter vers la caldeira, contourner la lave, continuer dans la galerie puis le poste RR. Deux admins successifs, avec préparation permise entre les combats. Dans le menu Île proposée, regarder la libération. Vol débloqué vers les lieux extérieurs de l'île déjà visités. Retourner au botaniste.

Le Centre et la boutique sont les deux bâtiments du havre. Les réglages, équipe/PC, apprentissages, capture, photo, scènes et sauvegardes précédents sont conservés. Le laboratoire reste accessible à pied depuis le havre ; son Vol historique garde ses conditions propres.

## Propositions et limites

Noms de lieux, dialogues de Vyna, adversaires, niveaux, Pikachu cadeau et récompenses de300₽/combat sont des fixtures. Pas un Pokédex final ou un starter choisi. Les deux admins appartiennent au même événement : tous deux cap22. Un ancien cap supérieur n'est jamais abaissé. Aucune Méga/legendary/fakemon supplémentaire ajouté ; génération et interactions confiées à Showdown.

La géographie est une maquette modulaire à primitives3D originales ; pas une île artistique terminée. Pas de modèles Pokémon, décors/textures haute qualité ni musique finale importés. Les cinq vues livrées servent aux retours de disposition/thème, pas à approuver implicitement les graphismes. Pas de configuration minimale ou de60fps garanti.

La grotte est une galerie lisible, sans obscurité nécessitant Flash. Le puzzle repose sur les relais, pas sur de nouvelles contraintes de compatibilité CS. Les actions terrain anciennes restent disponibles dans leur périmètre ; aucun système de raid légendaire ou multijoueur créé. Reproduction retirée, Nuzlocke/Soul-link reportés ; entrée dans ce nouveau chapitre refusée pour un ancien défi encore actif.

Cadeau et réserves transactionnels ; histoire/collecte/boîtes/connaissances persistantes. Schéma5 avec `island` optionnel. Une ancienne campagne charge le chapitre vide ; une nouvelle partie enregistrée dans ces nouvelles zones ne doit pas être relue avec une ancienne version du jeu. Les sauvegardes originales/migrations antérieures restent préservées.

## Validation et retours attendus

Tests de domaine avec chemins accessibles calculés à partir des collisions, sauvegardes JSON, ordre des quêtes, répétitions, sac plein et PC plein. Parcours Godot avec les quatre vraies victoires Showdown, cinématiques manuelles, transitions/services/cadeau et chargements intermédiaire/final. 103 contrôles domaine/chemins et46 contrôles de scène réussis ; suite complète du laboratoire réussie. Rendu GL Linux :51 contrôles incluant cinq vrais PNG, distincts du playtest Windows. Export et preuve de CI/publication consignés dans verification.

Au réveil, retour utile : disposition des zones, distances, lisibilité des panneaux, ambiance tropicale/volcanique, intérêt du puzzle et de la quête, rythme/dialogues, difficulté sur une nouvelle partie, bugs/save. Les textes et choix définitifs restent à discuter après ce parcours ; aucune interaction nécessaire pendant le développement autonome.
