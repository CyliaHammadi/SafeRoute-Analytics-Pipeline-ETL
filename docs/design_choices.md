# Choix du design

## Principe

Le projet est KPI-first.

On part des KPI, puis on garde seulement les objets utiles.

## KPI retenus

- nombre d'avis publiés par jour,
- délai moyen par type de marché,
- top acheteurs,
- top CPV principaux,
- taux de rejet par batch.

## Ce que cela implique

### Il faut une fact principale
Oui, pour compter les avis et calculer le délai moyen.

### Il faut une table CPV séparée
Oui, parce qu'un avis peut avoir plusieurs CPV.

### Il faut 15 dimensions
Non, car ce serait hors besoin.

## Choix retenus

### dim_date
Nécessaire pour l'analyse temporelle.

### dim_buyer
Nécessaire pour les top acheteurs.

### dim_market_type
Nécessaire pour le délai moyen par type de marché.

### dim_cpv
Nécessaire pour analyser les CPV principaux.

### fact_notice_publication
Grain : 1 ligne = 1 avis.

### fact_notice_cpv
Grain : 1 ligne = 1 couple avis + cpv.

## Ce qu'on a volontairement exclu

- département,
- procédure,
- lots,
- textes longs,
- critères,
- adresses,
- enrichissements IA.

## Pourquoi

Parce que ce projet sert à :

1. cadrer les KPI,
2. choisir un grain,
3. garder peu de colonnes,
4. justifier chaque table.
