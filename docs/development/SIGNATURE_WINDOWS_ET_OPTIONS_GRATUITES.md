# Signature Windows et options gratuites — recherche du 11 octobre 2026

## Conclusion pour Archélys

Il n’est pas nécessaire de payer pour tous les tests. Pour un EXE natif distribué directement qui doit fonctionner avec le Contrôle intelligent des applications activé, une signature de code de confiance reste la voie maîtrisable lorsque Microsoft ne connaît pas le binaire. Des programmes gratuits existent, avec acceptation conditionnelle. Une version Web permet aussi de tester sans lancer cet EXE Windows.

Aucun fournisseur n’a été contacté, aucune candidature envoyée, aucun achat effectué et aucune licence de code choisie à la place du propriétaire. Le laboratoire reste non signé. Ce document est une étude, pas une nouvelle fonctionnalité développée.

## Ce qui a été vérifié

Les pages commerciales Microsoft, SignPath, Certum et SSL.com sont refusées par le proxy de cet environnement (403), même après autorisation réseau supplémentaire. Les documents officiels publics ont été lus dans leurs dépôts GitHub. Les conditions sont donc vérifiées à partir de ces sources ; les prix commerciaux en direct ne le sont pas. Ne pas utiliser un ancien prix comme un devis actuel.

Microsoft explique que le Contrôle intelligent laisse passer un binaire jugé sûr par son service de réputation, ou signé par une autorité du programme de racines de confiance. Un fichier inconnu et non signé est bloqué. Cela explique pourquoi le premier EXE a pu fonctionner et le suivant être bloqué, sans établir la cause exacte sur le PC du propriétaire. La signature doit être RSA selon la documentation lue ; la signature ECC n’est pas prise en charge. Un certificat auto-signé, le SHA256 ou une signature Git ne remplace pas cette confiance.

