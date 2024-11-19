## [1] Revoir la structures des fichiers
## [2] Optimiser le gestionnaires d'etats car c'est un point crucial et sa doit etre une base solide :

1. **Réduction des appels redondants** :
   - **Éviter les vérifications multiples** : Certaines assertions (comme `assertFunction(self.currentState, "mousepressed")`) sont appelées dans chaque fonction d'événement. Si tu sais qu'un état existe et qu'il contient les méthodes nécessaires, ces vérifications pourraient être conditionnelles plutôt que systématiques, sauf si tu veux une sécurité accrue pendant le développement.

2. **Gestion de la mémoire pour les états** :
   - **Libérer la mémoire des anciens états** : Quand tu passes d'un état à un autre, les anciens états peuvent continuer à occuper de la mémoire (bien que cela ne soit pas un problème immédiat avec des objets de petite taille). Une gestion explicite de la mémoire, par exemple en supprimant les données d'un état avant de charger un nouvel état (par exemple dans `setState`), peut être utile.
   - **Réutiliser des états** : Si tu sais que certains états seront utilisés plusieurs fois, tu peux envisager un système de mise en cache où tu gardes une référence à des états déjà créés pour éviter de recréer les mêmes objets plusieurs fois.

3. **Optimisation des files d'attente d'états** :
   - **File d'attente dynamique** : Actuellement, la file d'attente est triée à chaque ajout (`sortQueue()`), ce qui peut être coûteux à long terme si beaucoup d'états sont ajoutés. Une approche pourrait être d'utiliser une structure de données plus appropriée pour les files d'attente priorisées (comme un tas binaire), qui permet d'ajouter et de retirer des éléments de manière plus efficace.
   
4. **Lazy loading pour les états** :
   - **Chargement paresseux des ressources** : Lors du passage d'un état à un autre, tu peux charger les ressources nécessaires uniquement lorsque l'état est réellement activé. Cela réduit la charge mémoire et améliore les performances, surtout pour des jeux avec beaucoup d'assets.
   
5. **Séparation des données et des comportements** :
   - **Données externes** : Si certains états possèdent des données lourdes qui ne changent pas fréquemment, envisage de stocker ces données à l'extérieur de l'objet d'état (par exemple dans des tables séparées). Cela pourrait réduire la surcharge liée à la gestion de la mémoire si ces objets deviennent trop volumineux.

6. **Utilisation des coroutines** :
   - **Gestion asynchrone des états** : Si tu as des états nécessitant des chargements ou des animations longues, utiliser des coroutines pour gérer ces processus en arrière-plan pourrait rendre le jeu plus fluide et réactif sans bloquer le fil principal.

