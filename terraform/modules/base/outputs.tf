output "state_lock_bucket_id" {
  description = "Nama bucket untuk state locking"
  value       = aws_s3_bucket.state_lock.id
}

output "state_lock_bucket_arn" {
  description = "ARN bucket untuk state locking"
  value       = aws_s3_bucket.state_lock.arn
}

output "bronze_bucket_id" {
  description = "Nama bucket data lake bronze"
  value       = aws_s3_bucket.data_lake_bronze.id
}

output "bronze_bucket_arn" {
  description = "ARN bucket data lake bronze"
  value       = aws_s3_bucket.data_lake_bronze.arn
}

output "silver_bucket_id" {
  description = "Nama bucket data lake silver"
  value       = aws_s3_bucket.data_lake_silver.id
}

output "silver_bucket_arn" {
  description = "ARN bucket data lake silver"
  value       = aws_s3_bucket.data_lake_silver.arn
}

output "gold_bucket_id" {
  description = "Nama bucket data lake gold"
  value       = aws_s3_bucket.data_lake_gold.id
}

output "gold_bucket_arn" {
  description = "ARN bucket data lake gold"
  value       = aws_s3_bucket.data_lake_gold.arn
}

output "quarantine_bucket_id" {
  description = "Nama bucket data lake quarantine"
  value       = aws_s3_bucket.data_lake_quarantine.id
}

output "quarantine_bucket_arn" {
  description = "ARN bucket data lake quarantine"
  value       = aws_s3_bucket.data_lake_quarantine.arn
}

output "glue_scripts_bucket_id" {
  description = "Nama bucket untuk glue scripts"
  value       = aws_s3_bucket.glue_scripts.id
}

output "glue_scripts_bucket_arn" {
  description = "ARN bucket untuk glue scripts"
  value       = aws_s3_bucket.glue_scripts.arn
}

output "glue_role_arn" {
  description = "ARN IAM role untuk Glue job"
  value       = aws_iam_role.glue_service_role.arn
}

output "glue_role_name" {
  description = "Nama IAM role untuk Glue job"
  value       = aws_iam_role.glue_service_role.name
}

output "glue_job_name" {
  description = "Nama Glue job transform"
  value       = aws_glue_job.etl_job_transform.name
}

output "glue_job_arn" {
  description = "ARN Glue job transform"
  value       = aws_glue_job.etl_job_transform.arn
}

output "athena_results_bucket_id" {
  description = "Nama bucket untuk Athena query results"
  value       = aws_s3_bucket.athena_results.id
}

output "athena_results_bucket_arn" {
  description = "ARN bucket untuk Athena query results"
  value       = aws_s3_bucket.athena_results.arn
}
output "athena_data_bucket_id" {
  description = "Nama bucket untuk Athena data source tables"
  value       = aws_s3_bucket.athena_data.id
}

output "athena_data_bucket_arn" {
  description = "ARN bucket untuk Athena data source tables"
  value       = aws_s3_bucket.athena_data.arn
}

output "aws_glue_catalog_database_name" {
  description = "Nama Glue catalog database untuk metadata tables"
  value       = aws_glue_catalog_database.data_lake_db.name
}

output "aws_glue_catalog_database_arn" {
  description = "ARN Glue catalog database untuk metadata tables"
  value       = aws_glue_catalog_database.data_lake_db.arn
}