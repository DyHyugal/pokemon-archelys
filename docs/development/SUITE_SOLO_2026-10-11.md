# Suite solo après le retour du propriétaire

## Validation reçue

Le propriétaire a testé le build Windows `lab-09897ca` et confirme lancement, déplacement, fluidité, sauvegarde et combat factice OK. Multijoueur non testé, expressément reporté. Ce retour valide ces usages sur son PC, pas la direction artistique finale ni un moteur Pokémon complet.

## Changements de cette suite

Caméra orthographique rapprochée : taille 22 → 16, personnage suivi pour rester visible pendant l’exploration. Curseur de test 12–22 pour ajuster sans refaire un build ; réglage non sauvegardé. Décors toujours provisoires.

Premier socle dialogue : PNJ guide à droite du départ, interaction à proximité avec A/E/Entrée, phrases avancées manuellement, répétition d’une touche ignorée, déplacement suspendu. Textes FR/EN dans une ressource séparée et modèle de dialogue indépendant de la scène. Le guide ne fait partie ni du casting ni du scénario proposés ; aucune quête durable ajoutée. L’interface entière n’est pas encore bilingue.

Panneau réseau masqué par défaut, ancien essai conservé. Combat affiché en duel solo plutôt qu’en raid à trois. Aucun développement réseau, import coop, copie de sauvegarde invitée ou rattrapage dans cette tâche.

Sauvegarde inchangée (schéma 1) : pas de migration ni de suppression de la save du premier laboratoire. Le dialogue et la simulation de combat restent transitoires. Les réglages caméra/langue reviennent au défaut au lancement.

## Vérifications

`python3 tools/check_prototype.py` : import Godot, 19 contrôles du socle, 6 contrôles du modèle dialogue, modèle animé et scène réelle. La scène vérifie entrée clavier/mouvement, caméra rapprochée et suivi, refus de dialogue à distance, ouverture proche, répétition ignorée, absence d’avance automatique et blocage du mouvement, clôture manuelle, duel, sauvegarde/chargement.

Capture avec le renderer OpenGL Mesa : visuel réel du laboratoire ; aucune mesure représentative des performances de la machine propriétaire. Export Windows créé ; ce build modifié doit encore être essayé sous Windows. Le test réseau ancien n’est pas réexécuté dans cette tâche. Les logs et la capture de cette suite sont dans `validation/solo-checks.log` et `validation/laboratoire-solo.png`.

## Suite de conception

Maintenir les règles de jeu indépendantes des scènes et des connexions. Continuer le socle solo : données d’espèces/attaques, menus équipe/résumé et inventaire, puis boucle rencontre/combat/capture selon le petit lot sélectionné. Ne pas annoncer les règles 9G implémentées à partir du duel factice. Préparer des échantillons artistiques avant la production des îles ; scénario et choix ouverts restent à valider au retour du questionnaire.

Une seule branche temporaire active : `docs/cadrage-valide`. Les sources sont poussées dessus, pas fusionnées dans `develop` sans la procédure PR. Le ZIP est une prerelease technique, pas la première île jouable.
