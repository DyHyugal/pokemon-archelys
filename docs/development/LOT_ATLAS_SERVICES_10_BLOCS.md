# Lot atlas, services et confort — dix blocs, D67

SPOILERS DEV. Livraison groupée du12 octobre2026, même branche de travail. Objectif : continuer le solo et montrer les propositions des six îles plus Æther sans interrompre le propriétaire pour chaque sous-chantier. Catalogue22espèces/43attaques et Showdown épinglés inchangés. Reproduction retirée ; multi/raids/Nuzlocke/Soul-link reportés. Dernier retour Windows effectivement validé : D52.

| Bloc | Résultat développé | Critère technique |
|---|---|---|
| B01 Atlas | Sept régions,28ancres FR/EN et indication occupation | Six îles +Æther, pas RR en draconique/céleste ; pas ordre de campagne implicite |
| B02 Studio | Visite orbitale de volumes indépendants | Caméra, HUD, avatars restaurés ; campagne/mouvement/interactions/saves bloqués |
| B03 Vêtements | PNJ au havre, haut/pantalon proposés | Achat100₽ confirmé, refus atomique, palette persistante, éditeur libre conservé |
| B04 Œuf cadeau | PNJ au Centre du havre | Cadeau Carapuce unique via acquisition/incubateur existants ; pas doublon/reroll |
| B05 Commerce | Quantités1–99 et résumé de confirmation | Pas débit avant confirmation, refus complet si stock/fonds/capacité insuffisants |
| B06 Affichage | Fenêtre/sans bordure/plein écran,720p/900p/FHD, FPS/vsync | Préférences locales validées/atomiques ; pas resize répété par slider audio |
| B07 Manette | Stick/croix, A/B/Start/X/Y | Routage des modales et confirmation native GUI ; remappage spécifique ultérieur |
| B08 Combat | Transition courte du texte optionnelle | Pas avance automatique, pas calcul gameplay, pas prétention d'animation finale |
| B09 Confort | Repères3D et mouvements réduits, dialogue responsive | Affecte décors/caméra/UI ; garde progression et confirmations manuelles |
| B10 Terrain | Trois obstacles locaux Coupe/Éclate-Roc/Force | Un seul catalogue position/rayon/flag pour rendu, interaction et collision ; état sauvé |

## Sauvegardes et isolation

Campagne5 conservée, `island.cleared` optionnel, anciennes campagnes sans champ lisibles. Chaque clairance doit correspondre à un obstacle connu et son drapeau narratif ; falsification sans déblocage refusée. Vêtements utilisent l'apparence existante, cadeaux l'incubateur existant. Aucune remise à zéro des équipes ou campagnes.

Préférences d'affichage/manette/confort sont locales au PC. Ajouts optionnels aux anciennes préférences audio/touches/thème ; valeurs de résolution/mode/FPS/booléens validées avant écriture atomique. Manette actuellement standard, sans mapping utilisateur persistant ; clavier remappable inchangé. Visiter le studio ne débloque pas de ville/campagne, ne fait pas marcher les œufs et ne déclenche pas d'autosave. Les lieux de studio ne sont pas des régions jouables connectées.

## Graphismes

Sept planches générées de quatre panneaux, affichées dans le chat et conservées sous docs/design/concepts et dans le ZIP. Atlas artistique : ATLAS_PROPOSE_2026-10-12.md. Sources/empreintes : provenance.json et briefs JSON. Pas de modèle ou décor officiel extrait. Ce sont des cibles visuelles proposées ; les études3D restent des volumes procéduraux plus simples avec modules communs. Aucun nom de ville, tracé exact ou esthétique approuvé implicitement.

La résolution1920×1080 règle la fenêtre ; elle ne prouve ni qualité finale des assets ni performances GPU. La vérification graphique Linux est sous Xorg/OpenGL llvmpipe logiciel. Fluidité Windows, manette physique et validation de la direction artistique restent à faire par le propriétaire.

## Vérifications et suite

Tests atlas_services : transactions vêtements refusées/réussies, migration/sécurité des préférences, déblocages d'obstacles sans Pokémon compatible, migration des saves et anti-falsification. Tests atlas_scene :28visites réellement ouvertes par menus, restauration du monde/caméra, isolement des actions, achats/vente réellement confirmés, PNJ uniques, save/reload, manette synthétique, paramètres appliqués, collision authoritative et messages à x4. Rendu réel : sept maquettes, boutique et paramètres FHD, modes de fenêtre/vsync. Résultats locaux : atlas_services39 contrôles et atlas_scene134 contrôles, zéro échec ; version avec rendu148 contrôles et neuf PNG, zéro erreur de script. FHD vérifié sur texture1920×1080. Le pilote logiciel signale que la synchronisation verticale réelle est indisponible : seul le réglage demandé est vérifié ici, pas sa cadence matérielle. Rapport complet et publication dans verification/ATLAS_2026-10-12.txt après CI.

Parcours propriétaire complet dans LIRE_MOI_WINDOWS.txt. Une seule session de retour peut couvrir le lot et les anciens chapitres encore non validés. Suite artistique proposée : choisir les silhouettes/palettes puis remplacer progressivement la première ville par un kit modulaire Blender/GLB, mesurer le coût d'assets avant généralisation. Les autres îles attendent leur construction jouable ; Pokémon/attaques animés ne sont pas produits par ce lot.
