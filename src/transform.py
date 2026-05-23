import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

# ============ INISIALISASI ============
args = getResolvedOptions(
    sys.argv, ['JOB_NAME',
    'source_bucket',
    'silver_bucket',
    'quarantine_bucket',
    'output_prefix_silver',
    'output_prefix_quarantine',
    'database',
    'table_silver',
    'table_quarantine'
])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

spark.conf.set("spark.sql.legacy.createHiveTableByDefault", "false")

job = Job(glueContext)
job.init(args['JOB_NAME'], args)

logger = glueContext.get_logger()

def transform(spark, file_path, silver_bucket, quarantine_bucket, 
              output_prefix_silver, output_prefix_quarantine,
              database, table_silver, table_quarantine):
    
    from pyspark.sql.functions import col, lit, when, unix_timestamp

    logger.info(f"Reading data from {file_path}")
    df = spark.read.format("parquet").load(file_path)
    logger.info(f"Data successfully read, count: {df.count()}")

    # Hitung duration hours
    df = df.withColumn(
        "duration_hours",
        (unix_timestamp("tpep_dropoff_datetime") - unix_timestamp("tpep_pickup_datetime")) / 3600
    )

    # Validation rules (sama seperti kode Anda)
    rules = [
        (~col("VendorID").isin([1, 2, 6, 7]), "invalid_vendor"),
        (~col("store_and_fwd_flag").isin(["Y", "N"]), "invalid_store_and_fwd_flag"),
        (col("tpep_pickup_datetime").isNull(), "null_pickup_datetime"),
        (col("tpep_dropoff_datetime").isNull(), "null_dropoff_datetime"),
        ((col("duration_hours") < 0), "negative_duration"),
        ((col("duration_hours") > 24), "duration_exceeds_24h"),
        ((col("trip_distance") < 0), "negative_trip_distance"),
        ((col("trip_distance") >= 300), "trip_distance_outlier"),
        ((col("passenger_count") < 0), "negative_passenger_count"),
        ((col("passenger_count") > 6), "passenger_count_exceeds_6"),
        (~col("RatecodeID").isin([1, 2, 3, 4, 5, 6, 99]), "invalid_ratecode"),
        ((col("PULocationID") <= 0), "invalid_pu_location_zero"),
        ((col("PULocationID") > 265), "invalid_pu_location_out_of_range"),
        ((col("DOLocationID") <= 0), "invalid_do_location_zero"),
        ((col("DOLocationID") > 265), "invalid_do_location_out_of_range"),
        (~col("payment_type").isin([1, 2, 3, 4, 5, 6]), "invalid_payment_type"),
        ((col("fare_amount") <= 0), "non_positive_fare"),
        ((col("fare_amount") >= 500), "fare_outlier"),
        ((col("extra") < 0), "negative_extra"),
        ((col("extra") > 10), "extra_outlier"),
        ((col("mta_tax") < 0), "negative_mta_tax"),
        (~col("mta_tax").isin([0, 0.5]), "invalid_mta_tax"),
        ((col("tip_amount") < 0), "negative_tip"),
        ((col("payment_type") == 2) & (col("tip_amount") != 0), "cash_tip_anomaly"),
        ((col("tolls_amount") < 0), "negative_tolls"),
        ((col("tolls_amount") > 100), "tolls_outlier"),
        (~col("improvement_surcharge").isin([0, 0.3, 1.0]), "invalid_improvement_surcharge"),
        ((col("congestion_surcharge") < 0), "negative_congestion_surcharge"),
        ((col("congestion_surcharge") > 5), "congestion_surcharge_outlier"),
        ((col("airport_fee") < 0), "negative_airport_fee"),
        ((col("airport_fee") > 5.0), "airport_fee_outlier"),
    ]

    condition_chain = lit("valid")
    for condition, label in rules:
        condition_chain = when(condition, lit(label)).otherwise(condition_chain)

    df = df.withColumn("status", condition_chain)

    valid_df = df.filter(col("status") == "valid")
    invalid_df = df.filter(col("status") != "valid")

    valid_df = valid_df.coalesce(2)
    invalid_df = invalid_df.coalesce(1)

    # ============ BAGIAN UTAMA ============
    # Buat database jika belum ada (pakai backticks karena ada hyphen)
    spark.sql(f"CREATE DATABASE IF NOT EXISTS `{database}`")
    
    # Buat temporary views dari dataframe agar bisa dipakai di SQL
    valid_df.createOrReplaceTempView("valid_df_temp")
    invalid_df.createOrReplaceTempView("invalid_df_temp")
    
    # --- SILVER ---
    silver_path = f"s3://{silver_bucket}/{output_prefix_silver}"
    spark.sql(f"""
        CREATE TABLE IF NOT EXISTS `{database}`.`{table_silver}`
        USING PARQUET
        LOCATION '{silver_path}'
        AS SELECT * FROM valid_df_temp LIMIT 0
    """)
    valid_df.write.mode("overwrite").insertInto(f"`{database}`.`{table_silver}`")
    logger.info(f"Silver table `{database}`.`{table_silver}` updated at {silver_path}")

    # --- QUARANTINE ---
    quarantine_path = f"s3://{quarantine_bucket}/{output_prefix_quarantine}"
    spark.sql(f"""
        CREATE TABLE IF NOT EXISTS `{database}`.`{table_quarantine}`
        USING PARQUET
        LOCATION '{quarantine_path}'
        AS SELECT * FROM invalid_df_temp LIMIT 0
    """)
    invalid_df.write.mode("overwrite").insertInto(f"`{database}`.`{table_quarantine}`")
    logger.info(f"Quarantine table `{database}`.`{table_quarantine}` updated at {quarantine_path}")

    return silver_path, quarantine_path

if __name__ == "__main__":
    file_path = f"s3://{args['source_bucket']}/yellow_tripdata/2025/03"
    transform(
        spark,
        file_path,
        args['silver_bucket'],
        args['quarantine_bucket'],
        args['output_prefix_silver'],
        args['output_prefix_quarantine'],
        args['database'],
        args['table_silver'],
        args['table_quarantine']
    )
    job.commit()