locals {
  resource_prefix = "${var.project_name}-${var.environment}"
}

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

resource "aws_s3_bucket" "state_lock" {
    bucket = "${local.resource_prefix}-state-lock"

    lifecycle {
      prevent_destroy = true
    }
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.state_lock.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "data_lake_bronze" {
    bucket = "${local.resource_prefix}-data-lake-bronze"

    lifecycle {
      prevent_destroy = true
    }
}

resource "aws_s3_bucket_public_access_block" "data_lake_bronze_privacy" {
  bucket = aws_s3_bucket.data_lake_bronze.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "data_lake_silver" {
    bucket = "${local.resource_prefix}-data-lake-silver"

    lifecycle {
      prevent_destroy = true
    }
}

resource "aws_s3_bucket_public_access_block" "data_lake_silver_privacy" {
  bucket = aws_s3_bucket.data_lake_silver.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "data_lake_gold" {
    bucket = "${local.resource_prefix}-data-lake-gold"

    lifecycle {
      prevent_destroy = true
    }
}

resource "aws_s3_bucket_public_access_block" "data_lake_gold_privacy" {
  bucket = aws_s3_bucket.data_lake_gold.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "data_lake_quarantine" {
    bucket = "${local.resource_prefix}-data-lake-quarantine"

    lifecycle {
      prevent_destroy = true
    }
}

resource "aws_s3_bucket_public_access_block" "data_lake_quarantine_privacy" {
  bucket = aws_s3_bucket.data_lake_quarantine.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}