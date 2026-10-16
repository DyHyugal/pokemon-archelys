# Pokémon Archélys — Courbe de niveaux, arènes et épreuves V1

> **ARCHIVE DE PROPOSITION (16 OCTOBRE 2026).** Ce document conserve la première courbe proposée (gym 22/36/47/55/68/78/93/100 ; biomes draconiques fixes 40–50/55–65/70–85/90–98). Elle n'avait **pas été approuvée** par le propriétaire. La proposition ultérieure détaillée se trouve dans [EQUIPES_TACTICA_ARCHIPEL_V1.md](EQUIPES_TACTICA_ARCHIPEL_V1.md) et [EPREUVES_ET_ARENES_V1.md](EPREUVES_ET_ARENES_V1.md) ; **ne pas mélanger les paliers des deux variantes dans les données**. La seule décision acquise sur Dragon est que les **quatre biomes** sont ouverts après l'île 1 ; le modèle de niveaux évolutifs versus zones fixes et le seuil de l'arène finale restent des paramètres de conception à valider.

> **SPOILERS DEV — proposition de game design, 16 octobre 2026.** Réfère au scénario [SCENARIO_INTEGRAL_V2_CODEX.md](SCENARIO_INTEGRAL_V2_CODEX.md).
> Les **types des huit arènes, 2+2+2+1+1, plages des quatre îles, niveau 100 céleste, accès draconique intégral après île 1** sont des décisions explicites du propriétaire. **Les caps précis, membres des équipes, attaques, talents, objets, noms et mini-jeux restent des propositions non testées.**
> Référence Tactica : `DyHyugal/pokemon-tactica`, branche `integration/v1`, `docs/spec/SOURCE_OF_TRUTH.md`, `BOSSES_AI.md`, `EVOLUTIONS.md`. Ne pas importer des équipes HnS obsolètes.
> **Légalité à auditer** : les sets ci-dessous sont des *candidats de conception*, pas des exports Showdown validés. Certaines capacités, talents ou formes peuvent être absentes/illégales selon le roster final Archélys ou le learnset du moteur. La validation par Pokémon Showdown et les données d'Archélys est obligatoire avant intégration. **Ne jamais attribuer un talent illégal à l'espèce de base ou avant Méga.** Corriger et documenter tout élément non légal, sans inventer un talent.
 
## 1. Nouvelle répartition et progression

| Arène | Île | Type | Ace proposé | Pokémon | Méga |
|---|---|---|---:|---:|---|
| 1 | Tropicale | Plante | 22 | 3 | Non |
| 2 | Tropicale | Feu | 36 | 4 | Non |
| 3 | Mystique | Psy | 47 | 6 | Non |
| 4 | Mystique | Ténèbres | 55 | 6 | Oui — 1 |
| 5 | Hivernale | Glace | 68 | 6 | Oui — 1 |
| 6 | Hivernale | Acier | 78 | 6 | Oui — 1 |
| 7 | High-tech | Électrik | 93 | 6 | Oui — 1 |
| 8 | Draconique | Dragon | 100 | 6 | Oui — 1 |

**Courbe globale imposée :** île 1 : 1–38 ; île 2 : 40–57 ; île 3 : 60–80 ; île 4 : 80–95 ; île céleste : 100. Les niveaux d'ace ci-dessus sont des jalons *proposés*, pas une décision propriétaire. Dans les repaires, les admins peuvent atteindre le niveau de fin d'île ; **ne pas ajouter +2 de façon cumulative**. La règle Tactica `dernier boss/last gym+2` est à adapter au fait qu'Archélys a des raids entre arènes et repaires.

**Île draconique : accès parallèle.** À l'instant où l'île 1 est libérée, la **totalité des quatre biomes et de leurs épreuves** est disponible : aucune des îles 2/3/4 n'ouvre un biome supplémentaire. Les niveaux sont **fixes par biome** et ne changent pas lorsque le joueur libère d'autres îles ; zones difficiles visibles tôt.

