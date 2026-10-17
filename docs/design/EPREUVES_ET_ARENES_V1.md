# Pokémon Archélys — Arènes et épreuves, conception détaillée V1

> **RECTIFICATIF DU 17 OCTOBRE 2026 — DÉCISIONS PROPRIÉTAIRE, PRIORITÉ SUR LES PROPOSITIONS ANTÉRIEURES.** À la suite de l'audit D118 : île I = **arènes Plante et Feu**, raid → repaire Magma → libération, puis **épreuve de traversée Île I → II à dos de Sharpedo** (monture existante à réutiliser, sans nouvelle implémentation déduite). Les anciennes épreuves obligatoires de la canopée, des galeries et de la plage sont remplacées comme défis officiels ; leurs secteurs, quêtes, énigmes et PNJ peuvent rester comme exploration et missions secondaires. Île II = arènes/épreuves existantes conservées ; **après raid → repaire Aqua → libération**, épreuve de traversée à dos de **Dracaufeu**, déblocage de **Vol libre + voyage rapide vers les villes**, arrivée sur l'île III. Réserve draconique = accès à l'île après libération de I ; **quatre accès de biomes disponibles immédiatement, mais chacun gardé par un gardien à vaincre pour ouvrir son biome**. Aucune condition de libération des îles II–IV pour entrer dans l'un de ces quatre biomes. Les équipes D01–D04 au palier 38 sont proposées comme gardiens d'entrée ; les tiers supérieurs deviennent des **revanches optionnelles**, pas des clés de zone. Les tâches des quatre épreuves draconiques restent pertinentes pour la dernière arène. Ce rectificatif remplace toute condition contraire plus bas.

> **SPOILERS DEV / PROPOSITION au 16 octobre 2026.** Les types et le nombre d'arènes ainsi que les tranches de niveaux viennent du propriétaire ; noms, énigmes, plans et PNJ restent proposés. Les équipes complètes associées sont dans [EQUIPES_TACTICA_ARCHIPEL_V1.md](EQUIPES_TACTICA_ARCHIPEL_V1.md). Le récit est dans [SCENARIO_INTEGRAL_V2_CODEX.md](SCENARIO_INTEGRAL_V2_CODEX.md). Aucun bâtiment, combat, puzzle ou mode coop décrit ici n'est déclaré déjà implémenté.

## Décisions et paliers

**Huit arènes** : deux dans chacune des trois premières îles, une sur l'île high-tech, puis la dernière Dragon sur la réserve indépendante. Types : **Plante / Feu / Psy / Ténèbres / Glace / Acier / Électrik / Dragon**.

| Zone | Plage propriétaire | Gym(s) : ace proposé | Épreuve(s) : ace proposé | Raid et repaire |
|---|---|---|---|---|
| Île I tropicale | 1–38 | 18, 36 | Traversée Sharpedo après libération ; pas de combat maître obligatoire | 38 / Magma |
| Île II mystique | 40–57 | 45, 55 | Fée 50, Spectre 55 ; traversée Dracaufeu après libération | 57 / Aqua proposé |
| Île III hivernale | 60–80 | 64, 78 | 69, 78 | 80 / Galaxie proposé |
| Île IV high-tech | 80–95 | 93 | 84, 89, 93 | 95 / Plasma et Flare proposés |
| Réserve Dragon | disponible après fin I | arène finale 98 (proposé) | 4 gardiens d'entrée ace 38 ; activités des 4 épreuves, revanches 57/80/95 facultatives | raid final ; **jamais occupée** |
| Île céleste | 100 | Aucune | 4 gardiens + dieu (5 combats) | Pas d'occupation |

