SafeRoute Analytics – Pipeline ETL d'intégration de données accidentologiques

Ce notebook implémente un pipeline ETL complet en 6 étapes pour la startup SafeRoute Analytics,
dans le cadre d'un MSPR Intégration de données, Sécurité & RGPD.

# Données sources (data.gouv.fr / transport.data.gouv.fr)
- Accidents corporels : ~5 000 enregistrements (caractéristiques, localisation, gravité)
- Population municipale : 20 communes françaises avec superficie
- Arrêts de transport : ~2 000 arrêts (type, coordonnées GPS, commune)

# Architecture du pipeline
COLLECTE → STAGING → CONTRÔLE QUALITÉ → TRANSFORMATION → DATAWAREHOUSE → DASHBOARD

1. Collecte       – Chargement des CSV sources (simulation réaliste avec anomalies volontaires)
2. Staging        – Ajout de métadonnées de traçabilité (hash MD5, horodatage, statut)
3. Contrôle QC    – Détection de doublons, valeurs manquantes, coordonnées GPS invalides,
                    mois hors bornes, nb_victimes négatif ; export des rejets avec motif
4. Transformation – Standardisation, création de features (date, heure, tranche horaire,
                    gravité label, météo), jointures accidents × population × transport,
                    calcul d'un score de risque composite (0–100) par commune
5. Datawarehouse  – Chargement dans SQLite (1 table de faits, 2 dimensions, 4 agrégats)
6. Dashboard      – Visualisation matplotlib : 4 KPI + 5 graphiques (top communes,
                    répartition des risques, desserte transport, accidentalité horaire, météo)

# Stack technique
Python · pandas · numpy · sqlite3 · matplotlib · hashlib 
