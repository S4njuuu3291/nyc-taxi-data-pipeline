"""
Ad-hoc script: Create a lightweight sample dataset from the full parquet file.

Usage:
    python create_sample.py

Output:
    data/yellow_tripdata_2025-03_sample.parquet  (50k rows)
"""

from pyspark.sql import SparkSession
from delta import configure_spark_with_delta_pip

SAMPLE_SIZE = 50_000
SOURCE_PATH = "data/yellow_tripdata_2025-03.parquet"
OUTPUT_PATH = "data/yellow_tripdata_2025-03_sample"

builder = (
    SparkSession.builder
    .appName("CreateSample")
    .master("local[*]")
    .config("spark.driver.memory", "2g")
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
)

spark = configure_spark_with_delta_pip(builder).getOrCreate()

print(f"Reading: {SOURCE_PATH}")
df = spark.read.format("parquet").load(SOURCE_PATH)

total = df.count()
print(f"Total rows: {total:,}")

sample = df.sample(fraction=min(1.0, SAMPLE_SIZE / total), seed=42)
# or use .limit() for exact count (non-random)
# sample = df.limit(SAMPLE_SIZE)

sample.write.format("parquet").mode("overwrite").save(OUTPUT_PATH)

written = spark.read.format("parquet").load(OUTPUT_PATH).count()
print(f"Sample saved: {OUTPUT_PATH} ({written:,} rows)")
print("Done!")

spark.stop()
