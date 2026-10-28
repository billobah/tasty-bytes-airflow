from pendulum import datetime

from airflow.sdk import dag
from airflow.providers.standard.operators.bash import BashOperator

DBT = "/usr/local/airflow/dbt_venv/bin/dbt"
PROJECT_DIR = "/usr/local/airflow/dbt/tasty_dbt"
PROFILES_DIR = "/usr/local/airflow/include/dbt"


@dag(
    dag_id="tasty_bytes_dbt_daily",
    description="Mise à jour quotidienne des modèles dbt marqués 'daily' (et de leurs dépendants)",
    start_date=datetime(2026, 10, 1),
    schedule=None,  # pas de calendrier pour l'instant : lancement manuel
    catchup=False,
    default_args={"retries": 0},
    tags=["dbt", "tasty_bytes"],
)
def tasty_bytes_dbt_daily():
    BashOperator(
        task_id="dbt_build_daily",
        bash_command=(
            f"{DBT} build --select tag:daily+ "
            f"--project-dir {PROJECT_DIR} --profiles-dir {PROFILES_DIR}"
        ),
    )


tasty_bytes_dbt_daily()