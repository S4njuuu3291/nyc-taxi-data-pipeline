# Bucket: state lock Terraform
resource "aws_s3_bucket" "state_lock" {
    bucket = "${local.bucket_prefix}-state-lock"

    lifecycle {
      prevent_destroy = false
    }
}

# Versioning: state lock
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.state_lock.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket: bronze (raw data)
resource "aws_s3_bucket" "data_lake_bronze" {
    bucket = "${local.bucket_prefix}-data-lake-bronze"

    lifecycle {
      prevent_destroy = false
    }
}

# Public access: bronze
resource "aws_s3_bucket_public_access_block" "data_lake_bronze_privacy" {
  bucket = aws_s3_bucket.data_lake_bronze.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket: silver (cleaned data)
resource "aws_s3_bucket" "data_lake_silver" {
    bucket = "${local.bucket_prefix}-data-lake-silver"

    lifecycle {
      prevent_destroy = false
    }
}

# Public access: silver
resource "aws_s3_bucket_public_access_block" "data_lake_silver_privacy" {
  bucket = aws_s3_bucket.data_lake_silver.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket: gold (aggregated/curated data)
resource "aws_s3_bucket" "data_lake_gold" {
    bucket = "${local.bucket_prefix}-data-lake-gold"

    lifecycle {
      prevent_destroy = false
    }
}

# Public access: gold
resource "aws_s3_bucket_public_access_block" "data_lake_gold_privacy" {
  bucket = aws_s3_bucket.data_lake_gold.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket: quarantine (rejected/invalid data)
resource "aws_s3_bucket" "data_lake_quarantine" {
    bucket = "${local.bucket_prefix}-data-lake-quarantine"

    lifecycle {
      prevent_destroy = false
    }
}

# Public access: quarantine
resource "aws_s3_bucket_public_access_block" "data_lake_quarantine_privacy" {
  bucket = aws_s3_bucket.data_lake_quarantine.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket: glue scripts (Python JARs)
resource "aws_s3_bucket" "glue_scripts" {
    bucket = "spark-porto-glue-scripts"
}

# Public access: glue scripts
resource "aws_s3_bucket_public_access_block" "glue_scripts_privacy" {
  bucket = aws_s3_bucket.glue_scripts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket: Athena query results
resource "aws_s3_bucket" "athena_results" {
    bucket = "${local.bucket_prefix}-athena-results"
}

# Public access: Athena results
resource "aws_s3_bucket_public_access_block" "athena_results_privacy" {
  bucket = aws_s3_bucket.athena_results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# Bucket: Athena data (source tables)
resource "aws_s3_bucket" "athena_data" {
    bucket = "${local.bucket_prefix}-athena-data"
}

# Public access: Athena data
resource "aws_s3_bucket_public_access_block" "athena_data_privacy" {
  bucket = aws_s3_bucket.athena_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
