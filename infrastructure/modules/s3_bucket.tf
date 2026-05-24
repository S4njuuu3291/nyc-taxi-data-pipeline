# Bucket: state lock Terraform
resource "aws_s3_bucket" "state_lock" {
    bucket = "${local.resource_prefix}-state-lock"

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