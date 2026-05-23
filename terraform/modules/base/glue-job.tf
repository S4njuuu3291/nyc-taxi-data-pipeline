
# Glue Job Transform
resource "aws_glue_job" "etl_job_transform" {
  name              = "${local.resource_prefix}_job_transform"
  role_arn          = aws_iam_role.glue_service_role.arn
  glue_version      = var.glue_version
  worker_type       = var.worker_type
  number_of_workers = var.number_of_workers
  timeout           = var.timeout_minutes
  max_retries       = var.max_retries
  
  # Python version untuk script
  command {
    script_location = "s3://${aws_s3_bucket.glue_scripts.bucket}/transform.py"
    python_version  = "3"
    name            = "glueetl"  # Untuk Spark ETL job
  }
  
  # Konfigurasi default arguments
  default_arguments = {
    "--enable-auto-scaling"              = tostring(var.enable_auto_scaling)
    "--enable-continuous-cloudwatch-log" = tostring(var.enable_continuous_logging)
    "--enable-metrics"                   = tostring(var.enable_metrics)
    "--enable-job-insights"              = tostring(var.enable_job_insights)
    "--enable-glue-datacatalog"          = ""
    "--source_bucket"                    = aws_s3_bucket.data_lake_bronze.bucket
    "--silver_bucket"                    = aws_s3_bucket.data_lake_silver.bucket
    "--quarantine_bucket"                = aws_s3_bucket.data_lake_quarantine.bucket
  }
  
}