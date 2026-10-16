# Pokémon Archélys — Équipes compétitives Tactica, V1 de conception

> **SPOILERS DEV — PROPOSITIONS À VALIDER — 16 octobre 2026.** Source : décisions du propriétaire dans les conversations des 15–16 octobre 2026, et référentiel [Pokémon Tactica / integration/v1](https://github.com/DyHyugal/pokemon-tactica/tree/integration/v1/docs/spec) consulté le 16 octobre 2026. **Aucune équipe n'a été testée dans Pokémon Showdown, Godot ou le runtime Archélys ; elles ne sont pas garanties importables en l'état.** Vérifier espèces retenues du Pokédex Archélys, existence des Méga, learnsets 9G/adaptations Tactica et talents dans le moteur avant validation définitive.

Voir les [épreuves et arènes — architecture, énigmes et synchronisation](EPREUVES_ET_ARENES_V1.md) et le [scénario narratif V2](SCENARIO_INTEGRAL_V2_CODEX.md).

## Source de vérité et règles de compilation

- **Niveaux imposés par le propriétaire :** île 1 N.1–38 ; île 2 N.40–57 ; île 3 N.60–80 ; île 4 N.80–95 ; céleste N.100. Arène Dragon finale N.98 proposé, entre île IV et île céleste. Les quatre biomes draconiques deviennent **tous accessibles** après la fin de l'île 1 ; seuls les combats des maîtres draconiques s'adaptent au palier courant (N.38 / 57 / 80 / 95), sans réhausser le niveau des Pokémon sauvages d'une zone déjà accessible.
- **8 arènes** : Plante N.18, Feu N.36, Psy N.45, Ténèbres N.55, Glace N.64, Acier N.78, Électrik N.93, Dragon N.98. La huitième n'ouvre qu'une fois les **quatre îles ordinaires libérées et les quatre épreuves draconiques terminées**, même si tous les biomes ont été ouverts dès la première libération. Ce verrou de dernière arène est une **proposition de conciliation** avec « dernier défi » ; à valider explicitement.
- **Tactica :** 1er champion 3 Pokémon, 2e 4, à partir du 3e 6. Jusqu'au 3e badge, pas de Méga ; à partir du 4e champion inclus : **une Méga propre au champion**. Méga-Gemmes non dupliquées entre chefs majeurs ; le Pokémon entre avec un talent pré-Méga légal. Les chefs des épreuves utilisent des effectifs différents selon leur niveau de menace. Les équipes sont les mêmes en NORMAL et HARD : seul HARD applique les IV 31, EV stratégiques et IA adaptée sans triche.
- **Objets uniques** par équipe, un exemplaire de chaque objet tenu. **1 objet maximum au premier gym**, 3 maximum au deuxième par adaptation prudente du profil « early Tactica » (Tactica impose exactement 1/2/3 objets aux trois premiers champions, mais cette proposition Archelys comporte 1ère et 2e arène seulement avant N.38 ; **par défaut imposer maximum 2 objets à A02 si on applique strictement la progression des badges**. A02 possède actuellement 3 objets : **correction requise avant l'implémentation**). Les phases EARLY/MID ne doivent pas employer un set final disproportionné. Pas de double objet identique sur une équipe, ni de talent inaccessible dans la forme de base.
- **EV HARD en raccourci :** P=252 Atq / 252 Vit / 4 PV, S=252 Atq. Spé / 252 Vit / 4 PV, D=252 PV / 252 Déf / 4 Déf. Spé, M=252 PV / 252 Déf. Spé / 4 Déf, V=252 PV / 252 Vit / 4 Déf. Spé. Pour certains poseurs de murs, V peut nécessiter un profil davantage PV/Déf : le calcul final doit être optimisé par essais réels. Natures proposées à valider (p.ex. « Brave » sur Distorsion implique IV Vitesse 0, exception motivée aux IV31 standard et à spécifier explicitement si on la conserve).
- **Évolutions :** les stades doivent être légaux **au niveau réel**. Échange simple = Fil Liaison ; échange + objet tenu = objet officiel tenu et Fil Liaison ; les méthodes faisables en 9G restent officielles sans niveaux artificiels. Les boss peuvent détenir une forme légalement obtenue par objet/Fil Liaison sans forcer le Pokémon sauvage à l'avoir déjà. Pas de famille starter en **rencontre sauvage** avant le 2e badge (cette restriction n'interdit pas un starter dans l'équipe d'un champion).
- **Types custom Tactica confirmés :** Dracaufeu et sa famille Feu/Dragon ; Tranchodon Dragon/Acier ; Élekable Électrik/Combat avec Sans Limite ; Jungko et Majaspic Plante/Dragon. Leur inclusion dans Archélys est conditionnée à l'import effectif de cette balance ; ne pas leur attribuer les nouveaux types dans Godot avant intégration vérifiée.
- **Disponibilité :** les Pokémon cités sont des **candidats**, car le roster final ~394 espèces et les Fakemons/deltas de l'archipel ne sont pas archivés ici sous une liste complète approuvée. Codex doit auditer tous les Pokémon contre les données effectivement retenues avant import. Certains mouvements, capacités/objets et cas d'évolution spéciaux doivent être substitués si la combinaison n'est pas réellement disponible.

## Courbe et conventions

| Île | Arènes et ace | Épreuves ordinaires et ace | Raid local | Repaire RR |
|---|---|---|---|---|
| I · tropicale | Plante 18 ; Feu 36 | Insecte 26 ; Roche/Sol 36 | 38 | Magma 38 |
| II · mystique | Psy 45 ; Ténèbres 55 | Fée 50 ; Spectre 55 | 57 | Aqua 57 |
| III · hivernale | Glace 64 ; Acier 78 | Vol 69 ; Eau 78 ; Roche 78 | 80 | Galaxie 80 |
| IV · high-tech | Électrik 93 | Acier 84 ; Eau 89 ; Psy 93 | 95 | Plasma/Flare 95 |
| Réserve Dragon (parallèle) | Dragon 98, seulement au final | Quatre épreuves, tier 38 / 57 / 80 / 95 | 98 proposé | Aucune occupation |
| Céleste | Aucune arène | Quatre gardiens avec six Pokémon N.100 | Dieu 5e combat N.100 | Aucun |

**Niveaux de détail :** cette V1 propose les quatre attaques, le talent, la nature, l'objet, la composition, les intentions stratégiques et le profil EV de chaque équipe. Une capacité de couverture listée n'est **pas une certification de légalité**. La traduction d'une attaque peut diverger de Showdown (ex. « Ébullition » = Scald) ; créer des constantes stables à la génération et auditer le learnset officiel adapté Tactica.

## Équipes Pokémon — arènes, épreuves et administrateurs

### A01 — Champion Plante — île 1, littoral/jardins

**Arène 1 · Type/thème : Plante · Palier EARLY · ace N.18.** Vampigraine et contrôle léger ; 3 Pokémon, 1 objet équipé.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Mystherbe | 16 | Chlorophylle | — | Modeste | S | Vol-Vie · Acide · Para-Spore · Croissance |
| 2 | Cabriolaine | 17 | Herbivore | — | Rigide | P | Fouet Lianes · Charge · Rugissement · Tranch'Herbe |
| 3 **(ace)** | Rosélia | 18 | Médic Nature | Baie Oran | Calme | M | Méga-Sangsue · Vampigraine · Para-Spore · Dard-Venin |

### T01 — Maîtresse de la jungle — épreuve 1

**Épreuve · Type/thème : Insecte · Palier EARLY · ace N.26.** Réseau de soie, ralentissements, nature envahissante.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Papilusion | 23 | Œil Composé | Baie Oran | Timide | S | Poudre Dodo · Vent Argenté · Choc Mental · Para-Spore |
| 2 | Parasect | 25 | Pose Spore | — | Rigide | P | Tranche · Vol-Vie · Para-Spore · Grincement |
| 3 **(ace)** | Insécateur | 26 | Technicien | Baie Sitrus | Jovial | P | Aéropique · Plaie-Croix · Vive-Attaque · Danse-Lames |

### A02 — Championne Feu — île 1, sources géothermiques

**Arène 2 · Type/thème : Feu · Palier MID · ace N.36.** Soleil offensif, pivot et sweeper physique ; 4 Pokémon, aucune Méga.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Feunard | 33 | Sécheresse | Roche Chaude | Timide | S | Lance-Flammes · Feu Follet · Éco-Sphère · Choc Psy |
| 2 | Magmar | 34 | Corps Ardent | Baie Sitrus | Modeste | S | Lance-Flammes · Choc Psy · Onde Folie · Tonnerre |
| 3 | Reptincel | 35 | Brasier | — | Jovial | P | Crocs Feu · Draco-Griffe · Griffe Ombre · Danse-Lames |
| 4 **(ace)** | Arcanin | 36 | Intimidation | Ceinture Pro | Rigide | P | Boutefeu · Vitesse Extrême · Câlinerie · Mâchouille |

### T02 — Maître du volcan — épreuve 2

**Épreuve · Type/thème : Roche / Sol · Palier MID · ace N.36.** Éboulements et pièges de terrain ; accès sanctuaire ensuite.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Onix | 34 | Fermeté | Évoluroc | Malin | D | Piège de Roc · Tombe-Roche · Piétisol · Grincement |
| 2 | Rhinocorne | 35 | Tête de Roc | Baie Sitrus | Rigide | P | Éboulement · Piétisol · Mégacorne · Protection |
| 3 **(ace)** | Grolem | 36 | Fermeté | Ceinture Pro | Rigide | P | Séisme · Éboulement · Poing Feu · Explosion |

### RR01 — Darek — repaire Magma île 1

**Admin RR · Type/thème : Géothermie / Roche-Feu · Palier MID · ace N.38.** Niveau identique au raid d'île ; pression et blocs de machines.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Chartor | 36 | Sécheresse | Roche Chaude | Assuré | D | Piège de Roc · Lance-Flammes · Tour Rapide · Feu Follet |
| 2 | Camérupt | 37 | Solide Roc | Baie Sitrus | Modeste | S | Telluriforce · Lance-Flammes · Éboulement · Abri |
| 3 | Maganon | 37 | Corps Ardent | Ceinture Pro | Modeste | S | Lance-Flammes · Tonnerre · Exploforce · Psyko |
| 4 **(ace)** | Rhinastoc | 38 | Solide Roc | — | Rigide | P | Séisme · Lame de Roc · Mégacorne · Poing Feu |

### A03 — Championne visionnaire Psy — île 2, lac

**Arène 3 · Type/thème : Psy · Palier MID · ace N.45.** Contrôle vitesse + anticipation, 6 Pokémon ; pas encore de Méga.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Mistigrix mâle | 42 | Farceur | Lumargile | Timide | V | Mur Lumière · Protection · Choc Psy · Cage Éclair |
| 2 | Xatu | 43 | Miroir Magik | Grosses Bottes | Timide | S | Psyko · Air Slash · Atterrissage · Demi-Tour |
| 3 | Flagadoss | 43 | Régé-Force | Restes | Assuré | D | Ébullition · Psyko · Paresse · Cage Éclair |
| 4 | Mentali | 44 | Miroir Magik | Orbe Vie | Timide | S | Psyko · Éclat Magique · Ball'Ombre · Plénitude |
| 5 | Gardevoir | 44 | Calque | Ceinture Pro | Modeste | S | Psyko · Pouvoir Lunaire · Tonnerre · Feu Follet |
| 6 **(ace)** | Alakazam | 45 | Garde Magik | Ceinture Force | Timide | S | Psyko · Exploforce · Ball'Ombre · Encore |

### T03 — Maître des lanternes — forêt mystique

**Épreuve · Type/thème : Fée · Palier MID · ace N.50.** Réparer les lanternes avant de disperser un faux brouillard.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Mysdibule | 47 | Intimidation | Baie Sitrus | Rigide | P | Câlinerie · Tête de Fer · Coup Bas · Provoc |
| 2 | Granbull | 49 | Intimidation | Ceinture Pro | Rigide | P | Câlinerie · Séisme · Poing Feu · Close Combat |
| 3 **(ace)** | Florges | 50 | Flora-Voile | Restes | Calme | M | Pouvoir Lunaire · Vœu · Abri · Aromathérapie |

### A04 — Champion Ténèbres — île 2, ruines

**Arène 4 · Type/thème : Ténèbres · Palier FINAL · ace N.55.** Nuisance + illusion + Méga-Démolosse ; premier champion avec Méga.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Grahyèna | 52 | Intimidation | Baie Sitrus | Rigide | P | Mâchouille · Crocs Éclair · Coup Bas · Provoc |
| 2 | Ténéfix | 53 | Farceur | Restes | Malin | D | Feu Follet · Sabotage · Soin · Provoc |
| 3 | Corboss | 53 | Impudence | Bec Pointu | Rigide | P | Rapace · Coup Bas · Surpuissance · Atterrissage |
| 4 | Zoroark | 54 | Illusion | Orbe Vie | Timide | S | Vibrobscur · Lance-Flammes · Exploforce · Machination |
| 5 | Vaututrice | 54 | Envelocape | Grosses Bottes | Malin | D | Tricherie · Atterrissage · Provoc · Anti-Brume |
| 6 **(ace)** | Démolosse | 55 | Torche > Force Soleil (Méga) | Démolossite | Timide | S | Vibrobscur · Déflagration · Bomb-Beurk · Machination |

### T04 — Maîtresse des archives — observatoire mystique

**Épreuve · Type/thème : Spectre · Palier FINAL · ace N.55.** Reconstituer une constellation avec des miroirs, révéler la fausse apparition.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Branette | 53 | Insomnia | Ceinture Force | Rigide | P | Ombre Portée · Sabotage · Feu Follet · Provoc |
| 2 | Noctunoir | 54 | Pression | Restes | Prudent | M | Poing Ombre · Poing Glace · Feu Follet · Balance |
| 3 | Ectoplasma | 54 | Corps Maudit | Orbe Vie | Timide | S | Ball'Ombre · Bomb-Beurk · Tonnerre · Prélèvement Destin |
| 4 **(ace)** | Lugulabre | 55 | Torche | Mouchoir Choix | Timide | S | Ball'Ombre · Lance-Flammes · Éco-Sphère · Psyko |

### RR02 — Corail — repaire Aqua île 2

**Admin RR · Type/thème : Pluie / Eau · Palier FINAL · ace N.57.** Pose pluie, exploitation des courants et switches offensifs.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Bekipan | 55 | Crachin | Roche Humide | Assuré | D | Vent Violent · Ébullition · Atterrissage · Demi-Tour |
| 2 | Ludicolo | 56 | Glissade | Orbe Vie | Modeste | S | Hydrocanon · Giga-Sangsue · Laser Glace · Exploforce |
| 3 | Staross | 56 | Médic Nature | Ceinture Pro | Timide | S | Hydrocanon · Psyko · Tonnerre · Laser Glace |
| 4 | Léviator | 56 | Intimidation | Baie Prine | Jovial | P | Cascade · Danse Draco · Séisme · Crocs Givre |
| 5 **(ace)** | Hyporoi | 57 | Glissade | Lunettes Choix | Modeste | S | Hydrocanon · Draco-Météore · Laser Glace · Surf |

### A05 — Champion Glace — île 3, fjord

**Arène 5 · Type/thème : Glace · Palier FINAL · ace N.64.** Neige + Voile Aurore + rush, Méga-Blizzaroi.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Feunard d'Alola | 61 | Alerte Neige | Roche Glace | Timide | V | Voile Aurore · Blizzard · Lyophilisation · Encore |
| 2 | Sablaireau d'Alola | 62 | Chasse-Neige | Orbe Vie | Jovial | P | Danse-Lames · Chute Glace · Tête de Fer · Séisme |
| 3 | Momartik | 62 | Corps Maudit | Ceinture Force | Timide | S | Picots · Blizzard · Ball'Ombre · Prélèvement Destin |
| 4 | Cochignon | 63 | Isograisse | Évoluroc | Rigide | P | Séisme · Éclats Glace · Éboulement · Malédiction |
| 5 | Lokhlass | 63 | Absorb Eau | Restes | Calme | M | Lyophilisation · Surf · Tonnerre · Repos |
| 6 **(ace)** | Blizzaroi | 64 | Alerte Neige (Méga) | Blizzarite | Rigide | P | Martobois · Éclats Glace · Séisme · Abri |

### T05 — Maître des hauteurs — épreuve hivernale 1

**Épreuve · Type/thème : Vol · Palier FINAL · ace N.69.** Retrouver trois balises dans une tempête et protéger un refuge.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Lakmécygne | 67 | Regard Vif | Lunettes Sages | Timide | S | Surf · Vent Violent · Laser Glace · Atterrissage |
| 2 | Scorvol | 68 | Soin Poison | Orbe Toxique | Jovial | P | Séisme · Acrobatie · Provoc · Atterrissage |
| 3 **(ace)** | Airmure | 69 | Fermeté | Casque Brut | Malin | D | Piège de Roc · Rapace · Atterrissage · Cyclone |

### A06 — Champion Acier — île 3, village des sources

**Arène 6 · Type/thème : Acier · Palier FINAL · ace N.78.** Hazards, résistances, contre-attaques et Méga-Galeking.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Airmure | 75 | Fermeté | Casque Brut | Malin | D | Piège de Roc · Rapace · Atterrissage · Cyclone |
| 2 | Noacier | 76 | Épine de Fer | Restes | Relax | D | Vampigraine · Gyroballe · Piège de Roc · Mégafouet |
| 3 | Magnézone | 76 | Magnépiège | Lunettes Choix | Modeste | S | Tonnerre · Luminocanon · Change Éclair · Exploforce |
| 4 | Lucario | 77 | Impassible | Orbe Vie | Jovial | P | Close Combat · Pisto-Poing · Mâchouille · Danse-Lames |
| 5 | Cizayox | 77 | Technicien | Bandeau Choix | Rigide | P | Pisto-Poing · Demi-Tour · Surpuissance · Sabotage |
| 6 **(ace)** | Galeking | 78 | Fermeté > Filtre (Méga) | Galekingite | Prudent | M | Tacle Lourd · Malédiction · Repos · Blabla Dodo |

### T06 — Maîtresse des sources — épreuve hivernale 2

**Épreuve · Type/thème : Eau · Palier FINAL · ace N.78.** Dériver la vapeur sans priver les maisons de chauffage.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Staross | 76 | Médic Nature | Ceinture Pro | Timide | S | Surf · Psyko · Tonnerre · Laser Glace |
| 2 | Tritosor | 77 | Lavabo | Restes | Calme | M | Ébullition · Telluriforce · Soin · Toxic |
| 3 | Azumarill | 77 | Coloforce | Baie Sitrus | Rigide | P | Aqua-Jet · Câlinerie · Sabotage · Surpuissance |
| 4 **(ace)** | Milobellus | 78 | Écaille Spéciale | Casque Brut | Assuré | D | Ébullition · Soin · Laser Glace · Draco-Queue |

### T07 — Maîtresse du glacier — épreuve hivernale 3

**Épreuve · Type/thème : Roche · Palier FINAL · ace N.78.** Cristaux, conduction de chaleur et itinéraire sans rupture du glacier.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Gigalithe | 76 | Sable Volant | Roche Lisse | Prudent | M | Lame de Roc · Piège de Roc · Séisme · Explosion |
| 2 | Crustabri | 77 | Multi-Coups | Herbe Blanche | Jovial | P | Exuviation · Stalactite · Boule Roc · Aqua-Jet |
| 3 | Ptéra | 77 | Pression | Orbe Vie | Jovial | P | Lame de Roc · Séisme · Provoc · Atterrissage |
| 4 **(ace)** | Tyranocif | 78 | Sable Volant | Restes | Malin | D | Lame de Roc · Mâchouille · Séisme · Abri |

### RR03 — Administrateur Galaxie — repaire île 3

**Admin RR · Type/thème : Distorsion / dimensions · Palier FINAL · ace N.80.** Distorsion et slow breakers ; jeu de tours cohérent.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Porygon2 | 78 | Télécharge | Évoluroc | Relax | D | Distorsion · Tri Attaque · Laser Glace · Soin |
| 2 | Archéodong | 78 | Lévitation | Restes | Relax | D | Distorsion · Gyroballe · Séisme · Protection |
| 3 | Symbios | 79 | Garde Magik | Orbe Vie | Discret | S | Psyko · Exploforce · Ball'Ombre · Soin |
| 4 | Bétochef | 79 | Cran | Orbe Flamme | Brave | P | Vampipoing · Façade · Sabotage · Mach Punch |
| 5 | Corvaillus | 79 | Armure Miroir | Casque Brut | Malin | D | Rapace · Atterrissage · Anti-Brume · Demi-Tour |
| 6 **(ace)** | Dimoclès | 80 | Annule Garde | Baie Sitrus | Brave | P | Lame Sainte · Tête de Fer · Ombre Portée · Danse-Lames |

### T08 — Maître des usines — épreuve high-tech 1

**Épreuve · Type/thème : Acier · Palier FINAL · ace N.84.** Réparer le flux des robots avec interrupteurs, circuit accessible sans séquence aveugle.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Foretress | 82 | Fermeté | Casque Brut | Malin | D | Picots · Tour Rapide · Gyroballe · Change Éclair |
| 2 | Métalosse | 83 | Corps Sain | Veste de Combat | Rigide | P | Poing Météore · Séisme · Poing Glace · Pisto-Poing |
| 3 **(ace)** | Cliticlic | 84 | Corps Sain | Baie Sitrus | Rigide | P | Change-Vitesse · Lancécrou · Éclair Fou · Clonage |

### T09 — Maître du port énergétique — épreuve high-tech 2

**Épreuve · Type/thème : Eau · Palier FINAL · ace N.89.** Dévier les courants et rétablir un quartier, sans vider la centrale.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Tarenbulle | 86 | Aquabulle | Restes | Prudent | M | Vampirisme · Liquidation · Toile Gluante · Voile Miroir |
| 2 | Denticrisse | 87 | Corps Coloré | Ceinture Pro | Jovial | P | Psykoud'Boul · Liquidation · Crocs Givre · Mâchouille |
| 3 | Léviator | 88 | Intimidation | Baie Prine | Jovial | P | Cascade · Danse Draco · Crocs Givre · Séisme |
| 4 **(ace)** | Oratoria | 89 | Torrent | Lunettes Choix | Modeste | S | Hydrocanon · Pouvoir Lunaire · Laser Glace · Psyko |

### A07 — Champion Électrik — île 4, tour centrale

**Arène 7 · Type/thème : Électrik · Palier FINAL · ace N.93.** Champ Électrifié actif, vitesse, pivot ; dernier badge avant la réserve Dragon.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Électrode | 90 | Boom Final | Ceinture Force | Timide | V | Champ Électrifié · Tonnerre · Cage Éclair · Provoc |
| 2 | Motisma-Lavage | 90 | Lévitation | Restes | Assuré | D | Hydrocanon · Change Éclair · Feu Follet · Balance |
| 3 | Raichu d'Alola | 91 | Surf Caudal | Graine Électrik | Timide | S | Tonnerre · Psyko · Nœud Herbe · Machination |
| 4 | Togedemaru | 92 | Épine de Fer | Casque Brut | Jovial | P | Éclair Fou · Tête de Fer · Demi-Tour · Encore |
| 5 | Élekable | 92 | Sans Limite | Orbe Vie | Jovial | P | Poing Éclair · Poing Glace · Close Combat · Séisme |
| 6 **(ace)** | Élecsprint | 93 | Paratonnerre > Intimidation (Méga) | Élecsprintite | Timide | S | Tonnerre · Change Éclair · Surchauffe · Lance-Flammes |

### T10 — Maîtresse du réseau — épreuve high-tech 3

**Épreuve · Type/thème : Psy · Palier FINAL · ace N.93.** Reconstruire les journaux d'accès du registre RR, ouvrir la tour de surveillance.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Porygon2 | 91 | Analyste | Évoluroc | Calme | M | Distorsion · Tri Attaque · Tonnerre · Soin |
| 2 | Neitram | 92 | Analyste | Orbe Vie | Discret | S | Psyko · Tonnerre · Ball'Ombre · Exploforce |
| 3 | Gallame | 92 | Impassible | Ceinture Pro | Rigide | P | Psykoud'Boul · Close Combat · Lame-Feuille · Ombre Portée |
| 4 **(ace)** | Métalosse | 93 | Corps Sain | Veste de Combat | Rigide | P | Poing Météore · Séisme · Poing Glace · Pisto-Poing |

### RR04P — Admin Plasma — repaire high-tech

**Admin RR · Type/thème : Contrôle et perturbation · Palier FINAL · ace N.95.** Écran, statut, menace de switch et anti-setup.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Angoliath | 93 | Farceur | Lumargile | Prudent | V | Protection · Mur Lumière · Provoc · Tricherie |
| 2 | Scalproie | 93 | Acharné | Orbe Vie | Rigide | P | Danse-Lames · Tête de Fer · Sabotage · Coup Bas |
| 3 | Smogogo de Galar | 94 | Gaz Inhibiteur | Boue Noire | Assuré | D | Bomb-Beurk · Feu Follet · Balance · Provoc |
| 4 | Corvaillus | 94 | Armure Miroir | Casque Brut | Malin | D | Rapace · Atterrissage · Anti-Brume · Demi-Tour |
| 5 | Zoroark | 94 | Illusion | Ceinture Force | Timide | S | Vibrobscur · Exploforce · Lance-Flammes · Machination |
| 6 **(ace)** | Trioxhydre | 95 | Lévitation | Lunettes Choix | Timide | S | Draco-Météore · Vibrobscur · Lance-Flammes · Demi-Tour |

### RR04F — Admin Flare — repaire high-tech

**Admin RR · Type/thème : Offensive élitiste / soleil · Palier FINAL · ace N.95.** Un vrai combat distinct de Plasma, même palier de cap.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Feunard | 93 | Sécheresse | Roche Chaude | Timide | V | Lance-Flammes · Feu Follet · Éco-Sphère · Choc Psy |
| 2 | Flambusard | 93 | Ailes Bourrasque | Grosses Bottes | Jovial | P | Boutefeu · Rapace · Atterrissage · Demi-Tour |
| 3 | Floramantis | 94 | Contestation | Veste de Combat | Prudent | M | Tempête Verte · Sabotage · Surpuissance · Lame-Feuille |
| 4 | Démolosse | 94 | Torche | Baie Sitrus | Timide | S | Vibrobscur · Déflagration · Bomb-Beurk · Machination |
| 5 | Arcanin | 94 | Intimidation | Bandeau Choix | Rigide | P | Boutefeu · Vitesse Extrême · Éclair Fou · Câlinerie |
| 6 **(ace)** | Pyrax | 95 | Corps Ardent | Orbe Vie | Timide | S | Papillodanse · Déflagration · Bourdon · Giga-Sangsue |

### D01 — Maître draconique 1 — falaises

**Épreuve draconique adaptative · Type/thème : Dragon / Vol · Palier ADAPT · ace N.38.** Récupérer les marques de nids et traverser les ponts de vent.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Sonistrelle | 36 | Fouille | Baie Oran | Timide | S | Draco-Souffle · Lame d'Air · Vampirisme · Atterrissage |
| 2 | Drackhaus | 37 | Tête de Roc | Évoluroc | Malin | D | Draco-Griffe · Éboulement · Abri · Bâillement |
| 3 **(ace)** | Altaria | 38 | Médic Nature | Baie Sitrus | Calme | M | Draco-Souffle · Lance-Flammes · Coton Garde · Atterrissage |

### D02 — Maître draconique 2 — canyon

**Épreuve draconique adaptative · Type/thème : Dragon / Sol · Palier ADAPT · ace N.38.** Orientation parmi les arches et sauvegarde d'un nid après tempête.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Vibraninf | 36 | Lévitation | Baie Oran | Jovial | P | Draco-Souffle · Telluriforce · Éboulement · Bourdon |
| 2 | Carmache | 37 | Voile Sable | Évoluroc | Rigide | P | Draco-Griffe · Piétisol · Éboulement · Abri |
| 3 **(ace)** | Incisache | 38 | Brise Moule | Baie Sitrus | Rigide | P | Draco-Griffe · Tranche · Danse Draco · Crocs Feu |

### D03 — Maître draconique 3 — glaciers

**Épreuve draconique adaptative · Type/thème : Dragon / Glace · Palier ADAPT · ace N.38.** Parcours de gel et de réchauffement des caches de nourriture.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Amagara | 36 | Peau Gelée | Baie Oran | Calme | M | Vent Glace · Pouvoir Antique · Onde Folie · Protection |
| 2 | Draco | 37 | Mue | Évoluroc | Calme | M | Draco-Souffle · Laser Glace · Cage Éclair · Abri |
| 3 **(ace)** | Polarhume | 38 | Rideau Neige | Baie Sitrus | Rigide | P | Chute Glace · Aqua-Jet · Tranche · Charme |

### D04 — Maître draconique 4 — crêtes chaudes

**Épreuve draconique adaptative · Type/thème : Dragon / Feu · Palier ADAPT · ace N.38.** Éviter les jets de vapeur et stabiliser trois stations de sécurité.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Chartor | 36 | Écran Fumée | Baie Oran | Assuré | D | Lance-Flammes · Piège de Roc · Tour Rapide · Abri |
| 2 | Drackhaus | 37 | Tête de Roc | Évoluroc | Rigide | P | Draco-Griffe · Crocs Feu · Éboulement · Abri |
| 3 **(ace)** | Dracaufeu | 38 | Brasier | Baie Sitrus | Jovial | P | Draco-Griffe · Crocs Feu · Griffe Ombre · Atterrissage |

### A08 — Championne Dragon — dernière arène de la réserve

**Arène 8 · Type/thème : Dragon · Palier FINAL · ace N.98.** Équipe Dragon diversifiée, offensives physique/spéciale, Méga-Drattak ; arène fermée jusqu'aux 4 îles libérées et 4 épreuves dragon.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 | Dracaufeu | 95 | Brasier | Grosses Bottes | Timide | S | Draco-Météore · Lance-Flammes · Exploforce · Atterrissage |
| 2 | Kravarech | 96 | Adaptabilité | Veste de Combat | Modeste | S | Draco-Météore · Bomb-Beurk · Hydrocanon · Tonnerre |
| 3 | Tranchodon | 96 | Brise Moule | Bandeau Choix | Jovial | P | Colère · Séisme · Tête de Fer · Direct Toxik |
| 4 | Dracolosse | 97 | Multiécaille | Baie Prine | Rigide | P | Danse Draco · Colère · Vitesse Extrême · Séisme |
| 5 | Carchacrok | 97 | Peau Dure | Casque Brut | Jovial | P | Séisme · Draco-Griffe · Piège de Roc · Lame de Roc |
| 6 **(ace)** | Drattak | 98 | Intimidation > Peau Céleste (Méga) | Drattakite | Jovial | P | Danse Draco · Retour · Séisme · Atterrissage |

### C01 — Gardien céleste 1 — ténacité

**Défi divin 1/4 · Type/thème : Offense équilibrée · Palier FINAL · ace N.100.** Six combattants spécialisés, Méga-Lockpin.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 **(ace)** | Scalproie | 100 | Acharné | Lunettes Noires | Rigide | P | Danse-Lames · Tête de Fer · Sabotage · Coup Bas |
| 2 **(ace)** | Carchacrok | 100 | Peau Dure | Casque Brut | Jovial | P | Séisme · Draco-Griffe · Piège de Roc · Crocs Feu |
| 3 **(ace)** | Ectoplasma | 100 | Corps Maudit | Orbe Vie | Timide | S | Ball'Ombre · Bomb-Beurk · Exploforce · Tonnerre |
| 4 **(ace)** | Brutalibré | 100 | Délestage | Graine Herbe | Rigide | P | Acrobatie · Close Combat · Danse-Lames · Atterrissage |
| 5 **(ace)** | Métalosse | 100 | Corps Sain | Veste de Combat | Rigide | P | Poing Météore · Séisme · Poing Glace · Pisto-Poing |
| 6 **(ace)** | Lockpin | 100 | Joli Sourire > Querelleur (Méga) | Lockpinite | Jovial | P | Retour · Close Combat · Bluff · Poing Glace |

### C02 — Gardien céleste 2 — connaissance

**Défi divin 2/4 · Type/thème : Murs / contrôle · Palier FINAL · ace N.100.** Stratégies défensives et changement de tempo, Méga-Ténéfix.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 **(ace)** | Noacier | 100 | Épine de Fer | Restes | Relax | D | Piège de Roc · Vampigraine · Gyroballe · Abri |
| 2 **(ace)** | Flagadoss | 100 | Régé-Force | Casque Brut | Assuré | D | Ébullition · Psyko · Paresse · Cage Éclair |
| 3 **(ace)** | Motisma-Lavage | 100 | Lévitation | Grosses Bottes | Calme | M | Hydrocanon · Change Éclair · Feu Follet · Balance |
| 4 **(ace)** | Porygon2 | 100 | Télécharge | Évoluroc | Calme | M | Tri Attaque · Soin · Tonnerre · Laser Glace |
| 5 **(ace)** | Symbios | 100 | Garde Magik | Orbe Vie | Modeste | S | Psyko · Exploforce · Ball'Ombre · Plénitude |
| 6 **(ace)** | Ténéfix | 100 | Farceur > Miroir Magik (Méga) | Ténéfixite | Assuré | D | Feu Follet · Sabotage · Soin · Provoc |

### C03 — Gardien céleste 3 — résilience

**Défi divin 3/4 · Type/thème : Pluie / endurance · Palier FINAL · ace N.100.** Pluie progressive, Méga-Laggron Chasse-Pluie.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 **(ace)** | Bekipan | 100 | Crachin | Roche Humide | Assuré | D | Vent Violent · Ébullition · Atterrissage · Demi-Tour |
| 2 **(ace)** | Ludicolo | 100 | Glissade | Orbe Vie | Modeste | S | Hydrocanon · Giga-Sangsue · Laser Glace · Exploforce |
| 3 **(ace)** | Hyporoi | 100 | Glissade | Lunettes Choix | Modeste | S | Hydrocanon · Draco-Météore · Laser Glace · Surf |
| 4 **(ace)** | Prédastérie | 100 | Régé-Force | Boue Noire | Assuré | D | Ébullition · Soin · Toxic · Buée Noire |
| 5 **(ace)** | Raichu d'Alola | 100 | Surf Caudal | Ceinture Force | Timide | S | Tonnerre · Psyko · Nœud Herbe · Machination |
| 6 **(ace)** | Laggron | 100 | Torrent > Glissade (Méga) | Laggronite | Rigide | P | Cascade · Séisme · Poing Glace · Surpuissance |

### C04 — Gardien céleste 4 — harmonie

**Défi divin 4/4 · Type/thème : Distorsion et polyvalence · Palier FINAL · ace N.100.** Répartition équilibrée des rôles, Méga-Mysdibule.

| # | Pokémon | Niv. | Talent (avant > après Méga) | Objet | Nature | EV HARD | Attaques |
|---|---|---:|---|---|---|---|---|
| 1 **(ace)** | Porygon2 | 100 | Télécharge | Évoluroc | Relax | D | Distorsion · Tri Attaque · Laser Glace · Soin |
| 2 **(ace)** | Gaulet | 100 | Régé-Force | Casque Brut | Malin | D | Spore · Giga-Sangsue · Bomb-Beurk · Synthèse |
| 3 **(ace)** | Mimiqui | 100 | Fantômasque | Orbe Vie | Rigide | P | Danse-Lames · Câlinerie · Ombre Portée · Griffe Ombre |
| 4 **(ace)** | Bétochef | 100 | Cran | Orbe Flamme | Brave | P | Vampipoing · Façade · Sabotage · Mach Punch |
| 5 **(ace)** | Grolem d'Alola | 100 | Peau Électrique | Ceinture Pro | Brave | P | Éclair Fou · Lame de Roc · Séisme · Explosion |
| 6 **(ace)** | Mysdibule | 100 | Intimidation > Coloforce (Méga) | Mysdibulite | Brave | P | Câlinerie · Tête de Fer · Coup Bas · Danse-Lames |

## Quatre maîtres draconiques : scaling nécessaire

Les fiches D01–D04 ci-dessus définissent le **tier d'entrée à N.38**. Tous les biomes étant ouverts après la première île, les joueurs peuvent choisir **n'importe quelle épreuve**, dans l'ordre voulu. Au lancement du combat, le tier est fixé en fonction du **dernier jalon d'île libérée**, pas du niveau du Pokémon le plus élevé du joueur :

| Îles ordinaires libérées | Tier de maître | Taille suggérée | Évolution des équipes |
|---:|---:|---:|---|
| 1 | 38 | 3 | Compositions D01–D04 telles qu'affichées |
| 2 | 57 | 4 | Sonistrelle→Bruyverne (48), Drackhaus→Drattak (50), Carmache→Carchacrok (48), Vibraninf→Libégon (45), Incisache→Tranchodon (48), Amagara→Dragmara (39 de nuit), Polarhume→Polagriffe (37), Draco→Dracolosse (55), selon les rôles ; conserver espèces de support adaptées |
| 3 | 80 | 5 | Formes finales, objets et sets FINAL ; ajouter un soutien/tank de biome, autorisé dans le roster sélectionné et sans Méga imposée |
| 4 | 95 | 6 | Formes finales + couverture/objets FINAL, six Pokémon et IA HARD optimisée, **pour les nouveaux défis ou les revanches facultatives**, sans rendre obligatoires les quatre revanches |

**Règle fondamentale :** une épreuve validée au tier 38 **reste validée**. Le joueur peut donc terminer les quatre dès l'île 1 mais ne peut pas accéder à la dernière arène avant la libération de l'île IV (proposition). Les revanches tardives sont optionnelles, sauf décision contraire du propriétaire. **Aucun Pokémon sauvage** d'une zone draconique ouverte au tier 38 ne passe artificiellement au tier 95 : respecter `earliest_access_cap` de Tactica. Les éventuelles rencontres haut niveau nécessitent des **sous-zones réellement ouvertes plus tard**, pas le recalcul des anciennes tables.

Pour Codex : les remplacements de stades à tier 57 sont des exemples conditionnels : ne jamais faire évoluer automatiquement une famille qui dépend d'une pierre, amitié, temps, objet tenu ou Fil Liaison par simple passage d'un seuil numérique ; utiliser une **entrée d'équipe autorisée et auditable** pour la version 57/80/95. Les listes tier 57/80/95 doivent être matérialisées en rosters distincts et vérifiées avant le développement jouable, elles ne sont **pas** de nouvelles équipes complètes certifiées ici.

## Les gardiens célestes et la divinité

Les quatre équipes C01–C04 sont à N.100 et précèdent un **cinquième combat** : la divinité céleste, dont l'identité est à valider. Ce dernier est un **boss raid scénarisé**, pas une sixième équipe de champion humain. **4 humains + 1 dieu = 5 combats**, avec soins, objets et CT entre les combats, **sans PC ni sortie**. Noms, Pokémon, Méga et sets gardiens sont des propositions ; vérifier globalement les Méga uniques dans **l'ensemble d'Archélys**. Aucun légendaire capturable durant l'histoire.

## Vérifications restantes et critères d'acceptation

- [ ] Extraire le Pokédex final choisi pour Archélys (et pas le Pokédex de Tactica), vérifier présence de chaque famille et ses formes ; remplacer les espèces absentes sans perdre la stratégie.
- [ ] Valider chaque espèce, nature, talent normal/HA, objet, stade, attaques (level-up / CT / tutor / œuf / transfert) contre les données de génération retenues et les exceptions custom approuvées.
- [ ] Corriger les combinaisons contestables (ce document ne prétend pas avoir exécuté Showdown), notamment certaines attaques de couverture, formes conditionnelles, talents des Pokémon de soutien et restrictions de la première île.
- [ ] Imposer **maximum 2 objets tenus** pour l'arène A02 si application stricte des deux premiers gyms Tactica ; retirer un objet non critique (par exemple celui de Magmar) avant import.
- [ ] Éliminer les doublons de Méga d'ace entre tous les dresseurs majeurs, y compris chefs RR finaux encore à définir.
- [ ] Vérifier le cap avant/après chaque raid et administrateur et empêcher une régression lors de l'aller-retour avec la réserve.
- [ ] Compiler les quatre tiers des quatre maîtres Dragon en rosters légaux ; éviter les jumps de stade inaccessibles et respecter les méthodes réelles.
- [ ] Vérifier que les compositions C01–C04 ne font pas intervenir un talent/mouvement 8G+ non disponible dans le périmètre choisi, ou une espèce réservée au raid local.
- [ ] Tester NORMAL/HARD sur les mêmes équipes, HARD IV/EV et IA sans omniscience ; simulations solo, 2 et 3 joueurs après implémentation des règles coop, pas avant.
- [ ] Ne pas annoncer ces builds « validés Codex » tant que les audits ci-dessus ne sont pas réussis et que le propriétaire n'a pas approuvé les fiches finales.

## Sources Tactica consultées

- [SOURCE_OF_TRUTH.md](https://github.com/DyHyugal/pokemon-tactica/blob/integration/v1/docs/spec/SOURCE_OF_TRUTH.md)
- [STRATEGIC_TEAMS_AND_ACCESS.md](https://github.com/DyHyugal/pokemon-tactica/blob/integration/v1/docs/spec/STRATEGIC_TEAMS_AND_ACCESS.md)
- [EVOLUTIONS.md](https://github.com/DyHyugal/pokemon-tactica/blob/integration/v1/docs/spec/EVOLUTIONS.md)
- [BOSSES_AI.md](https://github.com/DyHyugal/pokemon-tactica/blob/integration/v1/docs/spec/BOSSES_AI.md)
- [PROGRESSION.md](https://github.com/DyHyugal/pokemon-tactica/blob/integration/v1/docs/spec/PROGRESSION.md)
- [POKEMON_BALANCE.md](https://github.com/DyHyugal/pokemon-tactica/blob/integration/v1/docs/spec/POKEMON_BALANCE.md)

