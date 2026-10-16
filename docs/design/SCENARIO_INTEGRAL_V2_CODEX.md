# Pokémon Archélys — Scénario intégral V2 pour Codex

> **MISE À JOUR CONCEPTION DES COMBATS, 16 OCTOBRE 2026 :** consulter en priorité [EQUIPES_TACTICA_ARCHIPEL_V1.md](EQUIPES_TACTICA_ARCHIPEL_V1.md) (8 arènes, épreuves, admins RR, 4 gardiens célestes, et 4 maîtres draconiques × 4 paliers avec builds) et [EPREUVES_ET_ARENES_V1.md](EPREUVES_ET_ARENES_V1.md) (agencement, énigmes, quêtes et progression). Ces deux documents détaillent une **nouvelle proposition** de courbe interne (aces d'arène 18/36/45/55/64/78/93/98) et des **combats de maîtres draconiques adaptatifs** 38/57/80/95, non encore validés par le propriétaire ; ils **ne changent pas** les plages des îles ni l'accès immédiat à tous les biomes Dragon. Ils remplacent les rosters et niveaux *provisoires* du document antérieur ARENES_EPREUVES_COURBE_V1.md, notamment son ancienne proposition de paliers fixes et d'arène Dragon 100. Les paragraphes historiques du présent scénario mentionnant encore ces anciennes propositions doivent être lus comme non normatifs. **Ne pas implémenter ces choix contradictoires simultanément.**
>
> **SPOILERS DEV — Document de conception / proposition narrative au 16 octobre 2026.**
> **Branche de destination : develop.** Ne pas publier ce texte tel quel dans le wiki destiné aux joueurs.
> **Statut :** les règles explicitement indiquées comme « actées » proviennent des choix du propriétaire ; les noms, équipes, détails du récit et personnages nouvellement inventés sont **des propositions**, et ne doivent pas être traités comme validés.
> **RECTIFICATIF PRIORITAIRE — ÉQUILIBRAGE ET ARÈNES (16 octobre 2026) :** consulter [ARENES_EPREUVES_COURBE_V1.md](ARENES_EPREUVES_COURBE_V1.md) avant d'exploiter les anciennes propositions de ce scénario. **Décisions du propriétaire : 8 arènes, soit Plante/Feu (île 1), Psy/Ténèbres (île 2), Glace/Acier (île 3), Électrik (île 4), Dragon (draconique) ; plages d'îles 1–38, 40–57, 60–80, 80–95 ; céleste niv. 100. L'île draconique devient intégralement accessible dès la libération de l'île 1, ses QUATRE biomes et épreuves simultanément.** Niveaux internes de la réserve proposés : 40–50, 55–65, 70–85, 90–98, puis dernière arène Dragon niveau 100. Les étapes D1–D4 entre îles plus bas indiquent un **ordre conseillé de visite**, plus des déblocages. Ce rectificatif prévaut sur les anciennes descriptions incompatibles.

> **Important :** document d'histoire et de mise en scène, **pas une autorisation implicite de développer toutes les fonctionnalités immédiatement**. Construire en solo d'abord ; rendre le contenu adaptable à la coop 1 à 3 joueurs. Préserver le projet, ses scènes et ses sauvegardes existantes.

## 0. Comment utiliser ce document

Ce document remplace, pour le travail créatif à venir, le **synopsis narratif provisoire** de docs/design/SCENARIO.md et les scènes proposées dans docs/design/SCENARIO_PROPOSITION_V01.md. Il ne remplace pas les décisions techniques ni le cahier des charges, et ne constitue pas une approbation définitive de tous les détails inventés.

Sources de cadrage à recouper : AGENTS.md, docs/spec/SOURCE_OF_TRUTH.md, docs/spec/CAHIER_DES_CHARGES.md, docs/spec/DECISIONS.md, docs/spec/OPEN_QUESTIONS.md, docs/spec/REPONSES_N01_N51.md sur la branche docs/cadrage-valide. La branche develop a encore des documents de cadrage antérieurs : ne pas considérer leur silence sur les décisions récentes comme un refus de celles-ci.

La première île s'appuie aussi sur docs/design/ATLAS_PROPOSE_2026-10-12.md, docs/design/canvas-premiere-ile/LIRE-MOI.md, docs/design/CONCEPT_PROMPTS_2026-10-12.json et docs/development/LOT_PREMIERE_ILE_12_BLOCS.md sur docs/cadrage-valide. Les zones techniques déjà prototypées sont des inspirations d'implantation, pas une carte finale validée.

**Ordre impératif de conception de chaque île :** (1) géographie, histoire locale, occupation et intrigue ; (2) nom de l'île ; (3) arènes et épreuves de biomes ; (4) personnages, cast et dialogues. Toutes les propositions ci-dessous suivent cet ordre. Aucun nom de lieu, de nouveau personnage ou de légendaire n'est fixé par la seule présence dans ce fichier.

## 1. Règles narratives actées par le propriétaire

1. **Trois protagonistes permanents, frères et sœur : Vyna, Raidon et Hyu.** Ils veulent retrouver et sauver **leur père commun** ; l'histoire se déroule toujours à travers ce trio. Chacun a 18 ans dans le cadrage d'origine. Ne jamais écrire un quatrième MC distinct qui accompagne ces trois personnages.
2. **Le joueur remplace l'un des trois rôles.** Sélection via un questionnaire de 2 à 3 questions maximum orientant vers Vyna (sociale, volontaire), Raidon (énergique, compétitif) ou Hyu (logique, stratège). En solo : un rôle joueur et deux PNJ ; en duo : deux rôles joueurs et un PNJ ; en trio : trois rôles joueurs. Un rôle ne peut pas être pris par deux humains simultanément.
3. **Même récit et mêmes trois interlocuteurs dans tous les modes.** Le nom affiché d'un rôle joué par un humain est son **nom de dresseur personnalisé**, jamais automatiquement « Hyu », « Vyna » ou « Raidon ». Un rôle PNJ conserve son nom canon. Le texte de base et ses intentions restent identiques, que le rôle soit humain ou IA.
4. **La progression majeure est collective.** Le groupe voyage ensemble la plupart du temps. Des séparations brèves, discussions et combats entre frères et sœur sont encouragés ; pas d'échanges de Pokémon imposés. Aux étapes collectives, attendre tous les joueurs humains requis ; les rôles PNJ se joignent automatiquement. Un départ d'hôte, une déconnexion ou un joueur en retard ne doit pas créer de scène incohérente.
5. **Rainbow Rocket (RR) est une coalition**, pas l'armée personnelle de Silver : représentants/héritiers des Teams Rocket, Magma, Aqua, Galaxie, Plasma et Flare. Silver représente Rocket et joue un rôle majeur, mais chaque branche a ses propres intérêts, chefs, administrateurs, sbires, moyens d'action et responsabilités. Les équipes occupent les îles via des branches identifiables, pas uniquement des administrateurs Rocket anonymes.
6. **Le Défi des Îles et les arènes restent officiellement autorisés par RR** parce que l'organisation recherche les dresseurs capables d'affronter des Pokémon légendaires et de servir le projet Couronne Zéro. Inscription des dresseurs, carte et résultats administrés dans une base RR. Des champions peuvent certifier la victoire localement tout en retardant ou falsifiant le rapport central pour protéger les jeunes dresseurs. Les conséquences de cette dissimulation apparaissent dans le récit.
7. **L'occupation doit être vivante :** patrouilles de nuit, couvre-feu, contrôles des cartes, taxes, monopoles, abus de pouvoir, propagande, réquisitions et résistances. Ces événements sont souvent de **courts dialogues ou interactions in-game** ; les grandes cinématiques sont réservées aux moments majeurs. Après libération, les PNJ, commerces et patrouilles changent.
8. **Les champions et maîtres d'épreuves deviennent progressivement porteurs d'espoir.** Au départ ils sont prudents ; ensuite certains protègent le trio et en parlent à d'autres ; à la fin ils soutiennent la révolte. Éviter de répéter après chaque badge « vous êtes la lueur d'espoir » ; faire monter cette conviction par des actes.
9. **Ordre principal validé :** île tropicale/volcanique → île mystique → île hivernale → île high-tech, avec île draconique intégralement accessible en parallèle dès l'île 1 libérée et retours facultatifs ; puis île céleste ; puis assaut final sur l'ancien Æther. Sur chaque île occupée : exploration de ses biomes et défis, interventions RR à moments variables, puis **raid de divinité locale → repaire secondaire RR → libération et changement visible du monde**.
10. **L'île draconique est libre** (trop dangereuse pour une occupation durable). Elle s'ouvre **après la libération de la première île** avec **ses quatre biomes et ses quatre épreuves disponibles immédiatement**. Leur difficulté est fixe et volontairement très différente (40–50, 55–65, 70–85, 90–98) pour permettre une exploration parallèle et des retours facultatifs. **Après les quatre épreuves : dernière arène Dragon niveau 100**, puis conclusion sacrée de la réserve. On ne parle jamais de « libérer » cette île.
11. **L'île céleste n'est accessible qu'après la victoire finale sur l'île draconique.** Défi divin en cinq combats : **quatre gardiens humains puis une divinité, cinquième adversaire**. Entre les combats, soins, objets et CT possibles ; **pas de PC ni de sortie de l'île** pendant le défi. Titre de Gardien d'Archélys attribué selon les jalons acquis par les joueurs.
12. **La conclusion au quartier général Æther vise à sauver le père et détruire la coalition RR.** Les dirigeants vaincus peuvent être emprisonnés s'ils se rendent ; certains refusant de cesser leurs violences subissent une fin tragique, **sans gore**. Le climax n'est pas seulement « Silver contre le monde ». La chute des six branches et de leur projet commun doit être lisible.
13. **Légendaires affrontés pendant le scénario, capturables seulement en postgame.** Ultra-Dimension et ses huit arènes, revanches, défense du titre et raids rejouables ensuite. Répartition de référence : trois boss de fin d'île en phases successives, deux en affrontement simultané sur les cinq îles ordinaires ; ne pas imposer les espèces proposées tant que le Pokédex du propriétaire n'est pas fixé.
14. Les noms des îles, des villes, des PNJ supplémentaires, les équipes Pokémon, starters, Fakemons, formes delta, budgets/niveaux et identités des cinq nouveaux héritiers **ne sont pas encore approuvés**. Ne jamais figer les anciennes suggestions par accident. Référence narrative inspirée de la richesse des fangames, sans copier Insurgence, Empyrean, ni les intrigues des jeux officiels.
15. **Priorité de développement solo**, architecture compatible duo/trio ; le multijoueur réel, ses sauvegardes et le réseau sont reportés au stade actuel. Écrire dès maintenant les conditions narratives et les dialogues compatibles, sans prétendre que le réseau fonctionne déjà.

## 2. Convention de script : les trois rôles et les noms

Rôles logiques immuables : ROLE_VYNA, ROLE_RAIDON, ROLE_HYU.

- La personne contrôlant ROLE_HYU peut s'appeler « Hyugal » ; toutes les étiquettes d'interlocuteur, apostrophes et objectifs destinés à ce personnage affichent « Hyugal ».
- La narration continue de connaître la personnalité « Hyu », même quand son nom de dresseur est différent : ne pas écrire de nouvelles paroles génériques à sa place.
- Les descriptions parentales (« notre père », « vous trois », « mes enfants ») restent vraies dans les trois modes.
- Les scènes utilisent le format « [ROLE_HYU] : ... » pour le locuteur et « {NOM:ROLE_HYU} » dans les paroles ; la résolution du nom se fait à l'affichage. Si le rôle n'a pas de propriétaire humain, le nom canon s'affiche.
- Aucun dialogue ne doit référencer « le joueur » comme quatrième protagoniste.
- Le choix du rôle n'est pas un choix de sexe ou de difficulté. Identités, apparences, vêtements et éventuels accords grammaticaux doivent être gérés par les données du personnage ; pas de prénom de PNJ réimposé à l'avatar humain.
- Les choix collectifs, quand ils existent, se décident par vote dans la future coop (réponse N16) ; une voix par joueur présent. Les choix ne changent pas arbitrairement la trame canonique.
- Une récompense de scénario individuelle appartient au profil correspondant ; une victoire d'étape collective donne le jalon aux joueurs remplissant les conditions de participation. Les PNJ complètent leurs étapes narratives sans stocker artificiellement une sauvegarde joueur.

### Questionnaire de 3 questions maximum — proposition

1. Face à un danger : « aider les autres immédiatement » (Vyna), « foncer vers l'adversaire » (Raidon), « observer et préparer une stratégie » (Hyu).
2. En combat : « confiance et polyvalence » (Vyna), « intensité et victoire » (Raidon), « anticipation tactique » (Hyu).
3. Selon ses proches : « sociable » (Vyna), « énergique » (Raidon), « réservé et réfléchi » (Hyu).

Addition des réponses, proposition du profil dominant, égalité = plusieurs propositions. **Confirmation manuelle obligatoire** ; en coop un rôle déjà occupé est indisponible. Les questions et le score ne changent pas la personnalité du rôle choisi. Les formulations finales restent à valider.

## 3. Univers, promesse, structure dramatique

### Logline

Trois frères et sœur, inscrits à un Défi des Îles surveillé par une coalition criminelle, cherchent à libérer leur père emprisonné. Leurs victoires réveillent l'espoir d'un archipel soumis ; ils découvrent trop tard que les exploits utilisés pour libérer chaque île permettent aussi aux chefs de Rainbow Rocket de compléter une machine dimensionnelle destinée à étendre leur domination au monde entier.

### Passé de la région

Archélys est un archipel isolé comportant quatre îles peuplées occupées, une vaste réserve draconique libre, une île céleste inaccessible et un complexe scientifique offshore autrefois connu comme Æther. Jadis, les sociétés insulaires entretenaient des sanctuaires liés aux divinités locales et à un réseau de passages anciens. Les traditions interprètent cet équilibre de façons diverses.

Il y a huit ans **(chronologie de travail, à confirmer)**, la coalition Rainbow Rocket a pris le contrôle des liaisons maritimes, de l'énergie et des échanges avant d'imposer ses garnisons. Elle a maintenu un Défi des Îles pour repérer les dresseurs exceptionnels. Il y a trois ans **(proposition de chronologie)**, Aloïs, père du trio, a été arrêté après avoir refusé de finaliser certaines recherches sur les sanctuaires ; sa captivité reste la motivation affective première du groupe.

### La Concordance — proposition à confirmer

La « Concordance » est un ancien réseau de passages dimensionnels protégé par les divinités de l'archipel. Les humains peuvent l'étudier, mais pas l'asservir sans conséquences. Chaque véritable victoire contre une divinité génère une « empreinte de résonance » unique. Le **projet Couronne Zéro**, conçu **collectivement** par les différentes branches de RR, vise à reproduire ces empreintes et à forcer l'ouverture de routes stratégiques à l'échelle du monde.

Répartition du travail RR : Magma fournit géothermie et matériaux ; Aqua maîtrise ports, transports et courants ; Galaxie étudie mathématiques et dimensions ; Plasma contrôle l'enregistrement, l'influence et l'identification des dresseurs ; Flare bâtit le matériel et sélectionne ses bénéficiaires ; Rocket pilote les opérations de renseignement et de sécurisation. Le conseil des six peut désavouer une branche ; nul chef ne possède seul toute la machine.

**Twist principal :** à chaque raid gagné et île libérée, RR perd une base réelle, mais une résonance est transmise automatiquement à Couronne Zéro avant la neutralisation des infrastructures. Les champions qui cachent les badges ralentissent l'identification administrative, **pas la mesure physique des raids**. L'organisation exploite les succès des trois enfants à son profit, sans les avoir « laissés gagner » magiquement.

### Prémonition — proposition à confirmer

Une championne Psy de l'île mystique possède de vraies prédispositions divinatoires. Des années plus tôt elle a vu **trois silhouettes apparentées**, quatre îles retrouver la lumière, une forteresse tomber et une porte céleste s'ouvrir sur une catastrophe. Elle soupçonne un futur salvateur **possible**, pas une destinée certaine. Les visions ne lui permettent pas de tout révéler ; ses avertissements prennent un sens différent après le dévoilement de Couronne Zéro. Elle ne désigne pas un seul MC élu.

### Fil émotionnel

- Début : chercher le père et protéger la famille.
- Premier tiers : constater l'oppression, grandir comme dresseurs, devenir visibles des champions.
- Milieu : affronter des branches RR différentes, découvrir que le père est vivant, inspirer une résistance réelle.
- Dernier tiers : comprendre comment les exploits servent Couronne Zéro ; achever la réserve draconique ; mériter le Défi divin.
- Climax : réunir les îles libérées, sauver le père, faire tomber **tous les appareils de la coalition** et stabiliser les passages.
- Postgame : réparer les dégâts, défendre le titre, explorer les portails et capturer les légendaires.

## 4. Carte narrative et ordre des grandes étapes

| Acte | Lieu / nom provisoire | Branche RR dominante | Progression | Clôture |
|---|---|---|---|---|
| P | Ville natale sur île tropicale | Magma, sous registre central RR | Famille, inscription, starters, premières injustices | Départ du trio |
| I | Île tropicale-volcanique « Varakoa » (proposition) | **Magma** | Côte → jungle → sources → volcan | Raid volcanique → repaire Magma → libération |
| D1 (visite conseillée) | Île draconique (sans nom validé) | Aucune | Biome 1 : falaises-forêt, disponible dès fin île I | Épreuve 1/4 |
| II | Île mystique (sans nom validé) | **Aqua** | Lac/brume → forêt → ruines → observatoire | Raid mystique → repaire Aqua → libération |
| D2 (visite conseillée) | Île draconique | Aucune | Biome 2 : canyon-oasis, disponible dès fin île I | Épreuve 2/4 |
| III | Île hivernale (sans nom validé) | **Galaxie** | Port → hauts plateaux → sources → glacier | Raid du glacier → repaire Galaxie → libération |
| D3 (visite conseillée) | Île draconique | Aucune | Biome 3 : hautes vallées gelées, disponible dès fin île I | Épreuve 3/4 |
| IV | Île high-tech (sans nom validé) | **Plasma + Flare**, fonctions distinctes | Métropole → quartier de contrôle → littoral énergétique → tour | Raid électrique → repaire commun → libération |
| D4 (visite conseillée) | Île draconique | Aucune | Biome 4 : crêtes volcaniques et orages, disponible dès fin île I ; après 4/4 arène finale | Divinité draconique → accès céleste |
| V | Île céleste (sans nom validé) | Aucune | 4 gardiens, puis divinité (5e combat) | Titre de Gardien et crise dimensionnelle |
| VI | Ancien Æther, repaire central (nom provisoire « Nœud Atlas ») | **Conseil RR des six** | Assaut des alliés → branches → prison → machine | Père libéré, conseil défait, Couronne Zéro détruite |
| VII | Épilogue et postgame | Pas de nouvelle RR | Réouvertures, raids, Ultra-Dimension, titre | Aventure libre |

**Important :** la distribution des branches au-delà de Magma en île 1 est une **proposition cohérente** pour caser Aqua, Galaxie, Plasma et Flare sur trois autres îles, en gardant Rocket au centre. Il n'y a **pas** un cinquième territoire occupé inventé pour héberger une branche. Aqua reste plausible sur une île mystique possédant un lac et une côte brumeuse, Galaxie sur l'île hivernale avec observatoire polaire et cristaux, et Plasma/Flare sur l'île technologique. Si le propriétaire souhaite une autre répartition, conserver la structure et réécrire les événements locaux.

**Répartition de raids proposée :** île I = successif, II = simultané, III = successif, IV = simultané, draconique = successif, soit 3/2. Les types/espèces ne sont pas verrouillés par cette proposition.

## 5. Casting transversal — fonctions d'abord, noms provisoires

### Famille et entourage

- **ROLE_VYNA :** sociable, enthousiasme contagieux, assez compétente en Pokémon ; soutient les habitants, adore les découvertes. Ses gags/initiatives ne doivent pas la rendre stupide.
- **ROLE_RAIDON :** compétiteur passionné, fonceur et provocateur ; aime les combats, mais ne trahit pas sa famille ni ne sabote les missions.
- **ROLE_HYU :** discret, analyste, généralement le plus avancé en stratégie ; sens pratique et humour sec. Hyu / Hyugal sont des références personnelles du propriétaire ; pas de blagues méta en jeu.
- **Aloïs (proposition de prénom) :** père commun et chercheur emprisonné ; étudiait la Concordance avant d'en découvrir le détournement. Au final, il apporte le savoir mais ne remplace pas les enfants comme héros de l'action.
- **Maëlle (proposition) :** figure parentale à la maison familiale, soutien affectif et témoin de l'occupation ; lien familial exact et existence à confirmer.
- **Salia (proposition) :** scientifique de départ, ancienne collègue d'Aloïs, confie les Pokémon initiaux et éclaire les premières recherches.

### Coalition RR — six partenaires et non cinq seconds de Silver

- **Silver / Rocket :** stratégie, renseignements, blocus et opérations inter-branches ; volonté de dépasser Giovanni. Personnage important, mais **pas supérieur omnipotent** aux autres héritiers.
- **Héritier Magma (nom proposé : Varek) :** croit que l'énergie et les ressources doivent être exploitées coûte que coûte. Supervise l'île I.
- **Héritière Aqua (nom proposé : Naélis) :** maîtrise les routes maritimes et manipule les accès côtiers de l'île II ; conflit d'intérêts avec Magma sur les dégâts aux courants.
- **Héritier Galaxie (nom proposé : Orien) :** recherche mathématique et dimensionnelle, instrumentalise les découvertes d'Aloïs ; dirige les installations de l'île III.
- **Héritier Plasma (nom proposé : Vérian) :** registre des dresseurs, propagande, contrôle des autorisations, surveillance sociale de l'île IV.
- **Héritier Flare (nom proposé : Caëlan) :** finance et fabrique Couronne Zéro, trie les privilégiés de l'île IV, défend un élitisme violent.

Chaque branche possède des **sbires reconnaissables**, un ou plusieurs **administrateurs** et au moins un poste/repaire sur son île. Un chef peut envoyer ponctuellement un administrateur en mission de test hors repaire. Prévoir un total raisonnable de combats spéciaux ; ne jamais placer un administrateur tous les deux carrefours.

### Autorités locales et figures majeures

Pour chaque île occupée, créer : un doyen ou responsable civil, ses champions/maîtres d'épreuves, des commerçants et victimes nommées, un représentant de résistance et au moins un fonctionnaire de la base de données RR. Certains collaborent, d'autres résistent, sans cliché « tous gentils » ou « tous vendus ».

L'île draconique possède un conseil indépendant et **quatre maîtres d'épreuves** avant la dernière championne/arène. L'île céleste possède **quatre gardiens humains + une divinité**. Ces catégories ne sont pas interchangeables. Les « divinités locales » des autres îles sont les boss légendaires ; les « gardiens » sont ceux du Défi divin céleste.

## 6. PROLOGUE — Le registre des dresseurs

### P-01 — Maison familiale au port

**Lieu :** maison du trio dans la ville portuaire de la première île. **Déclencheur :** nouvelle partie et sélection des rôles. **Personnages :** les trois enfants, figure parentale de foyer.

Le joueur découvre la région occupée sans prologue historique interminable : cartes réglementées affichées, taxe sur l'énergie, vieux portrait de famille devant un sanctuaire. Les trois discutent d'Aloïs, absent depuis plusieurs années.

**[ROLE_VYNA] :** « On ne va pas rester ici à attendre des nouvelles qui n'arrivent jamais. »
**[ROLE_RAIDON] :** « Alors on va directement au poste Rocket leur demander où est papa. »
**[ROLE_HYU] :** « C'est précisément le genre d'idée qui nous empêcherait d'obtenir des nouvelles. »
**[ROLE_VYNA] :** « On trouvera une autre façon. Mais cette fois, on fait quelque chose. »

**Résultat :** découverte de la maison et de la photographie ; objectif « Retrouver des informations sur notre père ».

### P-02 — Inspection et confiscation

Sur la place du port, les sbires Magma réquisitionnent les stocks d'un commerce et réclament à un habitant une taxe de détention de Pokémon. En cas de refus, confiscation et sanction. Le trio intervient ; échauffourée, premier combat d'initiation dans un contexte crédible.

**Sbire Magma :** « Aucun Pokémon non déclaré n'est autorisé dans le périmètre du port. »
**Habitante :** « Je l'élève depuis dix ans ! »
**[ROLE_RAIDON] :** « Et moi je n'ai jamais déclaré mes chaussures. Vous allez me les prendre aussi ? »
**[ROLE_HYU] :** « Arrête de les provoquer devant les caméras. »
**[ROLE_VYNA] :** « Ils ne peuvent pas lui enlever son Pokémon pour une taxe ! »

### P-03 — Les Pokémon de départ

Salia protège son matériel de recherche pendant la saisie. Les trois obtiennent chacun un partenaire via une séquence compatible solo/duo/trio. **Espèces choisies ultérieurement par le propriétaire**, pas par ce script. En solo, les deux PNJ ont des partenaires cohérents et leur équipe progresse au fil de l'histoire ; pas de doublon gratuit imposé.

Le premier duel tutoriel peut impliquer le joueur et un sbire ; ne jamais exiger trois combats identiques d'IA contre le même ennemi pour « valider » les rôles PNJ.

### P-04 — Inscription officielle au Défi des Îles

Le trio s'inscrit au guichet central. L'inscription est **obligatoire pour franchir certaines zones** et participer aux épreuves. RR collecte identités, Pokédex et résultats.

**Agent RR :** « Chaque victoire doit être certifiée par un champion puis transmise au registre. »
**[ROLE_HYU] :** « Qui consulte ces données ? »
**Agent RR :** « Les autorités habilitées. Pas besoin d'en savoir davantage. »
**[ROLE_RAIDON] :** « Génial. Même les badges sont surveillés. »
**[ROLE_VYNA] :** « On aura au moins le droit de parcourir les îles. C'est ce qu'il nous faut. »

**Résultat :** trois cartes narratives distinctes ; première autorisation. Ne pas confondre carte certifiée localement et télétransmission du résultat RR.

### P-05 — Fragment de recherche et décision familiale

Salia révèle un message partiellement conservé d'Aloïs, évoquant les sanctuaires et une future expédition interdite. Le trio prend **ensemble** la décision de se perfectionner, chercher les indices et sauver son père. Pas de désignation d'un « élu solitaire ».

**Aloïs, enregistrement :** « Les anciennes portes ne sont pas de simples ruines. Ne laissez personne en faire une arme... »
**[ROLE_VYNA] :** « C'est sa voix. »
**[ROLE_HYU] :** « Le fragment a été supprimé volontairement. »
**[ROLE_RAIDON] :** « Alors on retrouvera le reste. Et on le ramènera. »

**Jalon :** PROLOGUE_TERMINE → île I accessible.

## 7. ÎLE I — Tropicale et volcanique

### 7.1 Histoire, géographie et occupation

**Architecture existante à reprendre comme base :** port à arcades/toits turquoise, côte, sentier, jungle/canopée, deux relais, village de basalte et sources, caldeira, galerie, sanctuaire, poste de contrôle local, raffinerie dans les falaises. Ne pas ajouter un deuxième volcan sans justification. La carte devra relier les lieux **à pied**, les téléportations de test n'étant pas le parcours narratif.

L'île vivait de l'équilibre entre océan, forêt et géothermie : « les deux souffles ». Sous domination Magma, centrales, mines et terres sont réquisitionnées. La branche prélève l'énergie et des matériaux spéciaux destinés à Couronne Zéro. Les pêcheurs paient des droits d'accostage, les villageois des quotas d'eau chaude, les familles craignent les contrôles de Pokémon, la forêt s'appauvrit sous les pompes et conduites.

**Éléments d'ambiance récurrents :**
- Couvre-feu local (horaire exact à valider), patrouilles dans la ville nocturne et barrages au port.
- Un commerçant doit cacher son stock pour éviter la confiscation ; ses tarifs et dialogues changent après libération.
- Un mineur affecté au volcan doit montrer une autorisation de déplacement.
- Propagande Magma sur les « bienfaits du progrès géothermique ».
- Après victoire locale, rues plus vivantes, barrières levées, pêche reprise, voyageurs vers la réserve draconique.

### 7.2 Nom de travail de l'île

**« Varakoa » est une proposition NON VALIDÉE** ; noms de zones proposés : Havre-Clair (port et maison), Chemin des Alizés (côte), Canopée des Mille-Feuilles (jungle), Fumerolles (village), Bassins du Souffle (sources), Mont Khar (volcan), Galeries de Basalte (grotte), Cœur du Volcan (sanctuaire), Complexe du Cratère (repaire Magma). Renommer après validation sans modifier les identifiants stables de zone.

### 7.3 Défis de biomes — proposition révisée (types d'arènes fixés)

1. **Littoral : épreuve Eau**, marées/passerelles et contrôle des vannes du port.
2. **Jungle : arène Plante (arène 1)**, jardins de la canopée, relais et croissance végétale.
3. **Sources : arène Feu (arène 2)**, stratégie soleil et installations géothermiques. Championne ayant connu Aloïs.
4. **Volcan : épreuve Roche**, galeries, mécanismes et zones dangereuses, avec responsable ancien mineur.

Chaque défi exige une victoire propre aux rôles joués par des humains selon la progression individuelle prévue ; en solo les PNJ obtiennent leur progression narrative sans trois combats autonomes simulés inutilement.

### 7.4 Casting local — propositions

- Doyenne **Alma** : défend l'autonomie du port sans afficher une révolte impossible.
- Maître d'épreuve Eau **Ewen** : discret, courage prudent, valide la première épreuve littorale.
- Championne Plante **Iona** : botaniste, protège les rencontres sauvages ; retarde le rapport de victoire de l'arène de la canopée.
- Championne Feu **Mila** : connaissait Aloïs ; retarde le rapport, donne accès à une ancienne galerie.
- Maître volcan **Boran** : ancien mineur, guide jusqu'au sanctuaire.
- Officier Magma **Sarn** : fait appliquer contrôles et réquisitions.
- Administrateur Magma **Darek** : contrôle le repaire final.
- Héritier Magma **Varek** : dirige la branche et réapparaît dans le conseil central.
- Salia et la famille restent des personnages transversaux.

### 7.5 Déroulé des scènes

**I-01 — La côte réglementée.** À la sortie du port, un barrage réclame les cartes. Sur le quai, un marchand paie une taxe punitive. Un affrontement contre un contrôleur Magma ouvre le sentier ; les habitants ne célèbrent pas encore les héros.

**I-02 — Un duel entre frères et sœur (voir section 14).** Sur la grande place : Vyna part au centre commercial, Hyu et Raidon préparent l'arène. Premier duel Hyu/Raidon, puis Vyna défie le gagnant. Événement léger, jouable dans tous les modes, pas d'échange exigé.

**I-03 — Épreuve des marées (Eau).** Le maître d'épreuve affronte le trio à l'issue d'un puzzle de vannes, remarque leurs styles différents, les félicite sans proclamer de sauveur. Résultat certifié et transmis normalement ; premier jalon officiel, sans badge d'arène.

**I-04 — Premier abus Magma majeur.** Après le **premier biome**, un convoi détruit les cultures en installant des pompes dans la jungle. Un officier menace des villageois. Le trio défend les habitants et découvre des câbles partant vers le volcan.

**I-05 — Arène Plante de la canopée (arène 1).** Les relais et relevés botaniques forment l'approche de l'arène dans la jungle. Après les combats officiels, Iona certifie le badge **localement**, mais indique que son terminal « attendra une meilleure connexion » avant la transmission centrale.

**[ROLE_VYNA] :** « On n'a jamais été aussi près de comprendre ce qu'ils font. »
**[ROLE_HYU] :** « Les relais ne servaient pas seulement à surveiller la forêt. Ils reliaient les installations à la caldeira. »
**[ROLE_RAIDON] :** « Alors direction le volcan. »

**I-06 — Sources et village de basalte.** Un foyer a perdu l'accès au chauffage des bains ; courte quête de vannes et circuit d'eau, sans bloquer abusivement l'aventure. Découverte de logements de mineurs et collecte d'un témoignage.

**I-07 — Arène du soleil.** Avant le combat, Mila apprend le nom d'Aloïs. Après victoire, elle confie une ancienne carte d'accès et dissimule à son tour le rapport central.

**Mila :** « Votre père a découvert quelque chose dans les galeries. Il voulait empêcher qu'on réveille ce qui dort au-dessous. »
**[ROLE_HYU] :** « Vous pensez qu'il travaillait ici ? »
**Mila :** « J'en suis certaine. Et je ne transmettrai pas vos derniers résultats à ceux qui l'ont emmené. »

**I-08 — Épreuve des galeries.** Boran impose de traverser des passerelles au-dessus de la lave et d'actionner des mécanismes ; combat Roche/Sol. Les mineurs expliquent la suractivité des forages et la disparition de l'ancien personnel du sanctuaire.

**I-09 — Raid de divinité, proposé Heatran.** Magma déstabilise la chambre géothermique ; Heatran s'éveille. **Format successif** (phases réinitialisées selon règles de raid à finaliser). Le trio calme la divinité. Une résonance est enregistrée par une sonde dissimulée, sans que les héros comprennent sa portée.

**I-10 — Repaire Magma.** Entrée après le raid seulement, pas avant. Poste extérieur → machines → salle des admins → chambre d'extraction. Darek défie le trio. Le dirigeant Magma intervient en personne ou par communication selon rythme, reconnaît la perte du site et envoie des archives centrales à Æther avant repli.

**Darek :** « Vous pensez avoir arrêté nos opérations ? Les données ont déjà quitté cette île. »
**[ROLE_HYU] :** « Quelles données ? »
**Darek :** « Celles pour lesquelles vos victoires sont devenues si intéressantes. »

**I-11 — Libération.** Civils reprennent les centrales ; garnisons se rendent ou fuient, couvre-feu levé, commerces et ferries intérieurs rouverts. Alma remercie les **trois** enfants. Ewen et Mila se concertent : peut-être que ces trois jeunes sont un espoir réel. Retour poignant à la maison, promesse de ramener Aloïs.

**I-12 — Conséquences et ouverture.** Accès à l'île mystique et **à la totalité des quatre biomes draconiques**, dont les niveaux sont fixes et certains trop élevés pour être vaincus immédiatement. Après scène : PNJ/rues/boutiques/mer évoluent ; plus de patrouille Magma de nuit. Une surveillance RR maritime globale persiste hors île.

## 8. INTERLUDE DRACONIQUE I — La terre qui refuse les conquérants

**Condition :** île I libérée pour accéder librement à **tous les biomes**, l'interlude I n'est qu'une première visite conseillée. La réserve a conservé son indépendance grâce à ses Pokémon puissants, à une géographie dangereuse et à ses défenseurs, pas par négligence inexplicable de RR.

**Biome 1 : falaises battues par le vent et ancienne forêt draconique.** Le trio rencontre l'autorité locale **Ilyra** (nom proposé), qui refuse de les traiter en sauveurs sur parole.

**Ilyra :** « Avoir battu des soldats ne vous donne aucun droit sur cette terre. »
**[ROLE_RAIDON] :** « On ne vient pas la conquérir ! »
**Ilyra :** « Alors montrez que vous savez la traverser sans déranger ceux qui l'habitent. »

**Épreuve 1/4 (niveau candidat 50) :** observation de nids, traversée des falaises, combat stratégique contre un maître local. Les trois autres biomes sont déjà accessibles ; cette victoire **ne doit pas être utilisée comme clé d'ouverture des autres biomes**. Ne pas lancer l'arène finale avant 4/4. Aucune bannière ni base RR dans la réserve.

## 9. ÎLE II — Mystique, mer et secrets du futur

### 9.1 Histoire, géographie et occupation

Île de forêts nocturnes, côte en croissant, lacs brumeux, village de lanternes, ruines, ponts et observatoire historique. Avant la conquête, les habitants y étudiaient les marées, les Pokémon Spectre/Psy/Fée/Ténèbres et les traditions liées à la nuit. RR exploite la peur des phénomènes étranges.

**Branche dominante proposée : Aqua.** Sous prétexte de sécuriser la navigation, Aqua contrôle les ports, les digues, les écluses et une partie des brumes artificiellement entretenues autour du lac. Des patrouilles interdisent les sorties nocturnes sous couvert de protection. Des pêcheurs et bateliers disparaissent après avoir refusé les taxes. Les recherches dimensionnelles sont échangées avec Galaxie, mais Aqua possède la base locale et ses soldats.

**Début d'île :** un couvre-feu strict, des rues désertes le soir, de petits événements de PNJ : confiscation de bateaux, arrestation d'un passeur, interventions sans nécessité de cinématique. L'arrivée des trois enfants circule de bouche à oreille grâce à Soléane/Varakoa.

### 9.2 Nom — NON VALIDÉ

Noms de travail sans présumer du choix : **Sélombre**, **Vesper** ou tout autre nom à créer après révision de l'histoire locale. Nom d'une ville : « Les Ponts Brumeux » (descriptif seulement), deuxième ville « Village des Lanternes », sanctuaire « Miroir Nocturne ». Aucun nom final imposé.

### 9.3 Défis de biomes — proposition

1. **Lac et ponts : arène Psy**, énigmes de reflets ; championne douée de **précognition**.
2. **Forêt des lanternes : épreuve Fée**, recherche de lanternes et faux sentiers.
3. **Ruines : arène Ténèbres**, jeux de lumière, stratégie et faux indices.
4. **Observatoire côtier : épreuve Spectre**, archives, astres et chemins dimensionnels.

L'**intervention Aqua principale** survient **après le troisième biome**, contrairement à Magma après le premier. Petites patrouilles possibles avant ; pas trois cinématiques répétant la même menace.

### 9.4 Casting local — propositions

- Doyen/ancienne historienne **Isée** : protège les traditions sans forcément croire les mensonges de RR.
- Championne Psy **Éloane** : précognition véritable, apparition majeure deux fois au moins dans l'aventure ; répliques nuancées, pas une copie d'Astera.
- Maître d'épreuve de la forêt **Lior** : guide les voyageurs et entretient les lanternes.
- Champion Ténèbres **Silex** : arène officielle, publie parfois les résultats ; refuse d'exposer ses habitants pour le trio.
- Maîtresse des archives **Némina** : gardienne des pièces historiques.
- Admin Aqua **Corail** et officier du port **Darse** ; héritière **Naélis**.

### 9.5 Déroulé

**II-01 — Bienvenue dans la brume.** Les trois enfants sont reconnus par un pêcheur, mais un agent Aqua confisque des barques. La traversée de nuit expose le joueur à des patrouilles, sans supprimer la liberté d'exploration.

**II-02 — La vision aux trois silhouettes.** Éloane, avant le défi de l'arène Psy, s'interrompt en les voyant. Elle décrit sa vision ancienne : **trois silhouettes venues d'une même maison**, quatre îles en lumière, une forteresse défaite, une porte menaçante.

**Éloane :** « Je vous ai vus bien avant aujourd'hui. Je ne connaissais pas vos visages, seulement trois ombres côte à côte. »
**[ROLE_VYNA] :** « Alors vous savez si on retrouvera notre père ? »
**Éloane :** « Non. L'avenir que je vois change lorsque vous choisissez d'agir. Il montre aussi une porte que personne ne devrait ouvrir de force. »
**[ROLE_HYU] :** « Une image du futur n'est pas une certitude. »
**Éloane :** « Et c'est précisément ce qui me donne encore de l'espoir. »

**II-03 — Arène Psy (arène 3).** Combat du trio contre Éloane, puis reconnaissance prudente : elle garde secret le véritable niveau des enfants, accepte de certifier sans transférer immédiatement toutes les données.

**II-04 — Forêt et lanternes.** Épreuve nocturne, courtes discussions familiales au camp : Vyna aime les contes, Raidon se moque des fausses apparitions, Hyu cherche leur cause. Un petit duel facultatif de rivalité peut exister, jamais une obligation de repasser une même scène de combat.

**II-05 — Arène Ténèbres (arène 4) aux ruines des ombres.** Troisième défi du parcours. Les trois découvrent un ancien nom lié à Aloïs et un registre transporté vers l'observatoire. Un champion plus prudent avertit : toute erreur mettra les habitants en danger.

**II-06 — Intervention Aqua majeure.** Aqua ferme les écluses, provoque la montée des eaux et crée un brouillard permanent pour protéger ses transports clandestins. Le trio défend un village et déjoue un barrage. Naélis exprime ses objectifs maritimes propres, non un ordre secret de Silver.

**Naélis :** « Les routes appartiennent à ceux qui savent les garder ouvertes. »
**[ROLE_RAIDON] :** « Avec des soldats qui arrêtent les habitants à la tombée de la nuit ? »
**Naélis :** « La sécurité exige parfois qu'on prive les autres de choix. »
**[ROLE_VYNA] :** « Alors ce n'est pas la sécurité que tu protèges. »

**II-07 — Observatoire et archives.** Dernière épreuve Spectre. Documents partiellement authentiques prouvent qu'Aloïs a étudié des passages anciens ; ne pas affirmer qu'il a volontairement inventé une arme. Les héros commencent à entendre le terme « Concordance » sans le comprendre.

**II-08 — Raid mystique.** Divinité locale **Lunala** ou combinaison de manifestations **Darkrai/Cresselia** à décider selon Pokédex ; **format simultané**. Les résonances ne permettent aucune capture en histoire. Les écluses retournent progressivement à un état stable.

**II-09 — Repaire Aqua sous l'observatoire et au port.** Donjon de chambres hydrauliques et de consoles de navigation. Combat contre admin puis face à l'héritière (combat, négociation ou fuite scénarisée selon rythme). Aqua transfère des données à Atlas avant d'abandonner la base.

**II-10 — Un membre du conseil RR apparaît.** Silver, en **émissaire de la coalition**, examine les rapports manquants et peut faire combattre **une seule équipe de test** contre un responsable spécial, ou se montrer lui-même. Ne pas multiplier gratuitement les duels. Affrontement gagnable s'il y en a un ; pas de défaite forcée.

**II-11 — Libération.** Écluses reprises, brumes artificielles dissipées, commerce maritime rétabli, couvre-feu levé. Éloane confie à une personne de confiance que les trois enfants pourraient accomplir sa vision. Son doute sur la « porte » persiste. Accès île III ; **le biome draconique 2 était déjà disponible**, mais il correspond désormais au niveau de l'aventure.

## 10. INTERLUDE DRACONIQUE II

**Visite conseillée :** après île II libérée ; **accès réel dès l'île I libérée**.

**Biome 2 : canyon, désert rocheux et oasis sous arches naturelles.** Les dresseurs locaux privilégient l'endurance et la lecture des déplacements des Pokémon Dragon. **Épreuve 2/4 :** traversée guidée, aide à un habitat menacé par une tempête, combat contre un maître du canyon. Pas d'occupation ni de repaire RR. Le défi conclut ce biome sans offrir le titre céleste ni ouvrir l'arène finale.

## 11. ÎLE III — Hivernale, savoir et survie

### 11.1 Histoire, géographie et occupation

Port nordique de pierre et bois, haut plateau, village des sources chaudes, vallées glacées et mine creusée dans le glacier. Les habitants dépendent de réseaux de chauffage publics construits avant RR.

**Branche dominante proposée : Galaxie.** La branche a pris le contrôle d'une station de mesures célestes et d'une mine de cristaux utiles à la stabilisation des portails. Elle a converti les anciennes chaudières à son propre usage. Chauffage, déplacements en montagne et approvisionnement sont conditionnés à des quotas ; ses scientifiques détournent les relevés d'Aloïs. RR prétend sauver les habitants du froid en contrôlant la seule source de chaleur.

### 11.2 Nom — NON VALIDÉ

Suggestions de travail : « Skeld », « Frimas », autre nom à créer après recherche d'une identité locale ; villes « Port du Nord » et « Hameau des Sources », mine « Station Boréale » restent descriptives.

### 11.3 Défis de biomes — proposition

1. **Port et fjord : arène Glace**, routes gelées et navigation.
2. **Hauts plateaux : épreuve Vol**, tempête, refuges et orientation.
3. **Sources thermales : arène Acier (arène 6)**, forge métallurgique géothermique, réglage des rails et aimants.
4. **Glacier et mine : épreuve Roche**, circuits thermiques et cristaux.

L'**intervention Galaxie principale** intervient **après le deuxième biome**.

### 11.4 Casting local — propositions

- Doyenne **Néva** : ancienne responsable des services publics, sous surveillance.
- Champion du port **Yorik**, maître du plateau **Tarek**, championne des sources **Elwen**, maîtresse de mine **Irise**.
- Admin Galaxie **Soren** (nom provisoire, à ne pas confondre avec l'ancien candidat Plasma du dépôt), archiviste **Kelis**, héritier **Orien**.
- Infirmier de village, mineur réquisitionné, technicien des chaudières : personnages secondaires récurrents de courte portée.

### 11.5 Déroulé

**III-01 — Le chauffage comme laisse.** Arrivée au port. Une famille supplie une patrouille de rétablir sa chaudière ; un officier exige le paiement d'une nouvelle taxe.

**III-02 — Arène Glace au port (arène 5).** Le trio remporte l'arène. Le champion connaît leurs exploits, mais parle discrètement pour ne pas déclencher une enquête.

**III-03 — Plateau, refuges et épreuve Vol.** Les trois se séparent brièvement : l'un vérifie un refuge, un autre aide un Pokémon blessé, le dernier parcourt une voie de montagne. Une réplique et un regroupement commun font progresser ; ne pas séparer artificiellement les humains pendant une longue demi-heure.

**III-04 — Intervention Galaxie.** Des soldats ferment le réseau de chauffage après une protestation. L'héritier prétend que les sacrifices sont nécessaires pour comprendre les fondations du monde. Le trio peut restaurer les chaudières **sans couper la chaleur** aux familles : choix d'un bon itinéraire, pas sabotage aveugle.

**III-05 — Village des sources et arène Acier (arène 6).** Les habitants commencent à identifier le trio comme une vraie résistance ; un champion met à disposition une salle de repos, mais refuse que son nom apparaisse dans un rapport RR.

**III-06 — Archives du glacier, épreuve Roche.** Quatrième défi. La console révèle : **ALOÏS — DÉTENU — STATUT : VIVANT — SITE ÆTHER/ATLAS**. Trois réactions familiales distinctes, pas seulement celle du joueur.

**[ROLE_VYNA] :** « Il est vivant… On va vraiment pouvoir le retrouver. »
**[ROLE_RAIDON] :** « Alors qu'est-ce qu'on attend pour y aller ? »
**[ROLE_HYU] :** « Le complexe est encore hors d'atteinte. Mais cette fois on sait où chercher. »

**III-07 — Raid du glacier.** Divinité proposée **Kyurem** ; format **phases successives**, tempête de neige, cristaux et protections à rééquilibrer. Une nouvelle résonance est transmise.

**III-08 — Repaire Galaxie.** Mine et observatoire fusionnés en forteresse scientifique. Confrontations administrateur puis héritier, preuves de collaboration avec les autres branches. Le trio coupe l'extraction et rend les commandes aux techniciens locaux.

**III-09 — Libération.** Retour du chauffage, ouverture des routes de montagne et des ateliers. Les champions de plusieurs îles échangent désormais discrètement au sujet des trois enfants. Le groupe reçoit un message anonyme le prévenant de **ne pas attaquer Æther avant d'avoir acquis la reconnaissance céleste**. Déblocage île IV ; **le biome draconique 3 est déjà ouvert depuis l'île I, mais son niveau devient maintenant adapté**.

## 12. INTERLUDE DRACONIQUE III

**Visite conseillée :** après île III libérée ; **accès réel dès l'île I libérée**.

**Biome 3 : hautes vallées, pics neigeux et grottes cristallines.** Épreuve 3/4 : protéger une migration de Pokémon draconiques, résoudre les passages de glace et combattre le maître local. Le conseil commence à respecter les trois enfants, mais leur rappelle qu'être forts ne leur donne pas le droit de posséder la réserve.

## 13. ÎLE IV — High-tech, ordre et inégalités

### 13.1 Histoire, géographie et occupation

Grande métropole habitée, trams, jardins suspendus, avenues, quartiers ouvriers, centrale marémotrice et tour de supervision énergétique. Les façades modernes cachent un système de surveillance et de ségrégation économique.

**Deux branches RR dominantes : Plasma et Flare.** Plasma administre le registre des dresseurs, la propagande et les laissez-passer ; Flare fabrique Couronne Zéro, possède l'industrie et protège des quartiers privilégiés. Elles collaborent, mais se disputent le futur partage du pouvoir. Rocket supervise une sécurité inter-branches depuis Atlas, pas une occupation locale uniforme aux uniformes identiques.

**Oppression visible :** identification obligatoire dans les transports, autorisations révoquées à certains habitants, taxes discrétionnaires, coupures de services en quartiers populaires, écrans de propagande, surveillance des cartes de dresseurs. Certains résidents privilégiés soutiennent réellement RR.

### 13.2 Nom — NON VALIDÉ

Propositions « Axion », « Novaxis » ou nom entièrement nouveau après finalisation du plan urbain. Quartiers de travail « Les Terrasses », « Quai des Turbines », « District Bas » et « Tour du Réseau » ; aucun nom validé.

### 13.3 Défis de biomes — proposition

1. **Centre urbain et transports : arène Électrik (arène 7, combat en fin de parcours)**, carrefours et circuits.
2. **Quartier industriel : épreuve Acier**, chaîne d'assemblage et appareils.
3. **Port marémoteur : épreuve Eau**, contrôle des courants.
4. **Tour de réseaux : épreuve Psy**, traitement des informations, sécurité et anticipation.

Une démonstration des capacités de RR a lieu tôt sur l'île, puis **la révélation majeure** n'arrive qu'après les archives du troisième biome, afin d'éviter une structure copiée à l'identique des trois chapitres précédents.

### 13.4 Casting local — propositions

- Responsable civil **Céline** : n'ose pas critiquer RR ; veut éviter des représailles sur les quartiers défavorisés.
- Champion Électrik **Iren**, maître Acier **Doran**, champion marémoteur **Naya**, maîtresse de la tour **Asha**.
- Admin Plasma **Kerr**, admin Flare **Elda**, héritier Plasma **Vérian**, héritier Flare **Caëlan**.
- Résistante de quartier **Mina** ; fonctionnaire du registre **Orel** ; technicien ayant travaillé pour les deux branches **Samil**.

### 13.5 Déroulé

**IV-01 — La ville vitrine.** Le trio arrive dans un centre commercial où tout paraît prospère. Plus bas, les habitants font la queue devant des postes d'identification. Les trois personnages comparent les quartiers, sans supposer que tout civil riche est un ennemi.

**IV-02 — Repérage de l'arène Électrik et infiltration du registre.** La participation est autorisée, mais son combat principal est prévu plus loin au niveau ~93 ; le registre indique des résultats **partiellement manquants** pour les enfants, malgré les certifications détenues. Un inspecteur soupçonne plusieurs champions d'avoir effacé des données.

**IV-03 — Rencontre Flare.** L'héritier défend l'idée d'une civilisation développée pour quelques privilégiés. Il montre les avancées énergétiques réelles puis refuse de les partager à tous.

**Caëlan :** « Le progrès existe. Il suffit de choisir qui le mérite. »
**[ROLE_VYNA] :** « Donc ceux qui ne peuvent pas payer doivent vivre sans ? »
**Caëlan :** « Tous les privilèges ont une condition. »

**IV-04 — Épreuve Acier industrielle.** Énigmes de machines, accès à la centralisation des données. Pas de chantier interminable : deux ou trois étapes lisibles.

**IV-05 — District ouvrier et port énergétique, épreuve Eau.** Le trio aide une communauté à réactiver un service public au fil d'une épreuve de gestion marémotrice. Plasma déclenche des contrôles ciblés sur le groupe. Le héros est désormais connu sous son nom de dresseur si ce rôle est joué par l'humain ; affiches et radio peuvent parler du **trio**.

**IV-06 — Révélation Couronne Zéro.** Dans une salle de mesures, Hyu identifie des pics alignés exactement avec les raids gagnés aux îles I–III. Vidéoconférence du **conseil de la coalition**, Silver parmi ses membres ; on comprend que les branches ont récolté des données à distance malgré leurs défaites.

**Silver :** « Vous nous avez enlevé des territoires. Personne ne prétend le contraire. »
**Vérian :** « Vous avez aussi rempli nos registres de résultats remarquables. »
**Orien :** « Et chaque sanctuaire a livré une lecture irréproductible autrement. »
**[ROLE_HYU] :** « Nos combats… vous les mesuriez depuis le début. »
**[ROLE_RAIDON] :** « On a quand même libéré les habitants ! »
**[ROLE_VYNA] :** « Et on ne regrettera jamais de les avoir aidés. »
**Silver :** « Nous poursuivons des buts différents. Jusqu'à présent, vos actes ont servi les deux. »

La coalition ne « voulait pas perdre les îles » ; elle a anticipé et exploité le **risque** d'une victoire du trio, ce qui la rend crédible et faillible.

**IV-07 — Arène Électrik (arène 7), puis épreuve Psy de la tour et archives.** Après les défis de la ville, le trio affronte le champion Électrik niveau ~93 ; la tour et l'épreuve Psy (~94) mettent au jour des plans complets d'Æther et d'une voie vers l'île céleste impossible à forcer simplement. Un agent spécial RR tente une **évaluation finale** du trio, pas un combat de routine.

**IV-08 — Raid électrique.** Boss locaux proposés **Miraidon, Zekrom et Zeraora** ; format **simultané**, adaptation selon 1/2/3 joueurs et présence éventuelle de frères/sœur IA. Les espèces exactes et combats dépendent du roster définitif. La quatrième résonance est captée malgré la désactivation du complexe.

**IV-09 — Repaire Plasma/Flare.** Tour de contrôle à plusieurs secteurs : propagande et registre (Plasma), usine du noyau (Flare), salle mixte finale. Combats contre administrateurs de chaque branche, puis les héritiers dans un dernier affrontement local ou leur repli. Les deux organisations restent des partenaires majeurs de la coalition et conservent leurs dirigeants pour le final tant qu'ils ne sont pas capturés.

**IV-10 — Libération ambivalente.** Caméras et autorisations coercitives désactivées ; le quartier populaire célèbre ; les privilégiés ont peur de la transition. Les techniciens civils récupèrent les infrastructures ; les enfants ne deviennent pas gouvernants. Le quatrième biome draconique, déjà ouvert depuis l'île I, correspond maintenant au niveau de fin d'aventure.

## 14. Événements familiaux transversaux — scripts et synchronisation

L'histoire **ne doit pas** être une succession de scènes où les trois disent seulement « d'accord ». Ils voyagent, se taquinent et s'affrontent parfois pour le plaisir. Les séparations sont courtes et utiles.

### FAM-01 — Centre commercial / duel de la première île

**Déclencheur :** entrée dans le port, avant la première arène. **Lieu de regroupement :** cour de l'arène.

1. Vyna se rend au centre commercial pour chercher du matériel ; Hyu et Raidon étudient l'arène.
2. Chaque rôle a une petite tâche compatible solo/duo/trio. Le joueur humain contrôle son rôle ; les PNJ accomplissent leurs actions hors champ, sans autre compte ou sauvegarde.
3. Regrouper les **joueurs humains** pour le dialogue. Les PNJ se présentent automatiquement.
4. **Combat 1 : ROLE_HYU contre ROLE_RAIDON.** Deux humains → PvP ; un seul humain → humain/IA ; deux PNJ → simulation brève et résultat narratif sans cinématique longue.
5. **Combat 2 : ROLE_VYNA contre le vainqueur du combat 1**, avec la même logique.
6. La quête se termine qu'on gagne ou qu'on perde. Ne **jamais** obliger à obtenir la victoire pour progresser, ne jamais attribuer à un joueur une récompense fondamentale conditionnée à battre un autre humain.
7. Dialogue de clôture variable selon le vainqueur, une ou deux répliques ; pas de branchement majeur de l'histoire.

**[ROLE_RAIDON] :** « Avant l'arène, je veux vérifier si les théories de {NOM:ROLE_HYU} fonctionnent ! »
**[ROLE_HYU] :** « Tu as perdu nos deux derniers combats. »
**[ROLE_RAIDON] :** « Justement. Statistiquement, ça doit tourner ! »
**[ROLE_VYNA] :** « Vous vous êtes encore battus sans moi ? Très bien. J'affronte le gagnant ! »

Exemples d'objectifs dynamiques :
- Pour le rôle Hyu humain : « Rejoindre {NOM:ROLE_RAIDON} à la cour de l'arène », puis « Affronter {NOM:ROLE_RAIDON} ».
- Pour Vyna humaine : « Faire un tour au centre commercial », puis « Rejoindre le groupe et défier le vainqueur ».
- En duo ou trio : « Attendre que les autres joueurs arrivent à la cour de l'arène » ; ne pas déclencher la scène en l'absence du joueur humain attendu.

### FAM-02 — Veillée à la forêt de l'île II

Camp nocturne après l'épreuve des lanternes : chacun raconte sa façon de se souvenir d'Aloïs. Courte conversation, éventuellement un duel facultatif proposé par Raidon pour briser l'ambiance pesante. Pas de quête obligatoire qui impose de capturer ou échanger un Pokémon.

### FAM-03 — Refuge de Nivélis

Dans une tempête, les trois rôles ont des micro-objectifs simultanés (porte du refuge, ravitaillement, retrouver un Pokémon égaré). Le journal indique les tâches des autres joueurs sans permettre de valider leur objectif à leur place. En solo, les PNJ remplissent leurs tâches une fois le refuge atteint ; en coop, regroupement obligatoire avant ouverture du prochain chemin. Aucun rôle n'est dispensé d'une arène.

### FAM-04 — Désaccord avant la fin

Après la révélation sur Couronne Zéro, Raidon estime qu'ils ont aidé RR, Hyu rappelle que les îles ont réellement été libérées, Vyna souligne que renoncer reviendrait à abandonner les habitants. **Pas d'arc « une personne a tout faux et doit être corrigée »** : trois réactions compréhensibles. Leur accord se fonde sur un nouvel objectif commun.

**[ROLE_RAIDON] :** « Ils se sont servis de nous. »
**[ROLE_HYU] :** « C'est vrai. Et les gens que nous avons libérés le sont toujours. »
**[ROLE_VYNA] :** « Alors on arrêtera leur machine, sans abandonner ceux qu'on a aidés. »

### Règles de blocage et des combats familiaux

- Chaque scène collective a un lieu de regroupement, un ensemble de rôles attendus (toujours les trois narrativement) et un ensemble de **joueurs humains requis** ; les rôles PNJ ne bloquent pas indéfiniment.
- Tant qu'un humain manque : activité locale libre, journal « En attente de {NOM:ROLE_X} à [lieu] » et repère sur carte ; aucune téléportation ou commande forcée.
- Pour éviter les softlocks : rechargement restaure la phase de quête ; le retrait officiel d'un joueur par l'hôte réattribue son rôle à l'IA **uniquement quand les règles de campagne l'autorisent** et sans effacer son profil ; une nouvelle inscription rattrape les anciens chapitres selon N12.
- Le moteur de duel PvP ne démarre qu'avec deux humains présents ; après déconnexion, revenir à l'état d'avant combat conformément au cadrage coop. En cas de victoire/défaite, les deux conservent la participation scénaristique.
- Aucun échange de Pokémon, d'objet ou de compte n'est requis pour compléter une quête familiale.
- **Ne pas faire du choix de rôle un verrou de contenu :** chacun peut explorer, combattre les champions et récolter ses validations.

## 15. INTERLUDE DRACONIQUE IV — Le dernier Défi des Îles

### D4-01 — Le biome draconique le plus dangereux

**Accès au biome 4 :** dès la libération de l'île I. **Visite conseillée :** après l'île IV pour sa difficulté élevée (90–98). **Biome 4 :** crêtes volcaniques, orages et sanctuaire de haute montagne. **Épreuve 4/4 :** protéger une migration draconique d'un phénomène naturel dangereux, puis combat contre le quatrième maître. La réserve ne devient pas un chapitre de libération RR.

### D4-02 — Quatre épreuves vérifiées

Le conseil draconique examine les certifications du trio : **une épreuve dans chacun des quatre biomes**, aucune substitution par un simple badge d'une île ordinaire. Les trois ont le droit de passer à la **dernière arène** seulement après les quatre validations. L'IA accompagne les humains en solo.

### D4-03 — Dernière arène, championne Ilyra (nom proposé)

Ilyra dirige l'arène la plus difficile du Défi des Îles ordinaire, spécialisée Dragon avec une vraie équipe compétitive et de la couverture non monotype si besoin. Elle rappelle que le titre ne donne pas la propriété de l'île.

**Ilyra :** « Les combats ne font pas de vous des propriétaires. Ils montrent seulement jusqu'où vous êtes prêts à aller pour protéger. »

### D4-04 — Divinité de la réserve

Après la dernière arène, sanctuaire central et raid proposé contre **Zygarde** (phases successives, formes adaptées au roster). La divinité protège son équilibre naturel et n'est pas une captive RR. Les trois obtiennent la reconnaissance leur permettant de rejoindre Auralis. L'île **n'est jamais « libérée »**.

### D4-05 — Ouverture de l'accès céleste

Une ancienne porte s'ouvre au-dessus des nuages. Ilyra souhaite bonne chance aux trois enfants et promet que les habitants de la réserve contribueront à protéger les îles libres, pas à régner sur elles.

**Jalon :** quatre épreuves draconiques accessibles depuis la fin de l'île I + dernière arène Dragon niveau 100 + événement sacré = ACCES_CELESTE. La convergence avec la fin des îles II–IV doit être clarifiée avant codage du verrou céleste.

## 16. ÎLE CÉLESTE — Le Défi divin

### V-01 — Auralis (nom provisoire) et règles

L'île céleste est restée hors de portée de RR. Jardin sanctuaire et refuge au-dessus des nuages, **quatre portes de gardiens autour d'un cinquième sanctuaire central**, conformément au concept approuvé.

La prêtresse d'accueil **Séréna** (nom proposé) explique la différence entre force militaire et droit de veiller sur la Concordance. Le trio doit confirmer son entrée. Aucune intrusion RR à l'intérieur du défi : la menace demeure au large.

**Règles :** quatre combats successifs contre **quatre gardiens humains**, pauses entre matchs pour **soins, objets et CT** ; ni PC ni sortie. **Cinquième combat contre la divinité céleste**. Les quatre gardiens ne sont pas les « divinités » des îles ordinaires. La divinité finale n'est pas automatiquement Arceus ; un Pokémon original **Élydris** est proposé mais non choisi.

### V-02 — Gardien 1 : ténacité (nom proposé Corven)

Combat offensif soutenu. **Corven :** « Montre-moi que tu peux tenir même lorsque l'adversaire prend l'avantage. »

### V-03 — Gardienne 2 : connaissance (nom proposé Sélène)

Combat de terrains/contrôle. **Sélène :** « Ceux qui connaissent les règles peuvent apprendre à les dépasser. Ceux qui les ignorent n'ont aucune chance. »

### V-04 — Gardien 3 : résilience (nom proposé Eryon)

Combat de ressources et endurance. **Eryon :** « Être puissant ne veut pas dire se précipiter. »

### V-05 — Gardienne 4 : harmonie (nom proposé Ysara)

Équipe polyvalente difficile, adaptation aux synergies. **Ysara :** « Gagner ne signifie rien si tu détruis ce que tu étais venu défendre. »

### V-06 — Combat 5 : dieu de la Concordance (espèce non validée)

Cinquième porte, cinématique sobre, duel/boss unique. Après victoire, le titre **Gardien d'Archélys** est reconnu **pour les joueurs ayant accompli les conditions** ; les PNJ ont leur reconnaissance dans l'histoire, sans être des comptes joueurs. La divinité ne devient **pas capturable** avant le postgame.

### V-07 — L'alerte

Couronne Zéro est activée depuis Æther avec les signatures captées. Une faille lumineuse apparaît au large. Le conseil RR lance la phase terminale. Une brève transmission révèle Aloïs toujours détenu.

**Aloïs :** « Mes enfants, n'approchez pas de la machine sans pouvoir refermer les passages ! »
**[ROLE_VYNA] :** « Papa ! »
**[ROLE_RAIDON] :** « On arrive ! »
**[ROLE_HYU] :** « Il faut organiser l'assaut avec toutes les îles libres. »

**Jalon :** DEFI_DIVIN_TERMINE → ASSAUT_AETHER. Aucune capture des légendaires à ce stade.

## 17. ACTE FINAL — Ancien Æther, bastion de la coalition Rainbow Rocket

### 17.1 Architecture et situation

Le complexe scientifique artificiel offshore autrefois lumineux est devenu une garnison : campus et logements de chercheurs réquisitionnés, ponts de sécurité, prison souterraine, laboratoires des six branches et noyau de Couronne Zéro. **Nœud Atlas** reste un nom de travail.

Les quatre îles libérées coordonnent l'offensive. Les champions et doyens reprennent les transports, sécurisent les civils, ouvrent des routes ; la réserve draconique assure des missions de protection. **Aucune île n'est reconquise automatiquement par RR juste pour allonger l'histoire.**

### 17.2 F-01 — La réunion familiale au quai

Avant le départ, les trois enfants revoient la maison et leurs alliés. Les champions rencontrés auparavant échangent enfin ouvertement leurs véritables opinions. Leur espoir est **mérité** : ils ont vu le trio progresser, certains ont caché les rapports, puis assisté à la libération réelle.

**Champion de l'île I :** « J'ai cru qu'il s'agissait de trois gamins courageux. J'avais tort de sous-estimer leur détermination. »
**Championne Psy de l'île II :** « Ce futur n'était pas certain. Il ne l'est toujours pas. Mais nous pouvons les aider à le rendre possible. »

### 17.3 F-02 — Débarquement et secteurs de coalition

La flotte détourne les derniers vaisseaux de sécurité. Les frères et sœur entrent par le campus ; la progression alterne **plusieurs secteurs** au lieu d'un tunnel de six boss collés.

- Secteur **Magma** : centrales et refroidissement, sbires/officier, chef survivant ou représentant.
- Secteur **Aqua** : écluses et hangars maritimes, neutralisation du blocus, représentante.
- Secteur **Galaxie** : instruments de mesure, stabilisateurs et données du père, héritier.
- Secteur **Plasma** : fichiers des dresseurs, contrôle des détenus, propagande, héritier.
- Secteur **Flare** : chambre d'assemblage, sécurité industrielle et réacteur, héritier.
- Secteur **Rocket** : renseignement, dernier commandement et défense centrale, Silver.

Chaque sous-secteur doit posséder un **objectif réel** (ouvrir prison, désactiver contrôle, sécuriser circuit), une interaction et éventuellement un affrontement, avec pauses et soins. Les combats exacts pourront être regroupés pour ne pas transformer le final en marathon incohérent.

### 17.4 F-03 — Les dirigeants tombent comme coalition

Les chefs n'ont pas tous le même sort : ceux qui se rendent sont arrêtés ; celui ou ceux qui tentent de poursuivre la violence malgré la défaite peuvent disparaître tragiquement lors d'une surcharge, **sans gore**, à condition que leur motivation et le danger aient été préparés. La liste définitive de morts/survivants est à valider avant écriture des cinématiques.

**Héritier Magma :** « Si vous détruisez le noyau, l'île ne sera plus qu'un champ de ruines industrielles. »
**[ROLE_HYU] :** « Alors nous transférerons les commandes aux ingénieurs qui y vivent. »
**Héritière Aqua :** « Vous nous avez pris les routes maritimes, pas notre détermination. »
**[ROLE_VYNA] :** « Les routes n'ont jamais été à vous. »
**Héritier Plasma :** « Le registre faisait de chaque dresseur un candidat. Nous avons juste appris à les classer. »
**[ROLE_RAIDON] :** « On est venus prouver que vos classements ne vous donnent aucun droit sur nous. »

Le jeu doit montrer la **responsabilité partagée des six**, notamment dans les archives et le dialogue final.

### 17.5 F-04 — Prison et retrouvailles avec Aloïs

Après la neutralisation d'une partie des systèmes, les frères et sœur atteignent le centre de détention. Aloïs reconnaît **ses trois enfants**, peu importe lequel ou lesquels sont joués par des humains.

**Aloïs :** « Vyna... Raidon... Hyu... »
**Aloïs, si rôle humain :** noms affichés via {NOM:ROLE_VYNA}, {NOM:ROLE_RAIDON}, {NOM:ROLE_HYU}, et jamais noms fixes.
**[ROLE_VYNA] :** « On t'a enfin retrouvé ! »
**[ROLE_RAIDON] :** « Ils ne te garderont pas une minute de plus. »
**[ROLE_HYU] :** « On a besoin de toi pour stabiliser la machine. Et ensuite, on rentre. »
**Aloïs :** « Mes enfants… je savais que vous viendriez. Mais jamais je n'aurais voulu vous exposer à un tel danger. »

Retrouvailles longues juste ce qu'il faut. Aloïs explique qu'il a volontairement caché dans ses recherches **une méthode d'arrêt exigeant une reconnaissance céleste authentique**, raison pour laquelle la libération des îles et le Défi divin étaient nécessaires. Il conseille, mais le trio agit.

### 17.6 F-05 — Salle du conseil et dernier affrontement

La dernière opposition est **la coalition**, pas simplement un tyran et cinq sbires. La chambre de Couronne Zéro a été construite et alimentée par toutes les branches. Les dirigeants encore opérationnels y exposent leurs désaccords avant que l'infrastructure ne se retourne contre eux.

Silver commande les forces Rocket et peut être **le dernier dresseur affronté** dans la séquence, mais ne doit pas s'approprier toute la responsabilité ni tout le récit. Les autres chefs ont déjà été des ennemis autonomes et les blocages techniques ne s'arrêtent pas simplement avec sa défaite.

**Silver :** « Mon père croyait qu'un emblème suffisait à imposer la peur. Vous nous avez montré que la peur ne suffit pas. »
**[ROLE_RAIDON] :** « Alors arrête de nous combattre. »
**Silver :** « Je n'ai jamais appris à céder parce qu'on me l'ordonne. »
**[ROLE_VYNA] :** « Les autres chefs ont eu le choix, eux aussi. »
**[ROLE_HYU] :** « Et toute cette machine repose sur les mêmes erreurs. »

**Combat final :** difficulté maximale, vraie victoire possible, pas de perte scriptée obligatoire. Prévoir une présentation et des stratégies dignes du dernier adversaire, sans décider ici une équipe ou une Méga définitive.

### 17.7 F-06 — La rupture de Couronne Zéro

Le dispositif, instable parce que les empreintes ont été forcées, crée une déchirure dimensionnelle. Un chef refusant de renoncer peut subir une fin dramatique par excès de confiance (à arbitrer), pas de gore, pas de mise à mort gratuite. Des systèmes sont détruits ; évacuation des prisonniers et civils en priorité.

Aloïs révèle la commande finale ; les trois enfants unissent leurs efforts : l'un protège les accès, un autre coordonne l'évacuation, le dernier active le mécanisme, **sans retirer au joueur un rôle décisif selon son choix de personnage**. Les tâches concrètes s'adaptent aux contrôles humains/IA.

**[ROLE_HYU] :** « La fermeture doit suivre l'ordre des cinq stabilisateurs. »
**[ROLE_VYNA] :** « Les chercheurs sont presque tous dehors. »
**[ROLE_RAIDON] :** « Alors c'est à nous de tenir jusqu'au bout. »
**Aloïs :** « Vous avez accompli ce que je n'aurais jamais pu faire seul. »

La divinité céleste rétablit les passages à l'appel de ceux qui ont réussi le défi. **Le trio gagne parce qu'il agit et a acquis la reconnaissance**, pas parce qu'une prophétie lui garantit la victoire.

### 17.8 F-07 — Évacuation, chute du commandement et libération finale

Les derniers réseaux RR s'éteignent, les navires du blocus déposent les armes, les habitants des quatre îles occupées précédemment reçoivent les messages de victoire. Les prisons libèrent les détenus ; les héritiers rendus sont arrêtés et attendent jugement ; les branches perdent personnel, financements, transports et machines.

Aloïs rentre avec **ses trois enfants**. La région ne remplace pas RR par le pouvoir absolu du Gardien : les îles reprennent leur autonomie.

**[ROLE_VYNA] :** « Regardez les ports... »
**[ROLE_RAIDON] :** « Plus un seul pavillon Rainbow Rocket. »
**[ROLE_HYU] :** « Leurs réseaux sont coupés. Ce n'est plus une simple victoire locale. »
**Aloïs :** « Vous avez libéré toute une région. Maintenant, rentrons à la maison. »

## 18. ÉPILOGUE — Une liberté à entretenir

Plusieurs semaines après, la maison familiale du premier port redevient un lieu de réunion. Les champions et anciens maîtres d'épreuves reviennent pour une fête, mais aussi pour préparer l'autonomie des villes. La championne Psy a une dernière scène : sa vision montrait une catastrophe et une victoire **possibles** ; ce sont les décisions des trois qui en ont déterminé l'issue.

Les trois continuent à aimer les combats, à se taquiner et à voyager ; leur famille ne se dissout pas artificiellement quand le générique arrive. Aloïs peut reprendre ses recherches sous contrôle civil.

**Aloïs :** « J'ai passé des années à chercher ce qu'il y avait de l'autre côté de ces portes. »
**[ROLE_VYNA] :** « Et maintenant ? »
**Aloïs :** « Maintenant, je préfère profiter de ce qui m'attend de ce côté-ci. »

La célébration et le générique terminent la campagne principale.

## 19. POSTGAME — Réparer, explorer, défendre

1. **Sanctuaires des îles :** raids rejouables et captures légendaires individuelles après la fin de l'histoire seulement. Une personne peut aider un ami à refaire un raid sans gagner un deuxième légendaire, conformément aux choix précédents.
2. **Huit arènes d'Ultra-Dimension :** domaines distincts et champions de haut niveau (météo, terrain, distorsion, usure, vitesse, doubles, équilibrage), sans copier huit arènes officielles. Leur contenu détaillé doit suivre le Pokédex final.
3. **Défense du titre céleste :** revanches contre les gardiens, tournoi ultime, difficulté élevée et sans faux pouvoir royal.
4. **Restes d'Æther :** recherche d'archives et anomalies laissées par Couronne Zéro, sans « résurrection de Rainbow Rocket » automatique ni annulation de la victoire.
5. **Monde transformé :** nouveaux commerces, quêtes civiques, routes dégagées, rencontres sauvages/PNJ supplémentaires, retours sur l'île draconique.
6. **Rivalités familiales :** combats de revanche entre Vyna, Raidon et Hyu, humains ou IA selon le mode, facultatifs et sans échanges imposés.

## 20. Registre des jalons narratifs à implémenter plus tard

Noms **indicatifs** des drapeaux pour Codex ; ne pas changer un schéma de sauvegarde existant sans étude de migration. Chaque jalon comporte une progression collective de chapitre **et** une participation/validation par joueur humain si pertinente.

| ID logique | Préconditions | Effets narratifs |
|---|---|---|
| SC_PROLOGUE_INSCRIT | Starter, inscription des trois rôles | Cartes de dresseur et accès première route |
| SC_I_BIOMES_OK | 4 défis locaux terminés | Accès au sanctuaire volcanique |
| SC_I_RAID_OK | Biomes I validés | Repaire Magma accessible, légendaire non capturable |
| SC_I_LIBEREE | Raid I + repaire Magma | Patrouilles retirées ; île II + DRAGON_BIOMES_1_2_3_4 ouverts ensemble |
| SC_D1_OK | Première épreuve draconique | Certification 1/4 |
| SC_II_LIBEREE | Défis II + raid + repaire Aqua | Île III ; aucun nouveau verrou draconique levé |
| SC_D2_OK | Deuxième épreuve draconique | Certification 2/4 |
| SC_III_PERE_VIVANT | Consultation du dossier Galaxie | Journal : Aloïs détenu à Æther |
| SC_III_LIBEREE | Défis III + raid + repaire Galaxie | Île IV ; aucun nouveau verrou draconique levé |
| SC_D3_OK | Troisième épreuve draconique | Certification 3/4 |
| SC_IV_TWIST | Découverte des relevés des raids | Révélation Couronne Zéro, journal et dialogues adaptés |
| SC_IV_LIBEREE | Défis IV + raid + repaire Plasma/Flare | Fin de l'occupation des quatre îles ; les biomes draconiques restent déjà ouverts |
| SC_D4_OK | Quatrième épreuve draconique | Certification 4/4 |
| SC_DRAGON_ARENE_OK | D1 + D2 + D3 + D4 | Dernière arène draconique gagnée |
| SC_DRAGON_TERMINE | Arène + raid draconique | ACCES_CELESTE |
| SC_CELESTE_GARDIENS | 4 gardiens gagnés | Cinquième porte autorisée |
| SC_CELESTE_TITRE | 5e combat gagné | Titre/clé par joueur éligible, ASSAUT_AETHER |
| SC_AETHER_PERE_LIBRE | Sections prison résolues | Père retrouvé, méthode d'arrêt connue |
| SC_RR_COALITION_VAINCUE | Secteurs des branches + final | Couronne Zéro neutralisée, blocus et RR détruits |
| SC_CAMPAGNE_FINIE | Évacuation + épilogue | Postgame, captures légendaires, Ultra-Dimension, défenses du titre |

**Dépendance essentielle :** les quatre îles ordinaires ne sont **libérées qu'après le raid ET le repaire**, pas au badge final ni au raid. La réserve draconique n'a **aucun drapeau de libération**. Le Défi divin ne s'ouvre pas à partir des seuls badges des quatre îles.

## 21. Journal de quêtes, dialogues et vie des PNJ

Chaque scène à traduire ensuite en données comprend : ID stable ; zone ; fenêtre scénaristique ; protagonistes ; éventuel lieu de rendez-vous ; objectif affiché ; conditions d'ouverture ; répliques avec noms dynamiques ; ennemi et type de combat ; résultats ; mise à jour du monde ; version FR/EN ; rejouabilité et conditions de sauvegarde.

**Exemple de libellés, compatibles 1 à 3 joueurs :**
- « Retrouver la famille à la cour de l'arène. »
- « Attendre {NOM:ROLE_VYNA} à la cour de l'arène. » (seulement si Vyna est jouée par un humain attendu.)
- « Affronter {NOM:ROLE_RAIDON} en combat Pokémon. »
- « Déterminer d'où provient l'énergie volée à la jungle. »
- « Remporter les quatre épreuves de la réserve draconique avant la dernière arène. »
- « Rejoindre les autres joueurs à l'entrée du repaire Magma. »
- « Libérer notre père et neutraliser le conseil Rainbow Rocket. »

**États d'ambiance à prévoir :** AVANT_OCCUPATION? (historique raconté seulement), OCCUPEE, SOULEVEMENT, LIBEREE. Après libération : suppressions/réduction des contrôles, nouvelles heures d'ouverture, dialogues et services distincts, trafic maritime rétabli, champion plus franc. Ne pas provoquer d'apparition permanente de tous les PNJ de fête dans chaque ville.

**Progression de l'espoir :**
- Île I : « Ils ont du potentiel. »
- Île II : « Peut-être pourraient-ils changer quelque chose. » Plusieurs champions commencent à couvrir leurs traces.
- Île III : actes de soutien matériel ; un champion prend le risque de masquer les résultats, la coalition enquête.
- Île IV : les habitants connaissent les noms de dresseur des frères et sœur ; surveillance ciblée, mais solidarité visible.
- Æther : les alliés sont là parce qu'ils ont été aidés, pas parce qu'un titre leur a été annoncé dans une prophétie.

## 22. Administration RR et cohérence de son plan

- Le registre RR permet d'identifier les dresseurs capables de réussir les raids et d'exiger les certifications des champions ; il ne permet **pas** de contrôler magiquement leurs Pokémon.
- Un champion peut signer la victoire localement, différer le transfert central, altérer un indicateur officiel ou prétendre à une panne ; la carte du joueur conserve le résultat réel.
- Un inspecteur remarque des écarts entre cartes, journaux d'arène et rapports centraux. Le secret partiel finit par s'éventer ; pas d'invisibilité scénaristique illimitée.
- Les agents spéciaux ponctuels du conseil ont un rôle **d'évaluation** de la puissance du trio. Proposition de cadence : fin de I (observation sans combat majeur), II (un test sérieux), III (interception ponctuelle), IV (dernier test au moment de la révélation). Chaque repaire possède sa propre hiérarchie et son propre adversaire majeur ; ne pas additionner mécaniquement un combat spécial sur chaque route.
- Les héritiers peuvent se disputer les ressources et les priorités, mais restent **coresponsables** du projet. Ils ne deviennent pas des victimes de Silver, ni des patriotes incompris sans décisions explicites.
- Le conseil sait que les divinités exigent une puissance élevée ; il n'a pas prévu que **ces trois** gagneraient nécessairement. Il adapte sa stratégie en observant leur succès, d'où un suspense crédible.
- Ne pas inventer d'obligation de combat légendaire répétitif contre le même boss à chaque retour sur une île.
- Les captures légendaires n'arrivent pas avant le postgame.

## 23. Arbitrages encore ouverts — NE PAS FIGER

1. Noms définitifs des **six îles** et lieux, des champions, maîtres d'épreuves, doyens, admins et nouveaux héritiers (tous noms proposés ici non validés).
2. Identités visuelles et espèces des **starters**, du Pokédex définitif, des formes delta et Fakemons ; choix des divinités locales et de l'éventuel dieu céleste original.
3. **Répartition des arènes fixée :** îles I, II, III = deux arènes chacune ; île IV = une ; réserve draconique = une dernière arène. Soit **huit arènes** : Plante, Feu, Psy, Ténèbres, Glace, Acier, Électrik, Dragon. Les épreuves de biomes et leurs mini-jeux sont proposés dans [ARENES_EPREUVES_COURBE_V1.md](ARENES_EPREUVES_COURBE_V1.md). Les quatre épreuves de l'île draconique + dernière arène sont imposées.
4. Fonctions exactes de la Concordance, conditions des portails et Couronne Zéro ; c'est un fil rouge narratif proposé, à valider.
5. Distribution finale des branches **Aqua/Galaxie/Plasma/Flare** entre les îles II–IV ; Magma sur l'île I et Coalition à Æther sont les références récentes de conversation.
6. Identité et sort individuel des chefs qui se rendent ou refusent ; scène dramatique sans gore, aucun décès nominatif définitivement décidé ici.
7. Liens familiaux précis, foyer et chronologie : **trois frères et sœur avec père commun** = acté ; leur éventuel statut de triplés, la présence et le prénom de la mère = non tranchés.
8. Identité et mécanique des quatre gardiens célestes, difficulté / niveaux / nombre d'administrateurs / équipes finales ; consulter règles de difficulté, caps et raids avant implémentation.
9. Formulation définitive du questionnaire de profil, gestion des égalités et personnalisation visuelle des avatars (propositions données).
10. Les huit arènes de l'Ultra-Dimension, cinématiques finales et musique à produire ensuite. Une proposition dans ce document ne vaut pas intégration automatique.

## 24. Liste de vérification pour Codex

Avant de convertir cette bible en contenu jouable, contrôler les scénarios suivants :

- [ ] En solo Vyna, Raidon ou Hyu, le groupe contient **exactement trois frères et sœur** avec deux PNJ pertinents, jamais quatre personnages.
- [ ] Un Hyu joué sous « Hyugal » est nommé « Hyugal » dans les bulles, labels et objectifs, tout en gardant ses répliques et traits propres au ROLE_HYU.
- [ ] En duo/trio, un rôle = un propriétaire humain, autres rôles IA seulement si libres ; aucune scène destinée au quatrième héros.
- [ ] Le duel familial fonctionne : joueur/joueur, joueur/IA, IA/IA ; après un duel perdu, la suite est possible ; aucun échange obligatoire.
- [ ] Une scène de regroupement attend les humains présents dans la campagne ; les PNJ n'imposent pas un blocage éternel ; sauvegarder/charger conserve la bonne phase.
- [ ] Les quatre îles occupées ont des restrictions visibles et des états libérés différents ; les arènes restent officiellement autorisées et connectées au registre RR.
- [ ] Les champions peuvent cacher les rapports sans empêcher les joueurs de conserver leurs validations.
- [ ] Chaque branche RR possède des sbires, une hiérarchie et un rôle économique/narratif ; Silver n'écrase pas les cinq autres chefs.
- [ ] Les interventions RR importantes ne sont pas toutes au même moment du chapitre.
- [ ] Chaque île ordinaire termine par raid local, repaire, puis libération, dans cet ordre.
- [ ] Après île I libérée, **les quatre biomes et les quatre épreuves draconiques** sont accessibles immédiatement ; **aucune ouverture de biome** liée aux îles II–IV ; quatre épreuves obligatoires avant dernière arène.
- [ ] Réserve draconique et île céleste **jamais occupées** ; aucun texte « île draconique libérée ».
- [ ] Accès céleste seulement après dernière arène draconique et conclusion de sa divinité.
- [ ] Défi divin : **4 gardiens + 1 dieu**, pas 4 combats dont le dieu ; pas d'accès PC ni départ entre les cinq combats.
- [ ] Père retrouvé à Æther par les **trois enfants**, libéré avant la résolution finale de la coalition.
- [ ] Générique après démantèlement effectif de Rainbow Rocket ; légendaires capturables uniquement après.
- [ ] Dialogues importants et objectifs localisables FR/EN ; noms dynamiques non codés en dur.
- [ ] Aucun script de ce document n'affirme qu'une fonctionnalité 3D/2D, réseau ou boss est déjà implémentée ou validée visuellement.
- [ ] Ne pas publier les spoilers dans le wiki joueurs ; protéger les anciennes sauvegardes au moment d'ajouter de nouveaux jalons.

---

**Conclusion créative :** Pokémon Archélys est d'abord l'histoire d'une fratrie qui cherche son père. Son inscription au Défi des Îles, utilisé par les criminels comme système de recrutement et de surveillance, l'amène à rendre espoir aux habitants. En démantelant les branches de la coalition, les enfants découvrent que leurs victoires contribuent aussi à une arme dimensionnelle. Ils terminent les quatre épreuves de la réserve draconique, gagnent l'épreuve céleste en cinq combats puis réunissent les peuples libérés pour sauver leur père et abattre **la coalition tout entière**.