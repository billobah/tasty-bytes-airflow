FROM astrocrpublic.azurecr.io/runtime:3.3-11

# dbt dans un environnement virtuel dédié, mêmes versions que le poste local
RUN python -m venv /usr/local/airflow/dbt_venv && \
    /usr/local/airflow/dbt_venv/bin/pip install --no-cache-dir \
    "dbt-core==1.13.0b1" "dbt-snowflake==1.12.4"

# Fichiers temporaires de dbt hors du projet monté
ENV DBT_TARGET_PATH=/tmp/dbt_target
ENV DBT_LOG_PATH=/tmp/dbt_logs

# Dossier du profil de connexion (sans secret : les valeurs viennent de l'environnement)
ENV DBT_PROFILES_DIR=/usr/local/airflow/include/dbt