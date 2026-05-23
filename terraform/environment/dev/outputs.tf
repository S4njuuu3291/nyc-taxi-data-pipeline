output "state_lock_bucket_id" {
  description = "Nama bucket untuk state locking"
  value       = module.base.state_lock_bucket_id
}

output "state_lock_bucket_arn" {
  description = "ARN bucket untuk state locking"
  value       = module.base.state_lock_bucket_arn
}

output "bronze_bucket_id" {
  description = "Nama bucket data lake bronze"
  value       = module.base.bronze_bucket_id
}

output "bronze_bucket_arn" {
  description = "ARN bucket data lake bronze"
  value       = module.base.bronze_bucket_arn
}

output "silver_bucket_id" {
  description = "Nama bucket data lake silver"
  value       = module.base.silver_bucket_id
}

output "silver_bucket_arn" {
  description = "ARN bucket data lake silver"
  value       = module.base.silver_bucket_arn
}

output "gold_bucket_id" {
  description = "Nama bucket data lake gold"
  value       = module.base.gold_bucket_id
}

output "gold_bucket_arn" {
  description = "ARN bucket data lake gold"
  value       = module.base.gold_bucket_arn
}

output "quarantine_bucket_id" {
  description = "Nama bucket data lake quarantine"
  value       = module.base.quarantine_bucket_id
}

output "quarantine_bucket_arn" {
  description = "ARN bucket data lake quarantine"
  value       = module.base.quarantine_bucket_arn
}

output "glue_scripts_bucket_id" {
  description = "Nama bucket untuk glue scripts"
  value       = module.base.glue_scripts_bucket_id
}

output "glue_scripts_bucket_arn" {
  description = "ARN bucket untuk glue scripts"
  value       = module.base.glue_scripts_bucket_arn
}

output "glue_role_arn" {
  description = "ARN IAM role untuk Glue job"
  value       = module.base.glue_role_arn
}

output "glue_role_name" {
  description = "Nama IAM role untuk Glue job"
  value       = module.base.glue_role_name
}

output "glue_job_name" {
  description = "Nama Glue job transform"
  value       = module.base.glue_job_name
}

output "glue_job_arn" {
  description = "ARN Glue job transform"
  value       = module.base.glue_job_arn
}

output "athena_results_bucket_id" {
  description = "Nama bucket untuk Athena query results"
  value       = module.base.athena_results_bucket_id
}

output "athena_results_bucket_arn" {
  description = "ARN bucket untuk Athena query results"
  value       = module.base.athena_results_bucket_arn
}
output "athena_data_bucket_id" {
  description = "Nama bucket untuk Athena data source tables"
  value       = module.base.athena_data_bucket_id
}

output "athena_data_bucket_arn" {
  description = "ARN bucket untuk Athena data source tables"
  value       = module.base.athena_data_bucket_arn
}

output "aws_glue_catalog_database_name" {
  description = "Nama Glue Catalog Database untuk Data Lake"
  value       = module.base.aws_glue_catalog_database_name
}

output "aws_glue_catalog_database_arn" {
  description = "ARN Glue Catalog Database untuk Data Lake"
  value       = module.base.aws_glue_catalog_database_arn
}