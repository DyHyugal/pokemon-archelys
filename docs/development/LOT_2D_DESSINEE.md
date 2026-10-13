# D79 — petite démo 2D directement dessinée

## Demande et périmètre

Le propriétaire approuve les deux directions A/B, préfère B et accepte A si la complexité de B l'impose. Après une véritable capture statique Godot, il demande : « go pour la demo avec ce style là ! ». Le résultat précédent D78, précalculé à partir de Tripo, était rejeté artistiquement. Cette autorisation porte sur une portion jouable ; ce n'est pas une validation de l'île entière ou des nouveaux intérieurs.

Havre, maison, Centre, boutique et court sentier. Fonds directement dessinés via image_gen, héros indépendant fixe, PNJ dérivés du même dessin avec recoloration de veste. Aucune conversion Tripo pour cette portion. Le moteur affiche les fonds comme des sprites/AtlasTexture, pas comme une scène 3D.

## Jeu conservé

Vraie sélection des starters provisoires, dialogues FR/EN, déplacement et course, collisions, interactions au clavier/manette, entrées/sorties à la porte correspondante, soins et PP, PC, achats, sac, rencontres/capture/fuite, dresseur, balise, retour à Vyna et sauvegardes. Ces services utilisent le domaine existant ; Showdown reste le simulateur réel. La carte locale reprend le dessin et les véritables coordonnées des points. Zoom réglable via distance caméra.

Les cartes dessinées partagent leurs coordonnées de collision, points, PNJ et herbes dans `drawn_layouts.gd`. Une exploration en largeur vérifie que chaque service/porte/objectif a une approche accessible à partir de son point d'arrivée. Les façades, comptoirs, banquette/PC et eau ne sont pas des zones traversables. Les actions contextuelles enlèvent un marqueur séparé et son collider ; les rochers peints ne sont pas effacés.

La portion se termine au nord du sentier ; la suite canopée/sources/poste est explicitement hors de ce lot. Aucune production silencieuse des autres îles. Roster, starters, histoire et équilibrage restent ceux des fixtures existantes, pas des choix définitifs.

## Sauvegardes et dépendances

Namespace `user://archelys_drawn_demo.json` et trois emplacements, distincts de la démo historique et de l'atelier. Schéma existant conservé ; anciennes parties non migrées ni écrasées. Un import situé hors de cette portion est refusé. Le socle historique reste présent pour les régressions ; le ZIP n'est donc pas représentatif d'une future distribution exclusivement 2D.

Aucune nouvelle dépendance. Godot 4.6.3, Node/Showdown hors ligne et le packager portable existant. EXE Windows officiel inchangé, PCK séparé, nom `Archelys-Laboratoire.exe` conservé. Aucune signature Authenticode supplémentaire prétendue.

## Limites artistiques concrètes

Le rendu B est maintenant utilisé en exploration jouable, mais les fonds restent précomposés. Pas de kit modulaire complet, pas de passage derrière les arbres, pas d'animation/marche directionnelle du héros et pas de personnalisation graphique de cette base. Le sélecteur conserve les données historiques mais est désactivé dans ce mode. Les PNJ ne constituent pas encore les designs individuels de Vyna, du professeur, de l'infirmière ou des commerçants.

Six illustrations Pokémon fixes couvrent les fixtures principales : Bulbizarre, Salamèche, Carapuce, Rattata, Pikachu et Magicarpe. Même illustration de face pour les deux côtés du combat ; les espèces non illustrées affichent leur nom, sans remplacement visuel par une autre espèce. Plateformes 2D et interface de combat fonctionnelles ; habillage final/dos/animations restent à réaliser. Dessins de Pokémon générés, pas d'assets officiels extraits. Provenance et empreintes : `game/assets/drawn/provenance.json`.

## Vérification et retour

Test `game/tests/drawn_demo.gd` : vrai parcours d'ouverture/starter, coordonnées de mouvement visibles, accessibilité des portes/services/objectifs, blocage d'une façade et du rivage, intérieurs/retours, soins HP/PP, PC/boutique/sac/carte, save/load, balise et action contextuelle, herbes, frontière de portion, Showdown/attaque/PP/fuite/retour et campagne atelier intacte. Captures prises depuis le viewport Godot, pas des illustrations présentées comme du gameplay.

Les résultats numériques et la livraison sont consignés dans la vérification de ce lot après exécution. Rendu Linux llvmpipe ; performance et validation Windows propriétaire restent distinctes. Parcours groupé dans le LIRE-MOI : nouvelle partie, village/services, sentier/combat, retour Vyna, zoom, sauvegarde/rechargement et avis graphique. Aucun nouveau playtest multi/raid/défi requis.
