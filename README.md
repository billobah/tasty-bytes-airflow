# Tasty Bytes : orchestration Airflow du projet dbt

**[English version → README.en.md](README.en.md)**

Projet Airflow (Astro CLI) qui lance **chaque jour, à 10 h (heure de Bruxelles)**, la mise à jour des modèles dbt du projet [`tasty-bytes-dbt-snowflake`](https://github.com/billobah/tasty-bytes-dbt-snowflake) sur Snowflake.

## En bref

| | |
|---|---|
| Orchestrateur | Apache Airflow 3 (Astro Runtime 3.3) |
| DAG principal | `tasty_bytes_dbt_daily` |
| Planification | tous les jours à 10 h, fuseau Europe/Brussels (heure d'été gérée automatiquement) |
| Commande exécutée | `dbt build --select tag:daily+` : les modèles marqués `daily` et leurs dépendants, tests inclus |
| Rattrapage | désactivé (`catchup=False`) : une journée manquée n'est pas rejouée |
| Connexion Snowflake | variables d'environnement, aucun secret dans le dépôt |

## Fonctionnement

```
Airflow (conteneur Astro)
   └─ DAG tasty_bytes_dbt_daily  ── tous les jours à 10 h
        └─ tâche dbt_build_daily ── dbt build --select tag:daily+
              └─ dbt (environnement virtuel dédié) ──► Snowflake
```

1. L'image Docker (`Dockerfile`) installe dbt dans un environnement virtuel séparé, pour ne pas mélanger ses bibliothèques avec celles d'Airflow.
2. Le dossier du projet dbt est monté en lecture seule dans le conteneur (`docker-compose.override.yml`).
3. Le DAG lance `dbt build` sur les modèles de l'étiquette `daily` : les deux tables de faits (`fct_orders`, `fct_order_items`) et ce qui en dépend.
4. Le profil de connexion (`include/dbt/profiles.yml`) lit tous ses paramètres dans des variables d'environnement. Le mot de passe n'est jamais écrit dans un fichier versionné.

## Lancer le projet

1. Installer Docker et l'[Astro CLI](https://www.astronomer.io/docs/astro/cli/install-cli).
2. Cloner ce dépôt et le projet dbt, puis adapter le chemin du projet dbt dans `docker-compose.override.yml`.
3. Définir les variables d'environnement de connexion : `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, `DBT_ENV_SECRET_SNOWFLAKE_PASSWORD`, `SNOWFLAKE_ROLE`, `SNOWFLAKE_WAREHOUSE`, `SNOWFLAKE_DATABASE`, `SNOWFLAKE_SCHEMA` (par exemple dans un fichier `.env`, ignoré par Git).
4. Démarrer Airflow : `astro dev start`.
5. Ouvrir l'interface Airflow, activer le DAG `tasty_bytes_dbt_daily` et le lancer une première fois.

## Structure

```
dags/
├── tasty_bytes_dbt_daily.py   # DAG de mise à jour quotidienne
└── exampledag.py              # exemple fourni par Astro (non utilisé par le projet)
include/dbt/profiles.yml       # profil dbt, lu dans l'environnement
Dockerfile                     # image Astro + dbt dans un environnement virtuel
docker-compose.override.yml    # montage du projet dbt
tests/dags/                    # tests d'intégrité des DAG
```
