# Questions ouvertes — après réponses Q01–Q16

Le cahier V0.1 est approuvé et Q01–Q16 sont conservées dans docs/sources. Les questions déjà répondues ne sont pas remises en attente. Les points ci-dessous sont des précisions ou des validations de propositions, pas un nouveau questionnaire complet.

## Trois choix nécessaires avant architecture finale

1. **Raids :** conserver le tour par tour collectif et reprendre seulement la résistance/les phases des raids officiels, ou reproduire aussi timer, scripts, purge et boucliers des raids Téracristal ? Proposition détaillée dans RAIDS_CADRAGE.md, aucune Téracristallisation implicite.
2. **Nouveau joueur :** la campagne est commune et tous attendent aux scènes ; pourtant le nouvel arrivant doit rattraper individuellement l’histoire. Option A : rejoint le chapitre de la campagne, récapitulatif et équipe adaptée, sans replay obligatoire. Option B : rejoue les chapitres précédents dans une progression séparée avant de rejoindre le groupe ; davantage de développement. Q10 exprime un rattrapage : ne pas choisir A silencieusement.
3. **Défi divin :** les quatre combats comprennent-ils le dieu/gardien final, ou s’agit-il de quatre adversaires puis un cinquième combat ? Le dernier exemple de scénario propose quatre au total, à valider.

## Propositions produit à valider

- Scénario complet et casting ; noms proposés, pouvoirs, arcs des compagnons, ordre des îles et événements du père ne sont pas approuvés par défaut.
- Règles Soul-link optionnelles : clause doublons, capture manquée, cadeaux/shiny, arrivée/départ, désactivation et fin du défi.
- Répartition exacte des formats par île ; amplification des HP/résistances et traitement des statuts ; Méga delta selon liste owner future.
- Action automatique après 60 secondes : cible et choix conservés si partiels ; règle en cas d’absence totale de choix. Préparer une proposition déterministe sans donner au joueur une IA omnisciente.
- Options globales modifiables seulement entre combats ou également pendant ; shiny sur génération des rencontres futures, vitesse client purement visuelle ; paramètres partagés réservés à l’hôte à proposer.
- Répétabilité d’un raid après capture et conduite si offre de capture refusée ou interrompue.
- Nombre et carte des biomes : règle biome = boss/champion confirmée ; au moins arène + défi hors céleste/repaire. Ne pas redemander cette règle, définir son application concrète sur les cartes.

## Études techniques autonomes

Inventaire assets et licences ; bases/moteur ; essais réseau, invitations, export Windows et performances ; sauvegardes atomiques et rollback ciblé ; échanges sans duplication ; Soul-link concurrent ; catalogue des attaques ; sécurité des informations PvP ; wiki bilingue et spoilers. Détails dans TECHNICAL_VALIDATION.md.

Plongée/île sous-marine : étude de coût, décision d’ajout après proposition, qualité inchangée. Aucun délai de production ni disponibilité de modèles ne sont supposés.
