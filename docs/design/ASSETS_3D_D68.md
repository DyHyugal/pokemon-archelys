# Kit graphique D68 — 12 octobre2026

Les sept planches D67 ont été explicitement approuvées par le propriétaire. Ce premier kit transforme leurs palettes/silhouettes en modèles originaux pour un test en jeu. Les assets restent des prototypes et les layouts de visite sont représentatifs ; la précision des illustrations n'est pas encore entièrement reproduite.

## Inventaire intégré

Sept maisons : tropicale à porche et toit turquoise ; mystique à colombages/toit violet ; hivernale enneigée/cheminée ; draconique pierre/bois ; high-tech à étage et bandeau cyan ; céleste claire à colonnes ; Æther à toit plat/jardin.

Sept grands repères : volcan à cratère ouvert et lave ; observatoire à dôme ; glacier ; porte draconique ; tour énergétique ; sanctuaire céleste ; plateforme/laboratoire Æther. L'occupation est signalée uniquement dans les régions concernées. Les modèles de repères sont visibles dans les visites, pas de combat/quête nouvelle attachée à eux.

Six props : palmier, arbre, pin enneigé, rocher, lanterne et banc. Architecture avec encadrements, marches, volets, porches, tuiles/bandeaux, bords adoucis. Matériaux de couleur continue, pas de textures pixellisées de ROM. Les meshes statiques sont regroupés par matériau à l'export pour réduire les nœuds/draw calls ; cela ne constitue pas un benchmark Windows.

Un avatar original : sept os, marche cyclique, tête/yeux/nez/bouche, cheveux, manches, pantalon, chaussures/lacets, sac et bretelles. Héros et PNJ réutilisent ce rig avec différentes palettes/coiffures. Quatre profils d'essai dans les visites : personnage courant, exploratrice, botaniste et uniforme RR. Ils partagent le même corps ; pas encore des modèles anatomiques masculins/féminins distincts. Le menu Personnage continue d'éditer peau/habits/cheveux/visage dans la campagne ; coiffure0 devient courte naturelle.

## Visite

Pause → Atlas/Studio → région → lieu → Visiter à pied. Stick ou commandes de déplacement configurées, rotation/zoom, B/Échap pour revenir. Choisir un profil change uniquement le visiteur. Les PNJ de ces visites sont décoratifs ; pas de dialogues/quêtes nouveaux ni d'intérieur visitable ajouté dans les autres régions. Les28sites sont des scènes représentatives, pas un archipel de campagne entier connecté.

La campagne réelle, sa position, ses flags, objets, Pokémon et sauvegardes restent isolés. Au retour, caméra, HUD, avatars et environnement lumineux sont restaurés. Les villes complètes, routes de liaison, scénario/intérieurs et Pokédex définitif restent un chantier de production.

## Sources et droits

Générateur : tools/create_archipelago_assets.py, Blender4.3.2. Sources éditables : art/source/archipelago/*.blend. Exports : game/assets/archipelago/*.glb et game/assets/prototypes/mannequin.glb (remplacement du mannequin historique). SHA256 des exports et des sources, auteur/origine, outil et statut de licence : game/assets/archipelago/provenance.json.

Géométrie et matériaux créés pour le projet ; aucune extraction de modèle/texture d'un jeu et aucun asset tiers importé. Les planches servent de référence approuvée. Redistribution dans la version de test autorisée par la demande de génération/intégration ; licence publique générale des assets du projet toujours à décider. Cette création n'ajoute aucun droit sur l'univers Pokémon. Le générateur historique create_prototype_avatar.py produit l'ancien mannequin : utiliser le nouveau générateur pour ce kit.

## Retour artistique attendu

Évaluer silhouettes des maisons, teintes, profondeur, lisibilité à caméra proche/lointaine, visage et proportions du personnage, couleurs/coiffures et marche. Les portraits, doigts détaillés, animation de course, faciales, interactions et modèles de Pokémon ne sont pas produits dans ce kit. Les surfaces extérieures des grandes îles ne sont pas encore sculptées comme les panoramas détaillés. Le jeu de test sert à décider les retouches avant généralisation des modules.
