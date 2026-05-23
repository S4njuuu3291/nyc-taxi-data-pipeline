# IAM Role: Glue ETL service
resource "aws_iam_role" "glue_service_role" {
  name = "${var.project_name}_glue_role"
  description = "IAM role untuk Glue ETL job transform"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Policy: akses S3 data lake + glue scripts
resource "aws_iam_policy" "glue_s3_policy" {
  name        = "${var.project_name}_glue_s3_policy"
  description = "Policy untuk Glue akses S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
        ]
        Resource = [
          aws_s3_bucket.data_lake_bronze.arn,
          "${aws_s3_bucket.data_lake_bronze.arn}/*",
          aws_s3_bucket.data_lake_silver.arn,
          "${aws_s3_bucket.data_lake_silver.arn}/*",
          aws_s3_bucket.data_lake_gold.arn,
          "${aws_s3_bucket.data_lake_gold.arn}/*",
          aws_s3_bucket.data_lake_quarantine.arn,
          "${aws_s3_bucket.data_lake_quarantine.arn}/*",
          aws_s3_bucket.glue_scripts.arn,
          "${aws_s3_bucket.glue_scripts.arn}/*",
          aws_s3_bucket.athena_data.arn,
          "${aws_s3_bucket.athena_data.arn}/*",
          aws_s3_bucket.athena_results.arn,
          "${aws_s3_bucket.athena_results.arn}/*",
        ]
      }
    ]
  })
}

# Policy: CloudWatch logs
resource "aws_iam_policy" "glue_cloudwatch_policy" {
  name        = "${var.project_name}_glue_cloudwatch_policy"
  description = "Policy untuk Glue CloudWatch logging"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:AssociateKmsKey",
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach policies ke role
resource "aws_iam_role_policy_attachment" "glue_s3_attach" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = aws_iam_policy.glue_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "glue_cloudwatch_attach" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = aws_iam_policy.glue_cloudwatch_policy.arn
}

# Policy: Glue Catalog access (create/read/update tables)
resource "aws_iam_policy" "glue_catalog_policy" {
  name        = "${var.project_name}_glue_catalog_policy"
  description = "Policy untuk Glue akses Glue Catalog (database & tables)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:CreateTable",
          "glue:GetTable",
          "glue:GetTables",
          "glue:UpdateTable",
          "glue:DeleteTable",
          "glue:BatchCreatePartition",
          "glue:GetPartitions",
          "glue:GetPartition",
        ]
        Resource = [
          "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:catalog",
          "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:database/${aws_glue_catalog_database.data_lake_db.name}",
          "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${aws_glue_catalog_database.data_lake_db.name}/*",
        ]
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy_attachment" "glue_catalog_attach" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = aws_iam_policy.glue_catalog_policy.arn
}

# Managed policy bawaan AWS untuk Glue
resource "aws_iam_role_policy_attachment" "glue_service_attach" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}