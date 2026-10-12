# D68 — assets et visite graphique groupée

Objectif : intégrer les concepts validés et rendre les régions visitables avec prototypes d'avatars. Même checkout/branche de travail, aucun merge main/develop. Sauvegarde5 et catalogue22/43/Showdown inchangés. Pas de fonction multi/raid/défi ni reproduction.

21GLB Blender originaux et sources éditables, maisons des sept régions et leurs repères, six props et avatar. Maisons/volcans et PNJ du havre/laboratoire utilisent les nouveaux meshes ; sept os et marche réutilisent les contrôles existants. Apparence de campagne conservée ; rendu coiffure0 courte naturelle. Les anciens choix d'habit sont restaurés sur tous les sous-meshes concernés.

Atlas28sites : vue orbitale puis marche locale, avatar indépendant, collisions maisons/PNJ/limites, déplacement par petits pas pour éviter traversée à vitesse élevée, profils de visite indépendants. À la sortie : campagne/mouvement principal/économie inchangés, restauration caméra/HUD/environnement. La variante mystique et les nuages célestes ont leur présentation dédiée. Les visites ne sont pas des chapitres de campagne débloqués et n'ont pas les quêtes/intérieurs complets des sept régions.

Tests : suite tools/check_prototype.py (fonctionnalités antérieures incluses), archipelago_assets : présence des modèles et rig, marche locale, arrêt devant les maisons, indépendance des profils, retour à la campagne et provenance. Rendu réel sous Xorg/OpenGL llvmpipe, panoramas+marche des sept régions et gros plan du personnage. Les assertions techniques ne valent pas validation artistique Windows. Captures dans Comparatifs, concepts approuvés dans Concepts, parcours groupé dans LIRE-MOI. Résultats/push/CI consignés dans verification/ASSETS_2026-10-12.txt après publication.

Limites : premier kit sans textures peintes/terrain complet, rig de prototype, un corps partagé par les profils, pas de PNJ narratifs nouveaux dans les visites, pas d'animation de course/attaque ou modèle Pokémon ajouté. LIRE-MOI précise ce qui est à tester. Sources/empreintes : ASSETS_3D_D68.md et provenance.json.

Résultats locaux : suite complète verte,75 contrôles assets/visites,105 contrôles avec rendu et15 captures1920×1080, zéro erreur de script. Pilotage/menus, palettes et rig vérifiés ; llvmpipe logiciel, aucune mesure de performance Windows. Sources/exports21 SHA256 vérifiés. Validation utilisateur des modèles et manette physique attendue.
