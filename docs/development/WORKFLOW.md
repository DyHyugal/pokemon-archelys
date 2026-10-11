# Développement et intégration

## Branches

main = jalons validés ; develop = prochain jalon. Une branche temporaire par tâche isolée et une seule active par défaut. PR vers develop avec contrôles appropriés, suppression après fusion. Pas de branches durables par ville, île ou fonction. L’initialisation du dépôt vide est documentaire ; ce n’est pas une release.

Le premier dépôt contient main avec présentation et règles, develop avec le cadrage. Le bootstrap de develop est une initialisation documentaire, pas une intégration de code sans revue.

## Tâches

Chaque tâche indique besoin concret, décisions de référence, portée, critères d’acceptation, dépendances, risques sauvegardes et méthode de validation. Petits commits ; pas de réécriture de l’historique partagé. Tests utiles sur règles et transitions, validation owner sur visuel/scénario et tests multi réels. Un build qui compile ne prouve pas l’aventure terminée.

## Décisions et périmètre

Le propriétaire réserve les choix de design et le pilotage. Les choix techniques sont autonomes dans les limites approuvées. Une idée nouvelle est décrite avec effet sur périmètre ; ne pas promettre sa V1 ni l’implémenter sans décision claire. Le backlog peut recueillir les idées sans changer le cahier.

## Wiki et outils

GitHub pour issues, roadmap et documentation ; les documents joueurs reprennent les rubriques Tactica, sans reprendre sa ROM ni ses données. Publication FR/EN, même rubrique en changement de langue. Mécanisme à vérifier ; éviter deux sources concurrentes.

Code, données et assets séparés. Git LFS proposé avant gros binaires ; pas de configuration présupposée. Versions de moteur/outils figées après essais ; licences enregistrées. Maintenir migrations de sauvegardes et sauvegardes de secours à partir de l’alpha publique.
