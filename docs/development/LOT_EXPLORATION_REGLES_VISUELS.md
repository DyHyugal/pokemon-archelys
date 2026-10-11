# Lot D49 — exploration, règles avancées et comparatifs

Le propriétaire a validé lab-2816c71 et demandé les trois blocs suivants ensemble. Les réponses N01–N51 sont conservées dans leurs formats XLSX/JSON et transcrites intégralement. Aucune île de production ni branche durable supplémentaire créée. Le multijoueur demeure reporté.

## Bloc 4 — systèmes solo de vie quotidienne

Le village communique par portes avec Centre et boutique, et par passages avec crique et quartier visuel. La sauvegarde contient le lieu, les destinations visitées et les obstacles retirés. Le chargement reconstruit le bon décor, sans cumuler les caméras. Centre : PV/PP/statuts ; Boutique : achats de 1/5 exemplaires et vente à moitié prix, contrôle argent/quantité/capacité avant mutation ; sac et soins utilisent les individus existants. Prix et offre provisoires.

Pêche depuis la jetée de la crique : vraie rencontre avec famille Magicarpe/Léviator, capture et progression identiques aux herbes. Le niveau de pêche plafonne à 20 pour ce test ; stade légal, jamais Magicarpe niveau 20+. Surf accessible après le premier dresseur, sans Pokémon compatible ; déplacements sur l'eau bloqués avant. Coupe/Éclate-Roc/Force retirent des collisions et marqueurs de test. Escalade monte/descend un promontoire ; aucun de ces usages ne lit les attaques ou la compatibilité de l'équipe. Vol via page Carte : déblocage scénaristique + lieu extérieur déjà visité. Carte de navigation technique ; pas la carte dessinée de l'archipel. Flash autorisé initialement, mais aucune grotte sombre ne permet encore de valider son éclairage automatique.

## Bloc 5 — périmètre avancé effectivement implémenté

17 espèces, 38 attaques, quatre Méga historiques : Florizarre, Dracaufeu X/Y et Tortank. Les formes temporaires possèdent les statistiques/types/talents extraits du CSV ; une seule Méga par camp et combat, sans remboursement après KO, forme retirée avant sauvegarde. Sécheresse, Isograisse, Griffe Dure et Méga Blaster traités sur les attaques disponibles. Le catalogue expose les talents autorisés et CT réutilisables réellement présents dans la version source. Pas les 500 espèces ni tous les talents.

Soleil/pluie/sable/neige et quatre terrains : horloges distinctes de cinq tours ; dégâts Feu/Eau, boosts 9G 1,3× du terrain au sol, immunités de statut/priority, soin du champ herbu, sable et bonus Déf. Spé. Roche/Défense Glace, Chlorophylle, Croissance au soleil et charge de Lance-Soleil. Les prolongateurs, capacités de suppression/annulation et autres interactions hors catalogue restent absents. Pas de revendication d'arrondis cartouche exacts.

IA difficile : planifie avant application du choix du joueur, connaît sa propre équipe et les données publiques adverses (espèce, niveau, PV, types/statut/champ). Elle ne lit ni le choix futur, ni les IV/EV/nature/objet adverses, ni les attaques non révélées ni le banc adverse. Contrôle pessimiste du KO, pas une prédiction par accès aux statistiques cachées. Un poseur privilégie son champ manquant, passe ensuite la main à un bénéficiaire ; si le champ expire, le bénéficiaire rappelle un poseur vivant, y compris un second. Les fixtures soleil et terrain électrique vérifient ce cycle. Politique de laboratoire, pas une IA finale couvrant toute équipe/condition. L'estimation très prudente du KO et l'absence d'une évaluation complète des risques de switch nécessiteront du playtest et une extension du simulateur.

Doubles solo réels : quatre acteurs, deux choix joueur verrouillés avant tour, cibles distinctes, ordre priorité/vitesse/égalité aléatoire, PP, KO annulant l'action, changements/réservations uniques, remplacement et victoire/défaite. Horloge du champ une fois par tour, pas une fois par acteur. **Catalogue mono-cible : attaques de zone, redirection, Abri, choix d'objets en double, raids et gestion avancée des poseurs en double restent à compléter.** Aucun faux « deux duels indépendants » ni test réseau.

Réglages : chill (choix aléatoires légaux), normal, hard ; cap activé par défaut, désactivation et retour sans réduction des niveaux ni EXP accumulée au-delà du cap ; multiplicateur EXP 1–5 ; taux shiny des rencontres à venir. Quatre vitesses de laboratoire proposées 1×/2×/3×/4× avec conservation séparée ; valeurs finales N38 ouvertes. L'accélération ne passe pas les messages automatiquement et ne modifie pas l'horloge musicale de Godot ; aucune musique finale n'est présente pour une validation auditive.

Nuzlocke solo : activation explicite, première rencontre/zone, premier échec de Ball consommant le quota, fuite/KO également, doublons de famille ignorables, capture shiny exceptionnelle utilisable. Un doublon peut être capturé volontairement si le quota est libre ; lancer la Ball engage alors ce quota. KO permanent, soins sans résurrection, game over seulement si équipe **et** PC sans survivant, désactivation sans réactivation. Passage en normal autorise de reprendre les soins. **Prêt Chapignon/reprise du défi : non développé, les nouveaux quotas sont encore à décider (N35).** Soul-link, œufs, cadeaux et fossiles attendent leurs propres systèmes ; aucune promesse qu'ils seraient déjà couverts.

## Bloc 6 — avant adoption artistique

[Trois comparatifs de rendu réel](../design/COMPARATIFS_QUARTIER.md), FHD, bâtiment modulaire à pans/cheminée/toit plat, ouvertures/encadrements, arbres/jardinières/lampadaires, relief et animations légères. Le quartier séparé est visitable ; aucun style final n'est imposé. Village et mannequin existants conservés, intérieurs techniques. Géométrie/code originaux, aucune nouvelle dépendance externe ou asset commercial. Validation N45 nécessaire avant produire les assets des îles ; le prototype est volontairement balisé non validé.

## Persistance, contrôles et limites

Schéma **4**, lecture 1/2/3 ; conservation originale `.vN.backup` au premier remplacement plus backup roulante. Validation complète avant mutation de la campagne : lieux, tableaux uniques, monnaies, challenge, Pokémon morts et options. Sauvegarde/chargement/édition/transfert restent interdits pendant un combat. Langue/caméra indépendantes ; vitesse séparée.

184 assertions de domaine exécutées (114 antérieures + 70 du lot), import du mannequin et trois parcours de scène réels (`pokemon_scene`, `exploration_scene`, `scene_smoke`). Contrôles de migration3→4, transactions refusées sans perte, caps réactivés, données cachées ne modifiant pas l'IA, poseurs/climats/champs/KO, Méga unique et nettoyée, Nuzlocke avec PC, tours doubles et collisions. `tools/check_prototype.py` exécute ces contrôles et échoue aussi sur les erreurs de script/absence de marqueur. Validation Windows **du nouveau build attendue** ; ni les résultats locaux ni la CI ne la remplacent.

Même EXE officiel portable, PCK séparé. Catalogue figé sous notice PokéAPI BSD ; export ZIP/README par build. Les anciennes captures/documents du lot D47 décrivent ce build antérieur, pas les limites actuelles.
