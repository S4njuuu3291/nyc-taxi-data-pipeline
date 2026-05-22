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