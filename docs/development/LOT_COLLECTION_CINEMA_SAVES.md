# Lot D51 — Pokédex, mises en scène et sauvegardes

Objectif : poursuivre trois blocs solo regroupés pendant que le propriétaire garde la Méga de lab-0d10428 à tester. Portée : systèmes déjà demandés, utilisables dans le laboratoire sans produire les îles ni imposer les assets/le scénario final. Moteur et dépendances inchangés ; format de sauvegarde5 avec compatibilité1/2/3/4. Source produit et cadence : D51, D43, C25/J5/K5/Q06.

## Bloc 7 — Pokédex

Menu dédié, 17 espèces provisoires, filtres toutes/vues/obtenues, inconnues masquées. Une espèce est vue lors de son entrée réelle en combat, en simple ou double ; un Pokémon seulement généré et le banc adverse ne sont pas révélés. Acquisition dans équipe ou PC, évolution de niveau/objet et kit enregistrent les obtentions, sans effacer les stades antérieurs. Les détails connus donnent types et habitats du laboratoire ; base stats/talents après obtention. Données FR/EN existantes, sans description encyclopédique inventée ni modèle ajouté.

Les habitats partagent avec les rencontres leurs familles de base et plafond de pêche ; la légalité des stades est celle du catalogue. Ils ne prétendent pas cartographier les futures îles ni garantir une apparition au cap actuel. Pas de Pokédex final, deltas, Fakemons ou Megas supplémentaires.

## Bloc 8 — cinématiques et galerie

Timeline JSON originale, quatre cadrages de visite technique et une note secondaire. Caméra interpolée et bandeau de textes manuels, HUD masqué, déplacement/menu/interaction/combat/chargement bloqués. Avance par nouveau E/Entrée/clic ; aucune avance automatique, même ×4. Visite principale non passable, replay débloqué seulement après fin complète. Note secondaire passable, non rejouable. La caméra retrouve sa distance et le menu galerie revient à la fin. Replay sans récompense ni changement d'équipe/sac/progression.

Ces scènes ne sont pas une cinématique d'île ou une scène de scénario validée : pas d'animation des personnages, de musique finale, de production narrative ou graphique nouvelle. Le socle de présentation est testé ; les scènes finales nécessiteront leur propre mise en scène et assets.

## Bloc 9 — slots et autosave

Trois emplacements solo indépendants, choix actif et option autosave conservés. Slot1 garde l'ancien chemin manuel. Le menu décrit manuelle/auto/date UTC/premier Pokémon et donne chargement explicite, récupération de la précédente manuelle `.backup`, sauvegarde ici/nouvelle partie avec confirmation. Une nouvelle partie démarre en mémoire, ne supprime pas les anciens fichiers. Charger quitte la mémoire sans sauvegarder ; le LIRE-MOI l'explique.

Autosave activée par défaut dans ce laboratoire : fichiers distincts par slot, échéance60secondes réelles indépendante de la vitesse, attente hors combat/dialogue/cinématique/menu, uniquement si l'état a changé. Jamais de remplacement de la manuelle par l'autosave, ni sauvegarde automatique immédiate d'une partie chargée. Les préférences de langue/caméra restent indépendantes.

Format5 lit1/2/3/4. Ancienne manuelle préservée octet pour octet en `.vN.backup` avant une écriture migrée ; backup roulante du précédent fichier valide. Un original invalide/unsupported explicitement remplacé est archivé avant remplacement. Les lectures invalides ne remplacent ni la campagne en mémoire ni le slot actif. Migration Pokédex : seuls les Pokémon actuellement possédés sont reconstitués, pas les anciens vus ni scènes jamais enregistrées.

## Vérification et limites

`tools/check_prototype.py` inclut 32 nouvelles assertions de domaine et 27 contrôles du parcours de scène, en plus du socle précédent. Vérifications : banc caché, doubles, deux méthodes d'évolution, habitats, migration4→5 avec original, séparation auto/manuelle/slots, préférences, corruption et backups, vrais boutons/checkboxes, avance manuelle ×4, verrouillage/caméra/replay et restauration d'un état par chargement. Aucun test propriétaire Nuzlocke/Soul-link/multi demandé.

Le PCK exporté est rendu sous Linux/Mesa et les nouvelles pages/cadrages sont inspectés. Cela ne valide pas Windows sur le PC du propriétaire, ni les graphismes de production. La qualité artistique reste à retravailler ; le thème de village seul est retenu. Un seul LIRE-MOI rassemble les essais des nouveaux systèmes et la Méga si elle n'a pas encore été vérifiée. La portée globale limitée de combat9G du lot D49 demeure inchangée.

Preuves locales du lot : [journal](validation/collection-checks.log), [Pokédex](validation/collection-dex.png), [timeline](validation/collection-cinematic.png), [emplacements](validation/collection-saves.png). La suite obligatoire est réussie : 216 assertions de domaine, 27 contrôles du nouveau parcours de scène et les autres scènes/imports du socle. Export Windows et rendu du PCK contrôlés ; essai Windows du propriétaire encore attendu.

## Livraison vérifiée

Source `04a2317c0ea0d8ed19a1b28a1900cad8e4c5eb63`, préversion [lab-04a2317](https://github.com/DyHyugal/pokemon-archelys/releases/tag/lab-04a2317). [CI réussie](https://github.com/DyHyugal/pokemon-archelys/actions/runs/38155110664), 52 secondes. ZIP public téléchargé et contrôlé : CRC, manifeste/commit, empreintes EXE/PCK, LIRE-MOI du lot, notices et documentation embarquée. EXE officiel inchangé par rapport au laboratoire portable précédemment validé Windows. Aucune signature ajoutée, aucun merge automatique.

[Télécharger Windows](https://github.com/DyHyugal/pokemon-archelys/releases/download/lab-04a2317/Archelys-Laboratoire-Windows.zip). SHA256 ZIP : `e447a0564610e7f414025730afaaa378a19f8bffe48c90dea6f1ec27395b136b`. PCK : `703959c10c3e2cc280af425f52063211c1934cd4119b95101a805512f58ff053`. Essai propriétaire de ce lot et de la Méga encore attendus.
