# D72 — douze blocs de démo intégrée

12 octobre 2026, Europe/Paris. Demande : « enchaine sur les 10/20 prochains blocs […] 20 […] jouable ». Lot livré : **douze blocs**, regroupés pour un seul playtest. Le nombre décrit des fonctions utilisables ou un outil exécutable ; les assertions ne sont pas comptées comme des blocs. Pas de validation Windows implicite.

La démo reste une portion de la première île : havre, sentier et trois intérieurs. Ce lot ne construit pas les six îles, n’approuve pas un scénario définitif et ne sélectionne pas le futur Pokédex. Les niveaux, prix, espèces et récompenses restent des fixtures. Le registre Meshy reste vide ; aucun nouveau bâtiment ou personnage final produit. Les obstacles réutilisent les maquettes existantes pour éprouver les actions.

| Bloc | Résultat concret | Limite / contrôle |
|---|---|---|
| 1. Expédition facultative | Trois passages à dégager, relevés à récupérer, remise au professeur pour cinq Poké Balls. Journal et sauvegarde suivent les étapes. | Proposition locale, indépendante de l’objectif principal ; récompense atomique, unique, récupérable après libération du sac. |
| 2. Actions contextuelles | Coupe, Éclate-Roc et Force sur le sentier, débloqués après la balise. Interaction supprime l’obstacle réel et sa collision. | Aucun Pokémon compatible ni attaque apprise requis. Déblocage et placement provisoires ; Surf/Escalade de l’atelier ne sont pas ajoutés à ce sentier. |
| 3. Vol depuis la carte | Après conclusion avec Vyna, choisir havre ou sentier déjà visité depuis Carte locale. | Aucune nouvelle destination non visitée ; pas de Pokémon volant requis ; lieu d’arrivée accessible. |
| 4. Services dans leurs lieux | PC uniquement dans le Centre, dépôt depuis le résumé également protégé. Achats/ventes et vêtements dans la boutique, fossiles/soins au Centre. Fermer le menu conserve les changements dans l’auto si activée. | Réutilisation des services existants, pas de nouvelle économie finale. |
| 5. Pokédex de démo | Recherche des espèces découvertes, filtres vues/obtenues, types et méthodes/niveaux/lieux des rencontres réellement configurées, indications starter/œuf/fossile. | 22 espèces de catalogue, pas 500. Ne révèle pas les noms inconnus par recherche ; ne prétend pas qu’un habitat de l’atelier existe ici. |
| 6. Scènes manuelles et galerie | Deux scènes de cadrage au havre, déclenchées par Vyna, textes FR/EN, galerie après achèvement, replay sans récompense. | Propositions narratives avec modèles provisoires ; scènes principales non passables. Caméra restituée exactement ; replay au havre. Ce ne sont pas des cinématiques finales d’île libérée. |
| 7. Autosauvegarde séparée | Fichier `.auto` indépendant par emplacement, activation/désactivation, chargement confirmé depuis Sauvegardes. | 60 secondes réelles entre opportunités en exploration ; combat, dialogue, photo et menu suspendent l’écriture. Les événements/services et la sortie conservent aussi la progression dans l’auto si activée, sans remplacer le point manuel. Sauvegarder est explicite. |
| 8. Archives portables | Export JSON, sélection locale d’un fichier à importer, validation avant confirmation et écriture, ancienne copie valide conservée. | Format de démo seulement ; fichiers inconnus/incompatibles refusés. Sélecteur natif et permissions Windows à tester. Source importée conservée. |
| 9. Diagnostic des sauvegardes | Statut valide/absent/incompatible, starter, effectif et argent pour fichiers manuels, copies et autosaves ; chemin réel et ouverture du dossier. | La copie précédente n’est pas un historique illimité. Bouton d’ouverture Windows à tester. |
| 10. Inspection des imports | Page Modèles importés : provenance/droits/hash déclarés, disponibilité ; visionneuse 3D isolée, dimensions et rotation des exports enregistrés. | Registre vide expliqué. Visionneuse exercée avec un GLB existant, aucun export Meshy reçu. Ni retopologie automatique ni validation artistique/droits par cet écran. |
| 11. Préflight de contenu | `python tools/check_demo_content.py` contrôle noms FR/EN, stats, talents, types, attaques, références d’évolution et sélection/niveaux/équipes de la démo. | Lecture seule ; `--catalog` et `--content` permettent d’inspecter une proposition. Refuse les données non prises en charge plutôt que les inventer. Huit erreurs réelles exercées par `check_demo_content_contracts.py`. |
| 12. Lisibilité du combat | Panneau opaque pour climat/terrain, largeur des commandes adaptée à la fenêtre, cartes PV/niveaux localisées, jauges vert/ambre/rouge. | Showdown reste le moteur ; modèles et animations finales attendus. Messages manuels conservés. |

## Sauvegardes et isolation

Format `archelys-demo-1` conservé : nouveaux flags facultatifs et option `autosave` dont la valeur par défaut est vraie pour les anciens fichiers. Les dépendances des flags de l’expédition sont validées avant toute restauration. À l’accueil, Continuer l’autosauvegarde est distinct de Continuer la démo sauvegardée (point manuel). Avec auto désactivée, penser à Sauvegarder explicitement. Les deux scènes sont ajoutées à la liste des historiques autorisés. Aucun reset nécessaire. L’emplacement chargé reste propriétaire des écritures, distinct de celui sélectionné à l’accueil. Les fichiers de l’atelier ne sont pas modifiés.

L’export/import conserve la campagne, l’équipe, le rangement, les règles et les étapes. Les préférences globales langue/audio/caméra ne sont pas des éléments de cet export de campagne. Aucun cloud, multi, raid, défi Nuzlocke/Soul-link ni reproduction ajouté.

## Vérification

`tools/check_prototype.py` exécute les régressions existantes, le nouveau parcours intégré `demo_extended.gd`, le préflight et ses refus. Le parcours couvre actions avant/après scénario, absence de Pokémon compatible, collisions supprimées, récompense pleine/non duplicable, visibilité Pokédex, services, scènes/replay, séparation auto/manuelle, refus d’import, confirmation/restauration et isolation de l’atelier. Le même parcours est rendu en OpenGL à 1920×1080, avec captures réelles de scène, sauvegardes, Pokédex, visionneuse et combat. Linux llvmpipe ne valide pas les performances GPU Windows.

Les résultats exacts, commit, CI et téléchargement sont consignés après publication dans VERIFICATION_D72.md. Le parcours propriétaire est inclus dans LIRE-MOI.txt du ZIP. Pas de nouveau test manuel exigé pendant ce travail autonome.

## Régression trouvée par la CI

La première CI de la source 876f3c2 réussit ; celle de la synchronisation auto 3f7eb21 échoue dans l’ancien `tactics_scene.gd`. Reproduction avec le moteur natif et graine `[55,2,3,4]` : Abri protège correctement Florizarre, mais Étincelle puis Charge critiques mettent Tortank K.O., imposent un remplacement et laissent le compteur au tour précédent. Le test attendait un tour ouvert et ses assertions suivantes échouaient en cascade. Aucun défaut d’Abri ou de Showdown constaté.

La fixture pédagogique donne maintenant des EV PV/Défense Spéciale à Tortank pour conserver un premier tour utilisable. La sortie de l’essai tactique est aussi disponible lorsque le panneau demande un remplacement obligatoire. Une régression native de la graine fautive couvre l’ancien KO et la résistance de la nouvelle fixture ; un contrôle UI vérifie la sortie pendant un remplacement. Aucune règle générale de dégâts, critique ou combat officiel modifiée, aucun rééquilibrage définitif du jeu.
