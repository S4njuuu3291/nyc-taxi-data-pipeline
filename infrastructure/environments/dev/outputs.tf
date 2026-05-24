output "state_lock_bucket_id" {
    description = "Nama bucket untuk state locking"
    value = module.base.state_lock_bucket_id
}

output "state_lock_bucket_arn" {
    description = "ARN bucket untuk state locking"
    value = module.base.state_lock_bucket_arn
}