| Biome draconique | Environnement / épreuve | Sauvages et dresseurs | Maître d'épreuve candidat | Déblocage |
|---|---|---|---:|---|
| 1 | Forêt des falaises / épreuve Plante | 40–50 | 50 | Après île 1 |
| 2 | Canyon et oasis / épreuve Sol | 55–65 | 65 | Après île 1 |
| 3 | Vallées glacées / épreuve Glace | 70–85 | 85 | Après île 1 |
| 4 | Crêtes de tempête / épreuve Vol | 90–98 | 98 | Après île 1 |

**Dernière arène Dragon** : accessible après les quatre validations draconiques ; ace 100. Puis raid/sanctuaire draconique niveau 100 et seulement ensuite accès à l'île céleste (4 gardiens humains + 1 divinité, tous niveau 100). Les arènes ordinaires étant au cœur de la campagne, proposer de ne rendre l'accès céleste effectif qu'après avoir aussi terminé les quatre îles occupées, sans refermer les biomes draconiques ; cette condition de convergence demeure **à arbitrer**.

**Caps Tactica à adapter :** un cap qui bloquerait les Pokémon au niveau 38 dès la fin de l'île I interdit en pratique la victoire contre le biome 4 niveau 98, même s'il est accessible. C'est une régulation naturelle possible, mais ne pas appeler cela « accès intégral aux défis » si une règle interdit l'entrée ; ici les entrées sont ouvertes, la difficulté reste réelle. Le joueur pourra découvrir et explorer les biomes dangereux sans remporter immédiatement leurs combats.

## 2. Épreuves de biomes proposées (autres types que les arènes)

| Île | Biome / lieu | Type d'épreuve | Gameplay et but | Niveau final candidat |
|---|---|---|---|---:|
| Tropicale | Côte et port | Eau | Ajuster les vannes du port et libérer une embarcation prise par un barrage RR ; mini-parcours à marée | 14 |
| Tropicale | Caldeira/galeries | Roche | Ouvrir l'ancien sanctuaire sans déstabiliser la caldeira : relais thermiques et passerelles | 37 |
| Mystique | Forêt des lanternes | Fée | Retrouver la vraie route à l'aide de symboles lumineux ; aider les habitants pris au couvre-feu | 51 |
| Mystique | Observatoire | Spectre | Déchiffrer des archives via apparitions et reflets ; confrontation précédant le raid | 56 |
| Hivernale | Plateau/refuges | Vol | Retrouver les balises dans la tempête et secourir des voyageurs | 72 |
| Hivernale | Mine glaciaire | Roche | Reconnecter des systèmes de chauffage, détourner les machines Galaxie sans couper les habitants | 79 |
| High-tech | Usine | Acier | Séquencer des robots/convoyeurs sans être identifié par le registre Plasma | 86 |
| High-tech | Port marémoteur | Eau | Restaurer un quartier et les turbines, mécanisme de débits partagés | 90 |
| High-tech | Tour réseau | Psy | Isoler les flux de données, dévoiler Couronne Zéro ; puzzle logique | 94 |

**Répartition :** 2 arènes + 2 épreuves pour chacune des trois premières îles (4 biomes majeurs), 1 arène + 3 épreuves pour l'île high-tech, et 4 épreuves draconiques + 1 arène. Les types d'épreuves ne sont pas ceux des arènes de leur île (sauf Glace sur une autre île), mais il ne faut pas les imposer comme types exclusifs des combats sauvages.

**Cadence et scénario :** pour chaque île occupée, vaincre les défis → raid de divinité locale → repaire RR → libération ; l'intervention narrative RR est placée à un moment différent sur chaque île. Le raid final proposé est niv. 38 / 57 / 80 / 95, puis niv. 100 en réserve draconique.

## 3. Légalité et philosophie des builds (adaptation Tactica)

