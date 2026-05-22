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