from airflow import DAG
from airflow.decorators import task
from datetime import datetime, timedelta
import logging
from airflow.providers.amazon.aws.operators.glue import GlueJobOperator
from airflow.providers.amazon.aws.operators.glue_crawler import GlueCrawlerOperator


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

default_args = {
    "owner": "data_engineer",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="nyc_taxi_pipeline",
    default_args=default_args,
    description="NYC Taxi ETL pipeline: Bronze → Silver → Gold",
    schedule=None,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["nyc-taxi", "etl"],
) as dag:

    @task(task_id="dummy_task")
    def dummy():
        logger.info("Worker dummy task executed")
        return "Dummy task completed"


    transform_task = GlueJobOperator(
        task_id="transform_bronze_to_silver",
        job_name="spark-porto-dev-job-transform",
        script_args={
            "--source_bucket": "spark-porto-dev-data-lake-bronze",
            "--silver_bucket": "spark-porto-dev-data-lake-silver",
            "--quarantine_bucket": "spark-porto-dev-data-lake-quarantine",
            "--output_prefix_silver": "yellow_tripdata_silver/2025/03",
            "--output_prefix_quarantine": "yellow_tripdata_quarantine/2025/03",
            "--database": "spark-porto-dev_data_lake_db",
            "--table_silver": "yellow_tripdata_silver",
            "--table_quarantine": "yellow_tripdata_quarantine",
        },
        region_name="ap-southeast-1",
        aws_conn_id="aws_default",
        dag=dag,
    )

    dummy() >> transform_task