- **Composition Tactica :** 3 Pokémon première arène ; 4 deuxième ; 6 dès la troisième. **Une Méga par champion à partir de la quatrième** dans ce modèle. Premier champion utilisant une Méga : arène Ténèbres. Le joueur doit pouvoir obtenir le nécessaire de Méga-Évolution au bon moment selon la décision d'équilibrage Archélys.
- **NORMAL/HARD :** même composition, capacités, niveaux, objets, talents, natures ; HARD = IV 31 / EV compétitifs / IA tactique plus exigeante. Ne jamais tricher sur l'information cachée.
- **Objet tenu unique au sein de chaque équipe** (sauf adaptation expressément décidée). Au plus deux soins de boss lorsque le système en prévoit.
- **Stade légal au niveau du combat** : niveau min d'évolution par niveau, méthodes par objet, Fil Liaison, conditions officielles 9G selon le contrat Tactica. Ne pas forcer une forme évoluée avant son seuil. Une évolution par pierre est possible tôt si ses conditions sont remplies ; l'accès réel à l'objet est à vérifier en contexte.
- **Talents légaux** pour l'espèce de base et la forme ; ceux obtenus par Méga ne s'appliquent qu'après activation. Ne pas inventer de talents cachés, ne pas confondre « Sans Limite » et annulation des contrecoups ou baisses de statistiques du lanceur.
- **Mégas uniques** à l'échelle des champions principaux ; les autres combats importants peuvent réserver leurs propres Méga, sans doublons non justifiés.
- **Cohérence tactique :** setter + bénéficiaires ; rôle annoncé de chaque Pokémon ; une réponse contre la météo supprimée ; lead de secours ; hazards utiles mais pas partout. Les objets Choix ne doivent pas être donnés à un Pokémon dont le plan exige d'utiliser Machination, Cage Éclair ou Provoc sans possibilité de changer de capacité (voir audits).
- **Données spécifiques Tactica** (Dracaufeu Feu/Dragon, Tranchodon Dragon/Acier, Majaspic Plante/Dragon, etc.) **ne s'appliquent à Archélys que si le propriétaire les y retient**. Idem pour les évolutions par Fil Liaison ; la règle doit être confirmée comme règle d'Archélys.
- **Les 394 espèces présélectionnées pour Archélys ne figurent pas encore en liste finale vérifiable dans le dépôt parcouru** ; les suggestions de roster sont conditionnées à leur présence. Remplacer une espèce exclue par une espèce du même rôle et du même thème, puis revérifier la légalité au moteur.

## 4. Huit fiches d'arène : décors, stratégies et équipes candidates

### Arène 1 — Jardins de la canopée (Plante, Tropicale)

**Niveau ace proposé : 22.** Serres suspendues, murs de lianes, vannes d'irrigation et puzzle de croissance : faire circuler l'eau entre trois jardins, ouvrir une allée végétale. Une boucle raccourcie s'ouvre après résolution.

**Plan tactique :** Usure courte : Para-Spore, Vampigraine, régénération et une menace spéciale ; 3 Pokémon, pas de Méga.

| Pokémon | Niv. | Talent proposé | Objet tenu | Capacités candidates (ordre indifférent) |
|---|---:|---|---|---|
| Rosélia | 20 | Médic Nature | Baie Oran | Méga-Sangsue / Para-Spore / Pic Toxik / Bomb-Beurk |
| Floravol | 21 | Chlorophylle | Évoluroc | Vampigraine / Poudre Dodo / Demi-Tour / Acrobatie |
| Herbizarre | 22 | Engrais | Baie Sitrus | Tranch'Herbe / Vampigraine / Poudre Dodo / Bomb-Beurk |

### Arène 2 — Anneau des fumerolles (Feu, Tropicale)

**Niveau ace proposé : 36.** Arène intégrée à des terrasses volcaniques ; portes thermiques alimentées par des conduites. Alterner circulation de vapeur et sécurité pour rejoindre le plateau circulaire.

**Plan tactique :** Soleil de Feunard, relais offensifs physiques/spéciaux ; 4 Pokémon sans Méga, cap proche du raid Heatran 38.

