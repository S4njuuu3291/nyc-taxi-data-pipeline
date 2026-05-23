#!/usr/bin/env python3
"""
Upload Python scripts from src/ to S3 glue-scripts bucket.
Usage: python scripts/upload_glue_scripts.py
"""

import boto3
import os

BUCKET = "spark-porto-glue-scripts"
SRC_DIR = "src"


def main():
    s3 = boto3.client("s3")

    # Pastikan bucket ada
    try:
        s3.head_bucket(Bucket=BUCKET)
    except Exception as e:
        raise RuntimeError(f"Bucket '{BUCKET}' tidak bisa diakses: {e}")

    uploaded = 0
    for filename in os.listdir(SRC_DIR):
        if not filename.endswith(".py"):
            continue

        local_path = os.path.join(SRC_DIR, filename)
        s3_key = filename

        s3.upload_file(local_path, BUCKET, s3_key)
        print(f"  ✓ {local_path} → s3://{BUCKET}/{s3_key}")
        uploaded += 1

    print(f"Done. {uploaded} file(s) uploaded.")


if __name__ == "__main__":
    main()