Source officielle : [fonctionnement du Contrôle intelligent](https://github.com/MicrosoftDocs/windows-dev-docs/blob/docs/hub/apps/develop/smart-app-control/overview.md) et [signature compatible](https://github.com/MicrosoftDocs/windows-dev-docs/blob/docs/hub/apps/develop/smart-app-control/code-signing-for-smart-app-control.md), dépôt consulté au commit `aabd22a9113af71e56bd6f5af8fde06df68162e0`.

## Options et coût

| Option | Coût vérifié ou repère | Adaptation au projet |
|---|---|---|
| SignPath Foundation | Gratuit pour les projets acceptés | Signature de confiance pour projets open source ; candidature et examen, pas une attribution automatique |
| Microsoft Store, compte individuel, paquet MSIX/AppX | Compte gratuit ; pas d’achat de certificat CA nécessaire pour la publication MSIX/AppX acceptée | Emballage et certification Store ; pas une signature gratuite du ZIP/EXE actuel |
| Export Web du laboratoire, hébergement gratuit adapté | Pas de certificat de signature Windows à acheter | Test dans le navigateur ; export/hébergement à réaliser et tester, pas encore disponible |
| Microsoft Artifact Signing, anciennement Trusted Signing | Repère public observé : 9,99 USD/mois ; tarif actuel officiel non vérifié ici | Public Trust pour particuliers limité aux USA/Canada ; organisations de plusieurs pays dont UE acceptées sous conditions |
| Certificats classiques : Certum, SSL.com, DigiCert, etc. | Prix actuel non vérifiable ici ; ne pas annoncer de montant | Demander une offre incluant validation d’identité, stockage sécurisé de clé et signatures nécessaires, avant achat |

### SignPath Foundation : vraie piste gratuite, mais pas immédiate

La fondation annonce un service gratuit pour les projets OSS. Elle impose notamment licence approuvée OSI, absence de composants propriétaires non autorisés dans son cadre, maintenance et releases documentées, builds vérifiables, authentification multifacteur, règles de revue et approbation manuelle de chaque signature. La fondation signe sous son identité. Elle exige une réputation vérifiable pour les exécutables et peut refuser une candidature.

Le dépôt public Archélys n’a actuellement pas de fichier de licence de projet : public ne signifie pas automatiquement open source. Ne pas choisir une licence sans décision du propriétaire. Vérifier aussi avec le fournisseur comment son règlement s’applique à un export reposant sur les templates précompilés Godot et au contenu d’un fangame. Le caractère gratuit du jeu ne suffit pas à établir l’éligibilité. La signature ne confère aucun droit sur les assets.

Sources : [présentation](https://github.com/SignPath/fdn-website/blob/main/docs/index.md), [conditions](https://github.com/SignPath/fdn-website/blob/main/docs/terms.md), [candidature](https://signpath.org/apply). Source consultée : `df7801c96a1c6a498add70bb0827baa07eb8f820`. La page de conditions se présente elle-même comme un draft ; vérifier les conditions effectivement appliquées lors d’une candidature.

### Microsoft Store : inscription individuelle gratuite et signature MSIX

Microsoft indique que le compte individuel est gratuit ; le compte société coûte environ 99 USD une seule fois, selon région. Pour les paquets MSIX/AppX, Microsoft remplace la signature lors de la publication après certification. Les installateurs EXE/MSI doivent être signés par l’éditeur : ils ne bénéficient pas de cette signature automatique.

Cette voie requiert une soumission, la validation du contenu et le respect des droits et règles Store. Pour un fangame Pokémon, l’acceptation ne doit pas être présumée. Elle convient moins aux itérations immédiates d’un petit laboratoire et ne fournit pas un certificat réutilisable pour le ZIP GitHub.

Sources : [comptes et frais](https://github.com/MicrosoftDocs/windows-dev-docs/blob/docs/hub/apps/publish/faq/open-developer-account.md), [signature des paquets Store](https://github.com/MicrosoftDocs/windows-dev-docs/blob/docs/hub/apps/publish/publish-your-app/msix/app-package-requirements.md).

### Microsoft Artifact Signing : restriction importante pour un particulier en France

La documentation actuelle accepte Public Trust pour les organisations de l’UE et d’autres pays, mais limite les développeurs individuels aux États-Unis et au Canada. Si le propriétaire est un particulier résidant en France, ne pas recommander cette offre comme immédiatement accessible. Private Trust et Public Trust Test ne donnent pas la confiance publique par défaut recherchée.

La FAQ précise que les abonnements Azure gratuits, d’essai ou sponsorisés ne permettent pas ce service : un abonnement payant est nécessaire. Le repère 9,99 USD/mois apparaît dans une discussion publique, pas dans un tarif officiel directement consultable ici ; vérifier le prix, la devise, les taxes et l’éligibilité avant toute dépense.

Sources officielles : [éligibilité géographique](https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/artifact-signing/quickstart.md), [FAQ, abonnements exclus](https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/artifact-signing/faq.yml), [types de confiance](https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/artifact-signing/concept-resources-roles.md), [page tarifaire à consulter avant achat](https://azure.microsoft.com/en-us/pricing/details/artifact-signing/). Dépôt consulté : `86ded125ac98a84e560a71a6e0a842ead8056809`. Repère secondaire : [discussion publique](https://github.com/wivuu/stellarallegiance/issues/101).

### Web : recommandation pour tester maintenant sans payer

Le laboratoire utilise déjà le renderer Compatibility, compatible avec l’export WebGL 2 de Godot. Un export mono-thread évite les contraintes d’isolation nécessaires à certains exports multi-thread. Un hébergement HTTPS gratuit adapté, par exemple GitHub Pages pour ce dépôt public dans ses limites, pourrait fournir un lien jouable sans EXE ni modification des protections Windows.

Il faut encore réaliser l’export, tester le navigateur et l’hébergement. Ce n’est pas une promesse de performances identiques au natif ni un changement de cible finale : Windows reste la cible demandée. Les sauvegardes navigateur utilisent un stockage distinct, dépendant de la persistance IndexedDB et de l’origine du site ; elles ne reprennent pas automatiquement le fichier Windows. Le réseau demeure reporté.

Source : [export Web officiel Godot](https://github.com/godotengine/godot-docs/blob/master/tutorials/export/exporting_for_web.rst).

## Pistes qui ne répondent pas au besoin

Certificat auto-signé : oblige à modifier la confiance sur les PC et ne fournit pas la confiance publique attendue par le Contrôle intelligent. Désactivation du Contrôle intelligent, modes développeur ou changements globaux de Windows : ne répondent pas à une distribution sans manipulation des protections. Achat d’un domaine ou certificat HTTPS : ne signe pas l’EXE. Renommer l’EXE ou lui ajouter un hash ne change pas ces faits.

Priorité proposée : permettre les tests du laboratoire via Web, puis étudier l’éligibilité SignPath pour le natif. Aucun de ces choix n’est encore une décision du propriétaire ni une intégration réalisée.
