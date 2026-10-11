# Sondes Showdown — hors moteur du jeu

Ces fichiers originaux servent à une étude reproductible. Ils ne sont chargés ni par le jeu ni par sa CI. Aucun code Tactica n'est importé. La licence amont est conservée dans `Showdown-LICENSE.txt` ; les sources du simulateur restent dans un checkout extérieur.

Référence : Showdown `942cda71d14bf0618bd57991708a2e2734b6daba`. Essais réalisés avec Node24.19.0 et Godot4.6.3 sous Linux. Node>=22.18 est requis par le package amont.

Depuis un dossier extérieur au dépôt (adapter les chemins absolus ci-dessous) :

```sh
git clone https://github.com/smogon/pokemon-showdown.git pokemon-showdown
cd pokemon-showdown
git checkout 942cda71d14bf0618bd57991708a2e2734b6daba
npm ci --omit=optional
node build
export ARCHELYS_SHOWDOWN_ROOT="$PWD"
node /workspace/pokemon-archelys/experiments/showdown/probe.cjs
```

La sonde doit afficher un JSON avec `checks:25`, `passed:25`. Elle teste le vrai simulateur ; les erreurs terminent avec un code non nul. Le format d'essai n'a aucun PP Plus et autorise des éléments historiques sélectionnés en 9G.

Pour la liaison Godot, créer un dossier de projet **extérieur au jeu** avec ce seul `project.godot` :

```ini
config_version=5
[application]
config/name="Showdown feasibility only"
[rendering]
renderer/rendering_method="gl_compatibility"
```

Puis lancer avec le chemin absolu du vrai binaire Node (`command -v node`) :

```sh
godot --headless --path /chemin/projet-externe \
  --script /workspace/pokemon-archelys/experiments/showdown/pipe_probe.gd \
  -- /chemin/absolu/node /workspace/pokemon-archelys/experiments/showdown/probe.cjs
```

L'environnement `ARCHELYS_SHOWDOWN_ROOT` doit rester défini. Attendre `SHOWDOWN PIPE: 6 checks, 0 failures`. Le protocole JSON de recherche offre start/choose/quit, et permet l'inspection des deux camps. Les I/O bloquantes sont réservées à ce test headless ; ce n'est pas un adaptateur de production ni un flux autorisé pour l'IA.

Depuis le checkout Showdown compilé, les tests amont ciblés se lancent sans initialiser le serveur :

```sh
./node_modules/.bin/mocha --no-config \
  --require /workspace/pokemon-archelys/experiments/showdown/upstream_bootstrap.cjs \
  test/sim/moves/followme.js test/sim/moves/electricterrain.js \
  test/sim/moves/grassyterrain.js test/sim/moves/mistyterrain.js \
  test/sim/misc/megaevolution.js test/sim/misc/weather.js \
  test/sim/abilities/lightningrod.js test/sim/abilities/intimidate.js \
  --reporter dot --timeout 8000
```

Résultats conservés : 25 sondes, 6 contrôles de liaison, 61 tests amont réussis et 2 déjà ignorés par l'amont. Aucun combat réseau, raid ou build Windows avec Node testé. Voir le [rapport de comparaison](../../docs/development/ETUDE_MOTEUR_SHOWDOWN.md) pour les limites et la proposition d'architecture.
