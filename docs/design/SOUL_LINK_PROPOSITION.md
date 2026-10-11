# Soul-link — proposition de règles

**À valider. Mode entièrement facultatif, jamais condition d’accès au multijoueur.** Base approuvée : chacun peut capturer un Pokémon par zone, Pokémon du groupe liés, KO d’un membre condamne les liés ; restauration de sauvegarde libre. Les règles de communauté varient : les détails ci-dessous sont une proposition, pas une norme officielle.

1. Campagne normale par défaut. Nuzlocke solo ou Soul-link coop sont choisis explicitement. L’activation/désactivation en cours de campagne et ses conséquences attendent décision owner.
2. Chaque joueur utilise sa première rencontre admissible par zone. Proposition : doublon d’une famille déjà possédée par ce joueur peut être ignoré ; pas de règle obligatoire de types ou de genres différents.
3. Les prises de la même zone constituent un groupe de liens, jusqu’à trois membres. Leur activation dans les équipes attend que les places du groupe soient résolues.
4. Proposition stricte : rencontre ratée ou mise KO avant capture rend ce groupe indisponible ; les partenaires déjà capturés sont stockés comme exclus du défi, pas supprimés. Les raids garantis restent soumis au quota de zone si retenus comme rencontre admissible.
5. Cadeaux, starters et fossiles : catégories de liens distinctes ; un starter est lié aux starters des autres joueurs. La liste de cadeaux ne compte pas implicitement comme captures gratuites illimitées.
6. Proposition : chromatique exceptionnel capturable en collection mais non utilisable dans le défi s’il contourne le quota. Le propriétaire peut choisir une clause shiny permissive.
7. KO en combat entraîne un état inutilisable sauvegardé pour tous les membres liés. Pas de suppression du Pokémon, pour permettre audit et restauration libre.
8. Si un partenaire est dans un autre combat au moment du KO, propagation immédiate de l’inutilisabilité à la prochaine frontière d’action autoritative, sans réécrire une action déjà résolue. Tester le cas et afficher un message clair ; règles de défaite de ce combat à préciser.
9. Un joueur absent n’est pas exempté des pertes communes enregistrées. Nouvel arrivant, retrait et remplacement d’un joueur nécessitent des règles explicites avant d’activer le mode dans une campagne réajustable.
10. Une défaite de tous les Pokémon utilisables est annoncée comme fin du défi ; proposer de continuer la campagne en mode normal plutôt que supprimer la sauvegarde. Confirmation owner requise.
11. Les sauvegardes de secours restent accessibles ; pas de verrouillage punitif ni d’anticheat présenté comme fiable. Le jeu affiche l’état du mode et les groupes liés.
12. Les caps, soins et édition IV/EV sont des options distinctes. Un Soul-link ne signifie pas automatiquement objets interdits ou caps imposés.

## Validation

Le propriétaire doit choisir particulièrement : échec de capture, doublons, cadeaux, clause shiny, joueurs arrivant/partant, fin du défi et changement du mode. Implémenter ensuite des tests de liens et de KO concurrents ; ne pas développer le mode avant ces choix.