| Pokémon | Niv. | Talent proposé | Objet tenu | Capacités candidates (ordre indifférent) |
|---|---:|---|---|---|
| Feunard | 33 | Sécheresse | Roche Chaude | Lance-Flammes / Feu Follet / Lance-Soleil / Machination |
| Magmar | 34 | Corps Ardent | Baie Sitrus | Lance-Flammes / Exploforce / Tonnerre / Feu Follet |
| Darumacho | 35 | Sans Limite | Mouchoir Choix | Boutefeu / Séisme / Éboulement / Demi-Tour |
| Dracaufeu | 36 | Force Soleil | Orbe Vie | Lance-Flammes / Draco-Choc / Lance-Soleil / Exploforce |

### Arène 3 — Le Miroir des visions (Psy, Mystique)

**Niveau ace proposé : 47.** Salle d'arène au bord d'un lac brumeux ; miroirs alignés sous plusieurs angles, reflets qui ouvrent de vrais passages. La championne devineresse apparaît brièvement dans les reflets, sans révéler l'énigme.

**Plan tactique :** Écrans, contrôle de vitesse et offensives spéciales ; championne dotée de prémonitions sur les trois enfants, pas un élu isolé.

| Pokémon | Niv. | Talent proposé | Objet tenu | Capacités candidates (ordre indifférent) |
|---|---:|---|---|---|
| Xatu | 43 | Synchro | Argile Lumière | Protection / Mur Lumière / Demi-Tour / Psyko |
| Mushana | 44 | Prédiction | Restes | Distorsion / Psyko / Rayon Lune / Ball'Ombre |
| Kaorine | 44 | Lévitation | Casque Brut | Piège de Roc / Psyko / Telluriforce / Tour Rapide |
| Mentali | 45 | Synchro | Lunettes Choix | Psyko / Ball'Ombre / Éclat Magique / Choc Psy |
| Gardevoir | 46 | Calque | Baie Sitrus | Pouvoir Lunaire / Psyko / Tonnerre / Feu Follet |
| Alakazam | 47 | Garde Magik | Orbe Vie | Psyko / Exploforce / Ball'Ombre / Encore |

### Arène 4 — Labyrinthe du crépuscule (Ténèbres, Mystique)

**Niveau ace proposé : 55.** Ruelles et patios à lumière variable ; les ombres de statues masquent des portes, les interrupteurs déplacent les sources. Jeu de lecture du décor, pas téléporteurs sans indice.

**Plan tactique :** Provoc, pièges, pivots, pression physique et illusion ; première Méga autorisée sur l'arène 4 selon modèle Tactica.

| Pokémon | Niv. | Talent proposé | Objet tenu | Capacités candidates (ordre indifférent) |
|---|---:|---|---|---|
| Crocorible | 52 | Intimidation | Casque Brut | Séisme / Sabotage / Piège de Roc / Provoc |
| Zoroark | 52 | Illusion | Ceinture Pro | Vibrobscur / Lance-Flammes / Exploforce / Machination |
| Corboss | 53 | Impudence | Orbe Vie | Rapace / Coup Bas / Atterrissage / Canicule |
| Vaututrice | 54 | Envelocape | Restes | Tricherie / Anti-Brume / Atterrissage / Toxik |
| Scalproie | 54 | Acharné | Baie Sitrus | Tête de Fer / Coup Bas / Danse Lames / Sabotage |
| Absol → Méga-Absol | 55 | Chanceux → Miroir Magik | Absolite | Sabotage / Câlinerie / Danse Lames / Coup Bas |

### Arène 5 — Les pistes boréales (Glace, Hivernale)

**Niveau ace proposé : 68.** Arène construite en gradins autour de canaux gelés ; des vannes forment/dégèlent des ponts temporaires. Grands repères colorés, aucun puzzle aléatoire pénible.

**Plan tactique :** Neige et Voile Aurore, couverture physique et spéciale, priorité Glace ; coordination météo selon Tactica.

