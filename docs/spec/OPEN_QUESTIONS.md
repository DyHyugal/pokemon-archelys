# Questions ouvertes — après réponses Q01–Q16

Le cahier V0.1 est approuvé et Q01–Q16 sont conservées dans docs/sources. Les questions déjà répondues ne sont pas remises en attente. Les points ci-dessous sont des précisions ou des validations de propositions, pas un nouveau questionnaire complet.

## Choix avant le système concerné (le multijoueur est reporté)

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

## Priorité actualisée après le test Windows

Lancement, déplacement, fluidité, sauvegarde et combat factice du premier laboratoire sont confirmés OK par le propriétaire. Aucun retour multijoueur n’est attendu maintenant. Les arbitrages rattrapage, effectif, identités réseau, copies invités et Soul-link coop ne bloquent pas les travaux solo ; ne pas les implémenter par défaut. Le propriétaire répond au questionnaire de 51 questions. Le nouveau rapprochement de caméra et le dialogue restent à éprouver dans leur nouveau build.

## Études techniques autonomes

Inventaire assets et licences ; bases/moteur ; export Windows et performances (réseau et invitations reportés) ; sauvegardes atomiques et rollback ciblé ; échanges sans duplication ; Soul-link concurrent ; catalogue des attaques ; sécurité des informations PvP ; wiki bilingue et spoilers. Détails dans TECHNICAL_VALIDATION.md.

Plongée/île sous-marine : étude de coût, décision d’ajout après proposition, qualité inchangée. Aucun délai de production ni disponibilité de modèles ne sont supposés.

## Livraison Windows

Signature demandée : certificat de signature de code/service de signature autorisé non disponible. Conserver un build clairement non signé et les instructions de diagnostic dans le LIRE-MOI ; ne pas créer un certificat auto-signé présenté comme une solution de confiance. Cela bloque la signature demandée, pas la préparation du ZIP et des tests.

Étude disponible : `docs/development/SIGNATURE_WINDOWS_ET_OPTIONS_GRATUITES.md`. SignPath Foundation gratuit sous conditions, Store MSIX gratuit après acceptation, export Web proposé pour les tests. Aucun choix de licence, candidature ni achat réalisé. Microsoft Artifact Signing Public Trust ne prend actuellement en charge les particuliers que dans USA/Canada ; vérifier résidence/statut avant toute souscription.

Le propriétaire demande un essai gratuit non signé (D41). Une variante moteur Godot non modifié + PCK séparé est préparée ; son lancement avec Contrôle intelligent actif attend le retour Windows. Elle ne tranche pas la signature de la distribution finale.

Retour D42 : le propriétaire confirme le lancement de lab-477caad sans avertissement et les contrôles solo OK. La compatibilité universelle du moteur non signé reste non garantie ; aucune signature payante nécessaire pour poursuivre ses tests actuels. D43 demande des lots plus complets et la persistance de langue.

## Après validation lab-e84ee99

D44 valide le lot Windows précédent. D45 demande un vrai écran Sac et le maintien du réglage caméra dans les Paramètres. Ce bloc de présentation n'attend aucun arbitrage de scénario ; les 51 questions produit restantes restent ouvertes. Signature finale et compatibilité sur d'autres PC restent à vérifier.
