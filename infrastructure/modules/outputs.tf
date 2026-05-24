output "state_lock_bucket_id" {
  value = aws_s3_bucket.state_lock.id
}

output "state_lock_bucket_arn" {
  value = aws_s3_bucket.state_lock.arn
}