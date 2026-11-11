# Tasty Bytes: Airflow orchestration of the dbt project

**[Version française → README.md](README.md)**

An Airflow project (Astro CLI) that runs **every day at 10:00 (Brussels time)** the refresh of the dbt models of the [`tasty-bytes-dbt-snowflake`](https://github.com/billobah/tasty-bytes-dbt-snowflake) project on Snowflake.

## At a glance

| | |
|---|---|
| Orchestrator | Apache Airflow 3 (Astro Runtime 3.3) |
| Main DAG | `tasty_bytes_dbt_daily` |
| Schedule | every day at 10:00, Europe/Brussels time zone (daylight saving handled automatically) |
| Command run | `dbt build --select tag:daily+`: models tagged `daily` and their dependents, tests included |
| Catch-up | disabled (`catchup=False`): a missed day is not replayed |
| Snowflake connection | environment variables, no secret in the repository |

## How it works

```
Airflow (Astro container)
   └─ DAG tasty_bytes_dbt_daily  ── every day at 10:00
        └─ task dbt_build_daily  ── dbt build --select tag:daily+
              └─ dbt (dedicated virtual environment) ──► Snowflake
```

1. The Docker image (`Dockerfile`) installs dbt in a separate virtual environment, so its libraries do not mix with Airflow's.
2. The dbt project folder is mounted read-only in the container (`docker-compose.override.yml`).
3. The DAG runs `dbt build` on the models carrying the `daily` tag: the two fact tables (`fct_orders`, `fct_order_items`) and what depends on them.
4. The connection profile (`include/dbt/profiles.yml`) reads all its settings from environment variables. The password is never written in a versioned file.

## Running the project

1. Install Docker and the [Astro CLI](https://www.astronomer.io/docs/astro/cli/install-cli).
2. Clone this repository and the dbt project, then adapt the dbt project path in `docker-compose.override.yml`.
3. Set the connection environment variables: `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, `DBT_ENV_SECRET_SNOWFLAKE_PASSWORD`, `SNOWFLAKE_ROLE`, `SNOWFLAKE_WAREHOUSE`, `SNOWFLAKE_DATABASE`, `SNOWFLAKE_SCHEMA` (for example in a `.env` file, ignored by Git).
4. Start Airflow: `astro dev start`.
5. Open the Airflow interface, enable the `tasty_bytes_dbt_daily` DAG and trigger it once.

## Structure

```
dags/
├── tasty_bytes_dbt_daily.py   # daily refresh DAG
└── exampledag.py              # Astro example (not used by the project)
include/dbt/profiles.yml       # dbt profile, read from the environment
Dockerfile                     # Astro image + dbt in a virtual environment
docker-compose.override.yml    # dbt project mount
tests/dags/                    # DAG integrity tests
