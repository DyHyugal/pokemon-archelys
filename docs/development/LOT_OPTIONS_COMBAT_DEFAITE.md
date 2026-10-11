# D65 — styles de combat, soins du sac et parcours de défaite

Date :12 octobre2026, Europe/Paris. Lot solo regroupé, autorisé par la poursuite autonome demandée par le propriétaire. Sources produit :I5 pour les options classiques, K4/C28 pour la défaite. Les nouveaux tests et la livraison technique ne constituent pas un nouveau retour Windows du propriétaire ; dernière validation reçue D52.

## Styles Défini / Choix

Menu Règles, hors combat : Défini conserve le comportement du laboratoire ; Choix propose de changer après le KO de l'actif adverse dans un combat de dresseur simple. Le prochain adversaire est choisi par l'IA avant la proposition et reste le même si le joueur accepte ou refuse. Seule son espèce annoncée est exposée, sans set, talent ou objet caché supplémentaire.

Les textes du KO doivent être confirmés avant le choix. Garder le membre actuel n'utilise pas d'action. Changer utilise la requête de remplacement native de Showdown : sorties, remise à zéro des modifications temporaires, pièges d'entrée et talents sont résolus par le simulateur. Pas de tour d'attaque supplémentaire, de PP ou de décrément supplémentaire du climat. Le compteur de tour pendant la proposition représente le tour dont l'action a déjà été effectuée.

Pas de proposition en combat sauvage ou double, sans réserve apte, après le dernier adversaire ou lorsque l'actif du joueur est aussi KO. Le remplacement obligatoire conserve sa priorité. Un KO causé par les pièges après un changement gratuit produit la demande native de remplacement, sans blocage du combat. Les changements volontaires ordinaires et leur coût restent identiques.

## Soins du sac

Option Autoriser les soins du sac en combat. Désactiver bloque Potions, Antidotes et Anti-Para dans l'interface, le domaine et le bridge ; refus sans objet perdu, PV modifiés ou tour dépensé. Le sac peut rester consultable. Les captures conservent leurs propres règles ; Centres, soins hors combat et objets tenus ne sont pas bloqués. Les objets de soins en double restent indisponibles comme dans le laboratoire précédent : ce lot ne tranche pas leur coût futur.

Cette option fournit ON/OFF, pas un quota numérique inédit ni une nouvelle règle de raid. Une limite chiffrée éventuelle n'est pas inventée. Réglage de campagne pour le solo ; adaptation multijoueur reportée.

## Défaite et sauvegardes

Le retour prévu au Centre corrige l'ancien retour au village. La pénalité d'essai existante reste100₽, plafonnée à l'argent disponible ; ce n'est pas l'économie finale de l'archipel. Son application et les soins sont centralisés dans la finalisation unique du combat ; répéter cette finalisation ne débite pas une seconde fois. Les textes restent manuels, puis le monde affiche le Centre et une position d'entrée sûre. L'essai tactique conserve son aventure temporaire et ne déplace/débite pas la campagne propriétaire.

Options enregistrées dans l'exploration de la campagne5 sous les champs optionnels `battle_style` et `bag_healing`. Une sauvegarde ancienne reçoit Défini et soins autorisés, ce qui préserve son comportement. Types et valeurs invalides refusés ; édition en combat interdite. Lecture des versions précédentes et préservation des copies originales conservées. Sauvegarder/recharger après défaite garde lieu, argent et options.

## Portée de validation

Vrais combats simples/doubles dans les contrôles du bridge, pièges d'entrée et talents natifs, refus/acceptation, absence de proposition, KO simultané, climat et objets tenus ; menus Godot et disque, historique pendant la proposition, choix FR/EN, vraie défaite avec retour au Centre. Une capture GL Linux montre la proposition réelle. 29 nouvelles assertions bridge (70 au total),44 contrôles domaine/menus/disque et suite complète réussis. Rendu GL Linux :45 contrôles dont le PNG réel `verification/BATTLE_OPTIONS.png`. La preuve de livraison consigne la CI et la distribution.

Catalogue22/43, Showdown épinglé et moteur amont inchangé ; seul le bridge Archélys reçoit cette orchestration. Aucun asset/île finale, aucune production narrative ou mode reporté ajouté. Les animations de combat configurables restent à développer avec leur présentation graphique ; ce lot ne prétend pas les livrer.