| Pokémon | Niv. | Talent proposé | Objet tenu | Capacités candidates (ordre indifférent) |
|---|---:|---|---|---|
| Feunard d'Alola | 64 | Alerte Neige | Argile Lumière | Blizzard / Voile Aurore / Pouvoir Lunaire / Encore |
| Momartik | 65 | Corps Maudit | Ceinture Force | Laser Glace / Ball'Ombre / Picots / Provoc |
| Blizzaroi | 66 | Alerte Neige | Restes | Blizzard / Giga-Sangsue / Telluriforce / Éclats Glace |
| Mammochon | 67 | Isograisse | Bandeau Choix | Séisme / Chute Glace / Éclats Glace / Sabotage |
| Glaivodo | 67 | Thermodynamique | Baie Sitrus | Danse Draco / Charge Glaive / Séisme / Éclats Glace |
| Oniglali → Méga-Oniglali | 68 | Attention → Peau Gelée | Oniglalite | Damoclès / Séisme / Éclats Glace / Explosion |

### Arène 6 — La forge des glaces (Acier, Hivernale)

**Niveau ace proposé : 78.** Vieille forge réhabilitée aux sources chaudes ; rails d'atelier et plaques métalliques ; régler pression et orientation d'aimants pour ouvrir le fourneau de compétition.

**Plan tactique :** Pose de rocs, couverture des faiblesses et défense agressive. Méga-Galeking ace, sans réutiliser la même Méga sur un autre champion.

| Pokémon | Niv. | Talent proposé | Objet tenu | Capacités candidates (ordre indifférent) |
|---|---:|---|---|---|
| Noacier | 73 | Épine de Fer | Casque Brut | Piège de Roc / Vampigraine / Gyroballe / Sabotage |
| Corvaillus | 74 | Pression | Restes | Rapace / Atterrissage / Demi-Tour / Gonflette |
| Magnézone | 75 | Magnépiège | Aimant | Tonnerre / Luminocanon / Change Éclair / Cage Éclair |
| Exagide | 75 | Déclic Tactique | Baie Sitrus | Bouclier Royal / Lame Sainte / Tête de Fer / Ombre Portée |
| Lucario | 76 | Attention | Orbe Vie | Close Combat / Poing Météore / Vitesse Extrême / Danse Lames |
| Galeking → Méga-Galeking | 78 | Fermeté → Filtre | Galekingite | Tacle Lourd / Séisme / Repos / Malédiction |

### Arène 7 — La centrale synaptique (Électrik, High-tech)

**Niveau ace proposé : 93.** Hub énergétique, circuits visuels au sol et aiguillages de tram ; activer trois sous-stations dans n'importe quel ordre sans bloquer les autres joueurs ; duel dans une salle de distribution à vitres panoramiques.

**Plan tactique :** Champ Électrifié via Wattapik, bénéficiaires rapides et offensives hybrides ; Élekable exploite ses changements Tactica seulement s'ils sont repris officiellement dans Archélys.

| Pokémon | Niv. | Talent proposé | Objet tenu | Capacités candidates (ordre indifférent) |
|---|---:|---|---|---|
| Wattapik | 88 | Créa-Élec | Restes | Picots / Tonnerre / Soin / Toxic |
| Motisma-Lavage | 89 | Lévitation | Baie Sitrus | Hydrocanon / Change Éclair / Feu Follet / Balance |
| Raichu d'Alola | 90 | Surf Caudal | Orbe Vie | Tonnerre / Psyko / Surf / Machination |
| Élekable | 90 | Sans Limite [si validé dans Archélys] | Ceinture Pro | Poing Éclair / Poing Glace / Close Combat / Séisme |
| Salarsen | 91 | Punk Rock | Spray Gorge | Overdrive / Bomb-Beurk / Provoc / Change Éclair |
| Pharamp → Méga-Pharamp | 93 | Statik → Brise Moule | Pharampite | Tonnerre / Draco-Choc / Exploforce / Change Éclair |

### Arène 8 — Le jugement du sanctuaire (Dragon, Draconique)

