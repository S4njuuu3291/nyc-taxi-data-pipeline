from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .remote("sc://localhost:15002") \
    .appName("ClientSparkTaxi") \
    .getOrCreate()
print("Client Spark Connect berhasil terhubung ke Cluster Spark Connect di port 15002!")