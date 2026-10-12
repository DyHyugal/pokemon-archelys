# D73 — dix blocs : suite jouable du havre

**SPOILERS DEV — proposition de chapitre, pas synopsis final.**

12 octobre 2026, Europe/Paris. Demande owner : « Ok enchaine sur les 10 prochjains blocs ». Poursuite autonome, sans approbation Windows ou artistique déduite. Aucun Pokédex/starter définitif ou export Meshy reçu.

Le lot prolonge la démo existante, plutôt que de recommencer une campagne : une fois le sentier terminé et la scène de retour achevée, reparler à Vyna propose la suite. Trois nouveaux lieux sont reliés au sentier : canopée, sources et poste de contrôle secondaire RR. Les noms, niveaux, équipes, récompenses et placements sont des **propositions de démo**. Les sols et accessoires réutilisent les maquettes existantes ; aucun nouveau kit de modèles primitifs produit.

| Bloc | Fonction utilisable | Critères / limites |
|---|---|---|
| 1. Zones connectées | Canopée, sources et poste RR accessibles à pied par des passages indiqués, avec collisions et retours. | Conditions narratives contrôlées avant chaque transition. Trois zones de maquette, pas l’île entière ou de nouvelles villes finales. |
| 2. Contrôle du sentier | Combat Showdown contre un contrôle RR après activation du chapitre par Vyna. Victoire ouvre la canopée, cap12 et récompense150₽. | Pokémon10/12 provisoires. Aucun déblocage sur défaite, fuite impossible en dresseur, cancellation sans progression. |
| 3. Mission des relais | Deux relais indépendants dans la canopée, dialogue de Hyu, journal et chemin vers les sources. | Les deux requis ; aucun doublon. Hyu n’est pas un allié contrôlable ou un nouvel arc pédagogique approuvé. |
| 4. Championne des sources | Combat réel avec trois sets légaux : Goupix Sécheresse, Bulbizarre Chlorophylle, second Goupix Sécheresse. | Rôles setter/bénéficiaire/second setter ; IA difficile existante, informations adverses publiques seulement. Ace14, nouveau palier14. Ni raid ni divinité légendaire. |
| 5. Responsables RR au palier commun | Deux combats du même poste, ordre imposé ; équipes14/16, ace16 et événement partagé16. Raidon présente l’enchaînement. | Base de la championne12/14 +2. Le second responsable ne fait pas +2 supplémentaires. Palier de l’événement mémorisé, cap global jamais abaissé ; récompenses250₽ chacune, uniques. |
| 6. Surf contextuel | Après la championne, action de rive sans Pokémon compatible ; traversée, sortie sur terre et reconstruction après chargement dans l’eau. Cache du bassin : trois Super Balls, une fois. | Masque d’eau commun à la canopée, aux sources et à la baie du havre, quai conservé comme sol sec. Pas de monture ou animation de nage finale. Cache atomique : sac plein conserve le cadeau. |
| 7. Camp et continuité des services | PNJ de soins dans la canopée : PV/PP, dialogue Hyu/Raidon, retour au Centre du havre après défaite. | Le PC et les services commerciaux restent aux lieux D72. Une seule pénalité de défaite existante,100₽ fixture ; aucune nouvelle économie définitive. |
| 8. Rencontres et habitats | Herbes canopée8–10 ; pêche aux sources18–22. Stades calculés à partir du niveau réel, Pokédex alimenté par ces mêmes tables. | Magicarpe18–19 / Léviator20–22, pas de Magicarpe22. Niveaux de pêche volontairement non équilibrés : peuvent dépasser le cap courant. Modèles manquants indiqués en combat ; catalogue22 espèces maintenu. |
| 9. Carte et guidage du chapitre | Graphe des zones visitées/ouvertes/verrouillées, plan local avec objectif ; Vol vers les nouvelles étapes visitées, guidage jusqu’à Vyna. | Schémas de navigation, pas nouvelle illustration finale de la région. Captions placées pour éviter recouvrement/débordement, liste textuelle conservée. |
| 10. Scènes, jalons et reprises | Présentation et rapport manuels FR/EN, galerie après achèvement, reprise d’une scène interrompue ; flags, visites et paliers enregistrés avec sauvegarde/export/import. | Rapport termine ce chapitre, pas la libération de l’île : divinité, caldeira, raid et repaire final restent à construire. Aucune récompense dupliquée par replay/chargement. |

## Contenu et sauvegardes

`game/data/demo/chapter.json` sépare les équipes et rencontres du contrôleur. Validation : espèces/stades/talents/attaques légaux, rôle de set, ace égal au cap, caps successifs non décroissants et caps identiques pour les deux responsables. Ces fixtures ne sélectionnent pas le Pokédex final. Les attaques anciennes et dégâts restent résolus par Showdown ; aucun moteur de combat recodé.

Le callback de victoire applique les jalons avant le message de victoire ; une interruption du moteur restaure l’aventure sans compléter le chapitre. Le journal conserve les paliers d’événement, alors que le cap effectif reste le maximum déjà atteint. Format de démo `archelys-demo-1` et campagne5 conservés ; champ `chapter` facultatif pour les anciennes saves. Aucune progression inventée à la migration. Les nouveaux espaces de rencontres ont des identifiants séparés. Les dépendances, cap minimal correspondant aux jalons et position aquatique sont validés avant restauration.

Auto/manuelle/backup/export D72 conservés. Une ancienne version n’est pas tenue de lire les saves des nouveaux lieux ; conserver la copie avant conversion. Atelier et démo restent deux campagnes distinctes. La continuation owner ne vaut pas validation des lots D69–D72.

## Contrôles

`tools/check_prototype.py` inclut `demo_chapter.gd` : parcours réel de quatre combats natifs avec une équipe de test renforcée, accès verrouillés, relais, profils/Sécheresse, paliers non décroissants et partagés, collision/Surf/chargement, soins, cancellation, défaite, carte/Vol, scènes et isolation de l’atelier. La fixture renforcée accélère les vérifications de progression ; elle ne valide pas la difficulté des combats.

Les rencontres sont aussi échantillonnées avec une graine fixée, avec limites attendues explicitement Magicarpe<20 / Léviator≥20. Données fautives et sauvegardes incohérentes sont refusées. Le parcours est rendu en OpenGL FHD avec cinq PNG réels. Linux llvmpipe ne valide ni les performances Windows/GPU ni la qualité graphique Pokémon demandée. Résultats, source, CI et téléchargement seront consignés dans VERIFICATION_D73.md après publication.

Aucun multi, raid, Nuzlocke/Soul-link ou reproduction ajouté. Pas d’asset Meshy ou Pokémon officiel extrait, pas de nouvelle branche.