**Règle draconique corrigée le 17 octobre :** l'île et les **quatre portes de biomes** sont accessibles dès la libération de l'île I, **mais la traversée de chaque porte exige de battre son propre gardien** (combat d'accès niveau 38 proposé, même si le joueur est allé ailleurs auparavant). Aucun biome ne dépend des îles II/III/IV ni des trois autres gardiens. Une fois la porte vaincue, son biome est librement exploré et les espèces draconiques y restent disponibles, sans verrou tardif. Les quatre activités d'épreuve déjà imaginées peuvent être achevées pour recevoir leurs certificats ; ne pas imposer un second combat de maître identique après le gardien. Les équipes adaptatives 57/80/95 sont réservées à d'éventuelles revanches volontaires. La dernière arène Dragon à haut niveau reste le dernier défi ; l'obligation de finir les quatre îles ordinaires avant elle reste **une proposition à valider**.

**Ordre des fins d'îles occupées, impératif :** défis principaux du chapitre → raid légendaire sans capture → repaire de la branche RR dominante → libération et changements des PNJ. **Spécificités de voyage post-libération :** île I → Sharpedo vers II ; île II → Dracaufeu vers III. Ces transitions ne passent pas avant le raid/repaire et ne retardent pas la cinématique de libération. Les grandes interventions des branches RR se placent à des moments différents selon l'île.

## Principes de création des lieux

- Arènes **officiellement reconnues et surveillées** par le registre RR. La carte de dresseur est contrôlée à l'entrée ; le champion peut **certifier localement** l'insigne tout en retardant le rapport central. Ce retard ne bloque **jamais** la progression du joueur.
- Chaque arène : entrée / hall, 2 à 4 petites salles ou secteurs, 1 à 4 dresseurs, 1 puzzle résoluble avec des indices visibles, salle de champion ; pas de grande cinématique systématique.
- Épreuves : 2 à 3 interactions utiles, un danger ou problème lié au biome, un combat maître, récompense et état du monde sauvegardés. Des types complémentaires aux gyms quand c'est possible.
- **Solo/duo/trio :** trois frères et sœur ROLE_VYNA, ROLE_RAIDON, ROLE_HYU, contrôlés par un joueur ou un PNJ ; dialogues invariants, noms de dresseurs dynamiques pour les rôles humains. Des objectifs d'épreuve individuels peuvent être répartis, mais le moment de clôture attend tous les humains. Les PNJ s'y joignent automatiquement.
- Défaite ou déconnexion ne remplace pas une validation requise par un succès fictif. Jamais d'échange de Pokémon imposé, ni de Pokémon particulier nécessaire à un puzzle. Reprise depuis la dernière phase sauvée et aucun softlock.
- Les méthodes de combat, talents, objets, Méga et IV/EV de HARD doivent appliquer le référentiel Tactica ; voir fichier d'équipes. Les niveaux des Pokémon sauvages restent liés au **premier accès réel de la carte**.
- Le post-libération transforme les ports, patrouilles, guichets d'arènes, horaires et dialogues. Les champions peuvent alors soutenir ouvertement la résistance.

## Les huit arènes

### GYM-01 — Le jardin des marées

**Lieu :** Île I / port · **Type :** Plante · **Ace :** N.18 · **Équipe :** A01.

**Architecture et énigme :** Serre de pilotis entre arcades crème et bassins turquoise. Trois vannes permettent de diriger l'eau vers les plants A et C ; la floraison déploie deux ponts de lianes. Les tuyaux visibles indiquent la logique, un levier réinitialise sans punition.

**Parcours jouable :** Guichet officiel RR, couloir des vannes avec 2 petits dresseurs, salle du champion, insigne remis et résultat transmis normalement.

**Scénario :** Le champion remarque trois dresseurs complémentaires, sans les proclamer sauveurs. La première victoire ne menace pas encore directement le registre RR.

### GYM-02 — Les bassins solaires

**Lieu :** Île I / village géothermique · **Type :** Feu · **Ace :** N.36 · **Équipe :** A02.

**Architecture et énigme :** Terrasses de basalte et jardins thermaux. Trois miroirs et des vannes modifient le degré de chaleur de serres ; viser la température stable pour ouvrir la forge. Signaux froid/stable/chaud ; retour à l'entrée de salle en cas d'erreur.

**Parcours jouable :** Miroir extérieur, vapeur, galerie, 2 dresseurs, championne et certificat local.

**Scénario :** La championne reconnaît le nom d'Aloïs, remet un plan des galeries et retarde la transmission centrale du badge.

### GYM-03 — Le miroir des possibles

**Lieu :** Île II / lac de brume · **Type :** Psy · **Ace :** N.45 · **Équipe :** A03.

**Architecture et énigme :** Pavillon de pierre sombre et verrières violettes au-dessus du lac. Trois miroirs montrent deux reflets contradictoires ; des symboles au sol permettent de distinguer le vrai itinéraire du reflet trompeur. Pas de code aléatoire.

**Parcours jouable :** Trois petites salles de reflets, 2 dresseurs Psy, championne visionnaire.

**Scénario :** La championne pressent la venue de trois enfants apparentés, quatre îles libérées et une porte dangereuse ; sa vision indique des futurs possibles, pas une destinée assurée.

### GYM-04 — Le palais des ombres

**Lieu :** Île II / ruines · **Type :** Ténèbres · **Ace :** N.55 · **Équipe :** A04.

**Architecture et énigme :** Ruines à colonnades et panneaux occultants. Orienter trois cloisons pour former sur le mur une silhouette gravée dans une fresque ; chaque étape révèle un passage. Ombres visibles de la caméra.

**Parcours jouable :** Antichambre, deux alcôves d'ombres, 3 dresseurs, champion utilisant sa Méga.

**Scénario :** Le champion craint les représailles d'Aqua mais aide le groupe en certifiant localement sans donner tous les résultats au registre.

### GYM-05 — Les chenaux gelés

**Lieu :** Île III / fjord · **Type :** Glace · **Ace :** N.64 · **Équipe :** A05.

**Architecture et énigme :** Port de pierre et bois, bassin de glace avec petites dalles glissantes. Trois leviers soulèvent des barrières pour arrêter la glissade au bon endroit. Chaque puzzle est isolé et peut être réinitialisé.

**Parcours jouable :** Docks couverts, bassin supérieur, 3 dresseurs, champion maître du climat neige.

**Scénario :** Le champion a entendu parler des libérations et fournit l'accès aux refuges du plateau.

### GYM-06 — La forge des sources

**Lieu :** Île III / sources et forge · **Type :** Acier · **Ace :** N.78 · **Équipe :** A06.

**Architecture et énigme :** Forge traditionnelle et grandes roues de vapeur. Distribuer l'eau chaude aux maisons ET au four du gym ; quatre circuits avec jauges de température et conduites, sans couper définitivement le chauffage.

**Parcours jouable :** Hall de forgeron, trois circuits, 3 dresseurs, champion Acier et Méga.

**Scénario :** Le champion masque un nouveau résultat du trio et prend un risque pour protéger les familles privées de chauffage.

### GYM-07 — La chambre du courant

**Lieu :** Île IV / métropole · **Type :** Électrik · **Ace :** N.93 · **Équipe :** A07.

**Architecture et énigme :** Arène dans la tour de tram. Des tronçons de rails conducteurs tournent pour relier trois sources d'électricité à leurs récepteurs ; affichage clair des circuits complets et des obstacles.

**Parcours jouable :** Le champion peut être rencontré en arrivant sur l'île, mais son combat officiel se débloque tard après remise en route des services. Hall d'identification, trois circuits, 3 dresseurs, Méga.

**Scénario :** Les résultats des badges dissimulés sont confrontés au registre RR. La coalition commence à reconnaître le trio comme une menace et un outil potentiel.

### GYM-08 — Le sanctuaire du dernier dragon

**Lieu :** Réserve draconique / cour sacrée · **Type :** Dragon · **Ace :** N.98 · **Équipe :** A08.

**Architecture et énigme :** Quatre portes de biomes entourant une cour d'arène. Activer quatre stèles en reconstituant les symboles vus pendant les épreuves ; indices consignés au journal pour éviter le par-cœur.

**Parcours jouable :** Les quatre épreuves peuvent être accomplies dès la fin de l'île I. L'arène finale requiert en plus les quatre îles occupées libérées (proposition à valider). Championne Dragon, puis raid sacré proposé Zygarde.

**Scénario :** La championne défend l'indépendance de la réserve. Pas de libération RR ici : cette île n'a jamais été occupée. La victoire sacrée ouvre l'île céleste.

## Les épreuves de biomes

### EP-I-TR-01 — La passe des courants, Sharpedo (épreuve officielle de fin de l'île I)

**Lieu :** plage littorale de l'île I, corridor maritime vers l'île II · **Thème/type :** Eau · **Combat de maître :** aucun imposé · **Précondition :** **SC_I_LIBEREE** (raid volcanique + repaire Magma + cinématique de libération déjà achevés).

**Mise en scène :** après l'évacuation des garnisons, une responsable des transports explique que les ferries inter-îles demeurent bloqués par des résidus de surveillance Aqua ; Sharpedo permet d'utiliser un chenal étroit où les grands navires ne peuvent pas passer. L'équipe utilise le **système de Pokémonture Sharpedo déjà implémenté**, sans inventer une seconde monture ni imposer la capture d'un Sharpedo.

**Épreuve :** parler au responsable sur la plage ; voir le tracé du chenal sur une carte/quelques bouées ; monter sur Sharpedo ; franchir un parcours maritime de courants et rochers avec 2 ou 3 repères de navigation ; atteindre la plage d'arrivée de l'île II avec le trio regroupé. Difficulté par pilotage/repères et observation ; **pas de mécanique de pêche** et pas d'obligation d'échange ou de Pokémon de l'équipe. Les éventuels sbires maritimes ou obstacles sont facultatifs, pas un nouveau boss obligatoire.

**Journal / coop :** « Rejoindre la plage de départ », « Parcourir le chenal à dos de Sharpedo », « Retrouver les autres joueurs sur la côte de l'île II ». Départ et arrivée des scènes communes synchronisés ; les rôles PNJ traversent automatiquement dans le récit. Ne pas forcer un joueur éloigné à se téléporter sans son accord.

**Résultat :** certificat de traversée / autorisation maritime (nom à valider), arrivée sur île II. Le déblocage de l'île draconique reste lié à la libération de I, **pas** à ce certificat.

**Ancien contenu rétrogradé :** la canopée (ancien EP-I-01 / équipe T01) et les galeries (ancien EP-I-02 / équipe T02) restent des zones d'exploration, de quêtes et de progression ; leurs maîtres et combats ne sont **plus des préconditions** du raid, de la libération ou de la traversée. L'ancienne épreuve Eau sur plage basée seulement sur des vannes/passerelles est **remplacée** par Sharpedo, et ne s'ajoute pas comme troisième défi obligatoire.

### EP-II-TR-01 — La route des nuages, Dracaufeu (traversée finale de l'île II)

**Lieu :** zone de départ de l'île II après libération, trajet aérien vers l'île III · **Thème :** Vol · **Précondition stricte :** raid mystique → repaire Aqua → **cinématique de libération** II terminée. Cette traversée est **additionnelle aux deux épreuves de biome existantes** Fée/Spectre ; ne pas supprimer EP-II-01 ni EP-II-02.

**Déblocage :** une scène courte remet l'accès à la Pokémonture **Dracaufeu en vol libre** et au **voyage rapide vers les villes déjà découvertes** (règles de destination à vérifier et documenter). Ne pas prétendre que cette fonctionnalité est déjà implémentée : seule la disponibilité actuelle de Sharpedo a été indiquée explicitement.

**Épreuve :** décollage accompagné, pilotage sur un couloir aérien naturel balisé (nuages, vents, balises et courants ascendants), découverte visuelle de l'archipel, atterrissage contrôlé à l'île III. Pas de combat ni échange imposé ; le vol libre se débloque durant cette séquence et reste utilisable après ; le voyage rapide ne débloque pas instantanément des villes jamais visitées.

**Journal / coop :** « Parler au guide aérien », « Décoller sur Dracaufeu », « Traverser le bras de mer vers l'île III », « Rejoindre la fratrie au point d'arrivée ». En solo les PNJ suivent ; en coop les participants peuvent piloter indépendamment, puis se regroupent au point d'arrivée avant la scène d'introduction de III. La séparation n'annule pas leurs validations personnelles.

**Résultat :** accès pratique à l'île III, monture aérienne et Vol rapide ; les autres épreuves des îles II, III et IV demeurent telles que décrites ci-dessous.

### EP-II-01 — Le sentier des lanternes

**Lieu :** Île II / forêt des lanternes · **Type :** Fée · **Ace ou tier :** N.50 · **Équipe :** T03.

**Épreuve :** Distinguer trois lanternes originales de leurs illusions en suivant clignotements et inscriptions. Les faux chemins retournent au dernier carrefour, pas au port. Combat Fée puis discussion familiale au camp.

**Scénario / résultat :** Forêt libérée de la peur entretenue par Aqua ; courte scène nocturne entre frères et sœur.

### EP-II-02 — Les archives impossibles

**Lieu :** Île II / observatoire · **Type :** Spectre · **Ace ou tier :** N.55 · **Équipe :** T04.

**Épreuve :** Associer trois vues de constellation à trois dates pour identifier un dossier falsifié. Pas de chiffres devinés ; indices lisibles dans la même salle. Combat du maître des archives.

**Scénario / résultat :** Évoque la Concordance et les travaux du père, mais ne révèle pas encore son emplacement. Après le raid mystique, repaire Aqua et libération.

### EP-III-01 — Les balises de l'orage blanc

**Lieu :** Île III / plateau · **Type :** Vol · **Ace ou tier :** N.69 · **Équipe :** T05.

**Épreuve :** Réactiver trois refuges, suivre des balises visibles aussi par leur forme, secourir un Pokémon perdu. Les trois rôles accomplissent de courtes tâches séparées, puis regroupement avant le combat maître.

**Scénario / résultat :** Galaxie intervient principalement après ce deuxième biome : elle ferme le chauffage pour punir les protestations.

### EP-III-02 — La mine des cristaux

**Lieu :** Île III / glacier · **Type :** Roche · **Ace ou tier :** N.78 · **Équipe :** T07.

**Épreuve :** Orienter deux prismes pour ouvrir une galerie sécurisée, garder une température stable et consulter les archives. Combat du maître du glacier.

**Scénario / résultat :** Découverte majeure : Aloïs est vivant, emprisonné à Æther. Après ce défi, raid glacier puis repaire Galaxie.

### EP-III-OPTION — L'épreuve du circuit thermal — facultative

**Lieu :** Île III / village des sources · **Type :** Eau · **Ace ou tier :** N.78 · **Équipe :** T06.

**Épreuve :** Diriger les vannes pour maintenir la cascade et la chaleur d'un quartier. Combat du maître Eau, récompense non indispensable.

**Scénario / résultat :** Ce défi est un contenu secondaire possible et ne constitue PAS un cinquième biome ou une condition de libération.

### EP-IV-01 — Le circuit interrompu

**Lieu :** Île IV / usine · **Type :** Acier · **Ace ou tier :** N.84 · **Équipe :** T08.

**Épreuve :** Régler la vitesse de trois convoyeurs pour acheminer des pièces de remplacement vers les habitants ; indicateurs synchronisés, état sauvegardé. Combat maître Acier.

**Scénario / résultat :** Preuve du détournement de matériel civil par Flare.

### EP-IV-02 — Les courants des turbines

**Lieu :** Île IV / port marémoteur · **Type :** Eau · **Ace ou tier :** N.89 · **Équipe :** T09.

**Épreuve :** Orienter quatre digues sur le plan du canal pour fournir les logements sans mettre les Pokémon aquatiques en danger ; aucun objet spécial à échanger. Combat maître Eau.

**Scénario / résultat :** Les contrôles de Plasma sur le trio s'intensifient.

### EP-IV-03 — La mémoire du registre

**Lieu :** Île IV / tour des données · **Type :** Psy · **Ace ou tier :** N.93 · **Équipe :** T10.

**Épreuve :** Reconstruire trois journaux de logs : badges certifiés, résultat central, captation d'énergie. Les différences rendent visible que RR a mesuré les raids depuis l'île I. Combat maître Psy.

**Scénario / résultat :** Révélation de Couronne Zéro : le trio a réellement libéré les îles mais ses raids ont aussi fourni des signatures à la coalition.

### DR-01 — Le souffle des falaises

**Lieu :** Réserve draconique / falaises · **Type :** Dragon / Vol · **Ace ou tier :** N.38 à l'entrée (57/80/95 en revanche optionnelle) · **Équipe :** D01.

**Épreuve :** Franchir trois arches en lisant la direction du vent, relever deux balises tombées, calmer un nid d'Altaria ; duel contre le maître adaptatif.

**Scénario / résultat :** Certificat des Cimes ; disponible sans autre libération après l'île I.

### DR-02 — L'écho du canyon

**Lieu :** Réserve draconique / canyon · **Type :** Dragon / Sol · **Ace ou tier :** N.38 à l'entrée (57/80/95 en revanche optionnelle) · **Équipe :** D02.

**Épreuve :** Suivre des empreintes, traverser une oasis et protéger une caravane surprise par le sable sans détruire les nids ; duel contre le maître adaptatif.

**Scénario / résultat :** Certificat de la Terre ; disponible immédiatement comme les trois autres.

### DR-03 — Le serment des glaces

**Lieu :** Réserve draconique / glaciers · **Type :** Dragon / Glace · **Ace ou tier :** N.38 à l'entrée (57/80/95 en revanche optionnelle) · **Équipe :** D03.

**Épreuve :** Retrouver trois balises thermiques et protéger une grotte de migration. Réduire le gel par des mécanismes, pas par un Pokémon imposé ; duel contre le maître.

**Scénario / résultat :** Certificat du Givre ; pas de blocage après île III.

### DR-04 — Le pacte du feu

**Lieu :** Réserve draconique / crêtes · **Type :** Dragon / Feu · **Ace ou tier :** N.38 à l'entrée (57/80/95 en revanche optionnelle) · **Équipe :** D04.

**Épreuve :** Ouvrir trois soupapes pour dévier la vapeur des nids et déplacer une coulée contrôlée vers un bassin rocheux ; duel contre le maître.

**Scénario / résultat :** Certificat des Braises ; accessible après île I, pas après île IV.

## Le Défi divin céleste

Après l'arène Dragon et sa divinité, entrée dans une citadelle à **quatre portes humaines entourant un cinquième sanctuaire**. Affronter **Corven, Sélène, Eryon, Ysara** (noms proposés) avec les équipes C01–C04 au niveau 100, puis **la divinité céleste comme cinquième adversaire**. Pauses autorisant soins/objets/CT, **sans PC ni sortie**. Le cinquième adversaire est un raid légendaire, **pas une cinquième équipe humaine**. Aucun légendaire n'est capturable avant postgame.

## Événements du trio autour des arènes

**Avant GYM-01 :** Vyna va au centre commercial pendant qu'Hyu et Raidon examinent la cour de l'arène. Objectifs individuels courts, puis réunion des humains concernés : duel Hyu/Raidon ; Vyna défie le vainqueur. Combat joueur/joueur si les deux rôles sont humains, sinon joueur/IA ou scène courte PNJ/PNJ ; gagner ou perdre n'arrête pas l'histoire, aucun échange imposé. Le journal affiche « Affronter {NOM:ROLE_RAIDON} à la cour de l'arène » et « Attendre {NOM:ROLE_VYNA} » seulement si ce rôle est un humain absent.

**Après GYM-03 :** un inspecteur RR voit que des insignes locaux ne correspondent pas au registre central. Il commence une enquête ; pas un combat d'admin automatique à chaque badge.

**À l'île IV :** les trois réalisent ensemble que les affrontements légendaires ont émis les résonances récupérées pour Couronne Zéro. Les dialogues ne désignent jamais un héros distinct de la fratrie.

## Jalons et critères de validation

| Territoire | Conditions de fin |
|---|---|
| Île I | **GYM-01 Plante + GYM-02 Feu** → raid → repaire Magma → libération → **EP-I-TR-01 Sharpedo** vers île II ; **les quatre portes Dragon deviennent accessibles dès la libération** |
| Île II | GYM-03 Psy + EP-II-01 Fée + GYM-04 Ténèbres + EP-II-02 Spectre → raid → repaire Aqua → **libération et cinématique** → **EP-II-TR-01 Dracaufeu** + vol libre/rapide vers île III |
| Île III | GYM-05 + EP-III-01 + GYM-06 + EP-III-02 → raid → admin Galaxie → île libérée ; EP-III-OPTION facultative |
| Île IV | EP-IV-01 + EP-IV-02 + GYM-07 + EP-IV-03 → raid → deux branches RR → île libérée |
| Dragon | Dès libération I : **4 gardiens d'entrée indépendants** (tier 38 proposé) → chaque victoire ouvre son biome et ses espèces, sans autre verrou narratif ; activités des 4 épreuves → gym Dragon finale haut niveau (verrou 4 îles ordinaires proposé, à valider) → raid Dragon → céleste |
| Céleste | 4 gardiens humains + 1 dieu → titre, finale Æther |

Chaque ID doit recevoir plus tard : carte et coordonnées, déclencheurs, règles des portes, indices des puzzles, interactions FR/EN, présence coop, sauvegarde de phase, victoire par profil, récompense unique et version de la ville après libération. Ne pas confondre document de conception avec un niveau réellement construit.

**Sources :** [Tactica](https://github.com/DyHyugal/pokemon-tactica/blob/integration/v1/docs/spec/STRATEGIC_TEAMS_AND_ACCESS.md), [Atlas de la première île](https://github.com/DyHyugal/pokemon-archelys/blob/docs/cadrage-valide/docs/design/ATLAS_PROPOSE_2026-10-12.md) et [réponses de cadrage](https://github.com/DyHyugal/pokemon-archelys/blob/docs/cadrage-valide/docs/spec/REPONSES_N01_N51.md).