**Niveau ace proposé : 100.** Arène centrale taillée dans une haute crête, quatre voies d'accès symbolisant les biomes explorés. Les quatre sceaux d'épreuve forment la porte finale ; combat sur un plateau suspendu, sans décor qui gêne la lisibilité du jeu.

**Plan tactique :** Six dragons de rôles différents : vitesse, tank, attaque physique, setup, priorité, Méga. Aucune capture de boss légendaire avant postgame.

| Pokémon | Niv. | Talent proposé | Objet tenu | Capacités candidates (ordre indifférent) |
|---|---:|---|---|---|
| Majaspic [Plante/Dragon si validé] | 96 | Contestation | Restes | Tempête Verte / Draco-Choc / Regard Médusant / Clonage |
| Hyporoi | 97 | Sniper | Lunettes Sages | Draco-Météore / Hydrocanon / Laser Glace / Hâte |
| Tranchodon [Dragon/Acier si validé] | 98 | Brise Moule | Baie Prine | Danse Draco / Colère / Tête de Fer / Séisme |
| Lanssorien | 98 | Corps Sain | Orbe Vie | Draco-Flèches / Demi-Tour / Hantise / Lance-Flammes |
| Dracolosse | 99 | Multiécaille | Grosses Bottes | Danse Draco / Vitesse Extrême / Séisme / Poing de Feu |
| Carchacrok → Méga-Carchacrok | 100 | Voile Sable → Force Sable | Carchacrokite | Danse Lames / Séisme / Draco-Griffe / Lame de Roc |

## 5. Contrôles de validation pour Codex

1. Inspecter le Pokédex réellement retenu, les formes delta et leurs nouvelles tables de types/learnsets, **avant** de créer les fichiers de boss. Si une espèce n'est pas retenue, remplacer sans changer l'identité tactique de l'arène.
2. Passer **chaque** set dans le validateur Showdown qui correspond à la base 9G et aux extensions Archélys. Les tables ci-dessus n'ont pas été validées automatiquement et contiennent délibérément des idées à auditer (ex. compatibilité capacité/génération ; objet Choix avec capacité de setup ; nom officiel exact des attaques).
3. Vérifier explicitement que Rosélia, Floravol, Herbizarre, Darumacho, Gardevoir, Vaututrice, Scalproie, Glaivodo, etc. sont légaux aux niveaux indiqués, ainsi que toutes les espèces évoluant par objet ou Fil Liaison. Les formes Delta modifiées ont leur propre contrat de légalité.
4. Auditer le talent en **forme d'entrée** et l'aptitude obtenue **après** Méga (ex. Absol chanceux → Miroir Magik) ; ne jamais donner le talent de Méga au Pokémon avant la transformation.
5. Auditer les objets, deux sets incompatibles « Choix + setup » et les noms localisés/identifiants Showdown. Chaque boss doit avoir 4 attaques réellement apprises et utilisables à son niveau (TM/œuf, si la règle Archélys le permet).
6. Entraîner les IA contre plusieurs archétypes : stall, hyper offense, pluie/soleil, priorité, immunités, ténacité ; éviter tous les leads obligatoires et les surprises injustes.
7. Tester solo Vyna, Raidon, Hyu et préparation 2/3 humains pour l'accès aux arènes : chaque humain peut obtenir son badge ; la victoire d'un autre joueur ne remplace pas son combat individuel si le produit l'exige.
8. Vérifier les déblocages : **tous les biomes draconiques ouverts après île 1** et aucun lien de verrouillage à île 2/3/4 ; quatrième épreuve battable seulement par niveau/stratégie, pas par porte verrouillée. La dernière arène requiert quatre épreuves complétées.
9. Les niveaux restent cohérents avec les plages owner, y compris en sortie de raid et au repaire ; un cap de combat ne baisse jamais et ne s'incrémente pas entre deux admins du même événement.
10. Documenter les choix à faire valider : équipes définitives, Méga de chaque champion, liste réelle des espèces, type de chaque épreuve, noms, caps exacts, restriction éventuelle d'entrée à la dernière arène draconique.
