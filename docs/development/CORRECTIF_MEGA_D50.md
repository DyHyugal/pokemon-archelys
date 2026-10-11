# D50 — Méga sur le Pokémon déjà possédé

Le retour propriétaire valide le reste de lab-58819aa, notamment les CS et le thème/type du village. Il signale l'absence de choix Méga avec le kit. Nuzlocke et Soul-link ne sont pas testés et sont reportés ; le thème approuvé ne constitue pas une validation de la qualité graphique ni un choix définitif entre les variantes.

## Cause et correction

Le kit ajoutait un nouveau Dracaufeu équipé mais laissait sans pierre l'individu déjà évolué du joueur. Le contrôle Méga était masqué pour cet individu. Le kit équipe désormais les individus compatibles existants sans changer leur identité, niveau, PV, PP ou attaques ; leur ancien objet retourne au sac. Une pierre compatible déjà tenue est conservée, notamment Dracaufeu X. Répéter le kit ne crée pas de nouveaux doublons. Les pierres restent aussi disponibles dans le sac.

Dans les choix d'attaques solo et doubles, le contrôle Méga est visible. Il est désactivé avec une explication si la pierre manque, l'espèce est incompatible, la Méga est déjà utilisée ou réservée par l'autre acteur en double. Le joueur active le contrôle puis choisit son attaque ; la transformation conserve les règles du simulateur existant.

L'activation d'un nouveau défi Nuzlocke est retirée de l'interface pour cette phase. Les états historiques et sauvegardes restent préservés. Aucune migration de format : schéma 4 inchangé, mêmes dépendances et même nom d'exécutable.

## Vérifications

`tools/check_prototype.py` passe intégralement : 184 assertions de domaine, scènes d'exploration/combat, import GLB et scène générale. Le nouveau test `game/tests/mega_ui.gd` reproduit le Dracaufeu niveau 37 déjà possédé, vérifie le retour de l'ancien objet, l'absence de doublons, l'activation depuis le vrai contrôle et la vraie attaque, Sécheresse, le nettoyage de forme, la pierre X conservée et la réservation en double.

Le PCK Windows exporté est également exécuté avec Godot sous Linux/Mesa : la capture du choix d'attaques a été inspectée et montre le contrôle Méga au-dessus des quatre attaques, sans chevauchement. Ce contrôle technique ne remplace pas l'essai Windows du propriétaire pour ce correctif.

Le LIRE-MOI du ZIP concentre le prochain essai sur F3 → combat → Attaquer → Méga → attaque. Aucun nouvel essai des systèmes déjà validés ni de Nuzlocke/Soul-link n'est demandé. Les graphismes ne changent pas dans ce correctif.

## Livraison vérifiée

Source du build : `0d10428794d2fdf4053a3db4acbd7988520c4f46`, préversion [lab-0d10428](https://github.com/DyHyugal/pokemon-archelys/releases/tag/lab-0d10428). [CI réussie](https://github.com/DyHyugal/pokemon-archelys/actions/runs/38151466877), 42 secondes. Le ZIP public a été téléchargé : CRC, empreintes, commit du manifeste, instructions ciblées et fichiers de documentation contrôlés.

[Télécharger le ZIP Windows](https://github.com/DyHyugal/pokemon-archelys/releases/download/lab-0d10428/Archelys-Laboratoire-Windows.zip). SHA256 du ZIP : `b4bbedc9725ca7cb729ced3766fe21a41975d427aaeb0c0acc4e357e08f5b474`.

L'exécutable officiel Godot reste identique à celui de la distribution précédemment testée par le propriétaire ; aucune nouvelle signature Authenticode n'est annoncée. Son SHA256 est `91724f15024a3a545e28ccd83134403d31ce2323a38e51c95e4dfa282f732ab6`. Le contenu du jeu est dans le PCK séparé.

Preuves : [journal des contrôles](validation/mega-fix-checks.log) et [capture du contrôle Méga dans le PCK exporté](validation/mega-checkbox-export.png). La validation Windows de cette nouvelle version reste à faire par le propriétaire. Branche temporaire poussée ; aucune fusion automatique.
