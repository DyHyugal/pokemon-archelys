# D63 — gros bloc gestion et préparation des équipes

Objectif : rendre le PC240 places et la préparation des individus utilisables dans une collection importante, avec des transferts sûrs et une seule livraison. Portée : solo, catalogue22 espèces/43 attaques existant ; pas nouveaux modèles/îles, reproduction, multijoueur, raids ou défis.

## Rangement et transferts

Huit boîtes de trente emplacements, séparées du tableau des individus. Déplacer dans une case vide conserve sa nouvelle position ; une case occupée échange les deux positions. Retirer un Pokémon ne décale pas ses voisins. Un échange direct entre un Pokémon stocké et un membre de l'équipe fonctionne même à six membres et garde la case libérée pour le membre déposé. Le transfert est refusé s'il supprimerait le dernier membre apte au combat. Aucun relâchement ni suppression introduits.

Identité, PV/statut, IV/EV/nature, talent, objet et attaques/PP restent attachés à l'individu. Captures/fossiles/œufs continuent d'utiliser `add`, qui attribue un emplacement libre seulement lorsqu'il reçoit un individu au PC. Équipe/PC pleins conservent les refus transactionnels précédents.

Interface FR/EN : boîte courante, trente cases, informations/infobulles, résumé/retrait/transfert. Recherche sur tout le PC par nom, type, talent FR/EN ou `#UID` exact ; filtre de type indépendant ; résultats paginés par trente. Les barres de défilement restent présentes ; le focus amène les actions sélectionnées dans la vue. Cases textuelles sans nouveaux sprites Pokémon définitifs.

## Préparation commune

Un Pokémon stocké ouvre le même résumé que celui de l'équipe : IV/EV/nature, stats réelles, talent, équipement/objets, CT et rappel. Le retirer n'est pas nécessaire. Modifier ses stats conserve la règle existante de dégâts reçus ; ne le soigne pas gratuitement.

CT/rappel : une source sélectionnée, recherche nom/type FR/EN, attaque avec type/catégorie/puissance/précision/PP/priorité, choix d'emplacement et confirmation explicite. Annuler ne change rien. Les attaques déjà connues sont signalées et ne peuvent réinitialiser leurs PP. Seul le nouvel emplacement reçoit les PP de base. L'ordre des attaques peut changer avec les PP correspondants ; aucun reset du reste du set.

Les effets sont résolus par Showdown ; la fiche présente les métadonnées du catalogue, pas une description exhaustive de chaque effet. Règles/coûts du laboratoire inchangés : CT réutilisables et rappel gratuits, légalité au stade/niveau actuel ou sous-évolutions pour le rappel. Pas de modèle de builds/presets supplémentaire ou de jeu compétitif réseau.

## Persistance et dépendances

Campagne5 ajoute `storage_slots`, mapping UID→emplacement optionnel. Une ancienne campagne sans ce champ est rangée selon l'ordre déjà présent ; aucun individu perdu ou transformé. Validation avant restauration : mapping complet des seuls membres du PC, valeurs entières0–239, pas de case dupliquée ou UID orphelin. Corruption refusée, pas corrigée silencieusement lors de la lecture. Préserver ses copies et éviter les anciens binaires qui ne connaissent pas le rangement stable.

L'API historique deposit/withdraw/add reste disponible ; les règles de capacité sont conservées. Pas de nouvelle dépendance, pas de modification de Showdown ou du catalogue, pas d'asset tiers ajouté. Interface et code de stockage originaux.

## Vérification

`storage_systems.gd` :31 contrôles, dont emplacement239, permutation d'occupants, refus atomiques, échange à équipe pleine, dernier membre apte, restauration JSON/ancienne campagne, corruptions, ordre/PP et CT/rappel. Un membre transféré/préparé entre réellement dans Showdown, attaque et retrouve ses PP consommés sur le même UID. Les240 cases sont effectivement remplies, puis une acquisition/dépôt supplémentaire sont refusés sans perte.

`storage_scene.gd` :16 contrôles de vrais menus, déplacement entre boîtes, recherche bilingue/UID exact et pagination de soixante résultats, résumé depuis PC, édition IV, recherche de rappel, annulation/confirmation, échange à équipe pleine et restauration. Rendu graphique Linux du même parcours et capture du PC inspectée. Toutes les suites antérieures de `tools/check_prototype.py` conservées et réussies.

La validation Windows et l'appréciation de l'ergonomie restent attendues ; D52 est la dernière validation reçue. Le LIRE-MOI regroupe ce bloc et les nouveaux lots précédents. Preuves/version/CI dans `verification/STORAGE_2026-10-11.txt` après publication.

[Capture du PC de vérification](verification/STORAGE_PC.png) —62 individus de test, Linux GL,1280×720 ; aucun contenu propriétaire validé implicitement.
