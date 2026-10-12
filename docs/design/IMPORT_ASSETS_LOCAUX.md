# Import local des futurs assets

Aucun asset Meshy intégré : `game/assets/imported/registry.json` est vide. Le pipeline sert à préparer les exports, pas à transformer un PNG en3D ni à garantir une qualité artistique.

Inspection : `python tools/import_demo_asset.py fichier.glb`. Le fichier doit être un GLB2 avec textures/buffers intégrés ; PNG, ressources externes et géométrie Draco sont refusés pour ce pipeline.

Enregistrement exemple : `python tools/import_demo_asset.py boutique.glb --id shop --source "Meshy, référence et date à renseigner" --rights "Conditions applicables à renseigner" --scale 1 --rotation 0`. Puis importer avec Godot et exécuter les contrôles habituels. Le script copie le fichier en conservant l’original et enregistre son SHA256. Un fichier différent déjà au même ID n’est pas écrasé automatiquement.

Le registre peut remplacer les instances appelées par le constructeur des décors de démo (shop, center, villa, arcade, clocktower). Échelle et rotation sont explicites. Les collisions/portes demeurent des données de gameplay indépendantes : les vérifier après import. Les avatars personnalisables et modèles Pokémon demandent un branchement spécifique des matériaux, rigs et animations ; ce pipeline ne les finalise pas.

Un import réussi ne remplace pas l’inspection en jeu, le contrôle du dos/côtés, la lisibilité, la qualité des textures et les mesures de performances. Ne pas produire massivement avant ce premier essai.
