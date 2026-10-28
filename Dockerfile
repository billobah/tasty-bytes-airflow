FROM astrocrpublic.azurecr.io/runtime:3.3-11

# dbt dans un environnement virtuel dédié, pour ne pas perturber Airflow
RUN python -m venv /usr/local/airflow/dbt_venv && \
    /usr/local/airflow/dbt_venv/bin/pip install --no-cache-dir dbt-snowflake

# Fichiers temporaires de dbt hors du projet monté
ENV DBT_TARGET_PATH=/tmp/dbt_target
ENV DBT_LOG_PATH=/tmp/dbt_logs