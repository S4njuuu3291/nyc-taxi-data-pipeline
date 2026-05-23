"""
transform_local.py — versi untuk Spark 4.1.1
"""

import sys
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, lit, when, unix_timestamp

# ============ KONFIGURASI ============
SOURCE_BUCKET   = "spark-porto-dev-data-lake-bronze"
SILVER_BUCKET   = "spark-porto-dev-data-lake-silver"
QUARANTINE_BUCKET = "spark-porto-dev-data-lake-quarantine"
OUTPUT_PREFIX_SILVER     = "yellow_tripdata_silver/2025/03"
OUTPUT_PREFIX_QUARANTINE = "yellow_tripdata_quarantine/2025/03"
DATABASE        = "spark_porto_dev_data_lake_db"
TABLE_SILVER    = "yellow_tripdata_silver"
TABLE_QUARANTINE = "yellow_tripdata_quarantine"

FILE_PATH = "data/source/yellow_tripdata_2025-03.parquet"

# ============ SPARK SESSION UNTUK SPARK 4.1.1 ============
spark = SparkSession.builder \
    .appName("nyc-taxi-transform-local") \
    .master("local[*]") \
    .config("spark.driver.memory", "4g") \
    .config("spark.executor.memory", "2g") \
    .config("spark.jars.packages",
            "org.apache.hadoop:hadoop-aws:3.4.0,"  # Versi compatible dengan Spark 4.1.1
            "com.amazonaws:aws-java-sdk-bundle:1.12.262") \
    .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
    .config("spark.hadoop.fs.s3a.aws.credentials.provider",
            "com.amazonaws.auth.DefaultAWSCredentialsProviderChain") \
    .config("spark.hadoop.fs.s3a.connection.establish.timeout", "15000") \
    .config("spark.hadoop.fs.s3a.connection.timeout", "300000") \
    .config("spark.hadoop.fs.s3a.connection.maximum", "100") \
    .config("spark.hadoop.fs.s3a.socket.send.buffer", "65536") \
    .config("spark.hadoop.fs.s3a.socket.recv.buffer", "65536") \
    .config("spark.hadoop.fs.s3a.threads.max", "20") \
    .config("spark.sql.adaptive.enabled", "true") \
    .config("spark.sql.adaptive.coalescePartitions.enabled", "true") \
    .getOrCreate()  # JANGAN gunakan .enableHiveSupport() untuk local

spark.sparkContext.setLogLevel("WARN")

# ============ CALLER IDENTITY ============
import boto3
sts = boto3.client("sts")
identity = sts.get_caller_identity()
print(f"Running as: {identity['Arn']}")

# ============ TRANSFORM ============
def transform(spark, file_path, silver_bucket, quarantine_bucket,
              output_prefix_silver, output_prefix_quarantine,
              database, table_silver, table_quarantine):

    print(f"Reading data from {file_path}")
    df = spark.read.format("parquet").load(file_path)
    print(f"Data successfully read, count: {df.count()}")

    df = df.withColumn(
        "duration_hours",
        (unix_timestamp("tpep_dropoff_datetime") - unix_timestamp("tpep_pickup_datetime")) / 3600
    )

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

    # Repartition untuk performa
    valid_df = valid_df.coalesce(2)
    invalid_df = invalid_df.coalesce(1)

    # === SILVER ===
    silver_path = f"s3a://{silver_bucket}/{output_prefix_silver}"
    valid_df.write.mode("overwrite") \
        .format("parquet") \
        .option("compression", "snappy") \
        .save(silver_path)
    print(f"Silver DONE: {silver_path}")

    # === QUARANTINE ===
    quarantine_path = f"s3a://{quarantine_bucket}/{output_prefix_quarantine}"
    invalid_df.write.mode("overwrite") \
        .format("parquet") \
        .option("compression", "snappy") \
        .save(quarantine_path)
    print(f"Quarantine DONE: {quarantine_path}")

    return silver_path, quarantine_path


if __name__ == "__main__":
    try:
        silver_path, quarantine_path = transform(
            spark, FILE_PATH,
            SILVER_BUCKET, QUARANTINE_BUCKET,
            OUTPUT_PREFIX_SILVER, OUTPUT_PREFIX_QUARANTINE,
            DATABASE, TABLE_SILVER, TABLE_QUARANTINE
        )
        print(f"\n✅ Silver path: {silver_path}")
        print(f"✅ Quarantine path: {quarantine_path}")
    except Exception as e:
        print(f"❌ Error: {e}")
        raise
    finally:
        spark.stop()
        print("=== TRANSFORM LOCAL COMPLETE ===")