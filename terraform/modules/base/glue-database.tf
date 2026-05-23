resource "aws_glue_catalog_database" "data_lake_db" {
  name = "${local.resource_prefix}_data_lake_db"
  description = "Glue Catalog Database untuk Data Lake ${var.project_name}"
  parameters = {
    "created_by" = "Terraform"
    "project"    = var.project_name
  }
}

# === LAKE FORMATION DATA LAKE SETTINGS ===
# Jadikan user Terraform + Glue Role sebagai Lake Formation admin
data "aws_iam_user" "terraform_user" {
  user_name = "spark-porto-iamuser"
}

resource "aws_lakeformation_data_lake_settings" "main" {
  admins = [
    data.aws_iam_user.terraform_user.arn,
    aws_iam_role.glue_service_role.arn,
  ]

  create_database_default_permissions {
    principal   = "IAM_ALLOWED_PRINCIPALS"
    permissions = ["ALL"]
  }

  create_table_default_permissions {
    principal   = "IAM_ALLOWED_PRINCIPALS"
    permissions = ["ALL"]
  }
}

# === GRANT KE GLUE ROLE ===
# Grant DESCRIBE on 'default' database
resource "aws_lakeformation_permissions" "glue_default_db" {
  principal   = aws_iam_role.glue_service_role.arn
  permissions = ["DESCRIBE"]

  database { name = "default" }
}

# Grant ALL on own database
resource "aws_lakeformation_permissions" "glue_own_db" {
  principal   = aws_iam_role.glue_service_role.arn
  permissions = ["ALL", "ALTER", "CREATE_TABLE", "DESCRIBE", "DROP"]

  database { name = aws_glue_catalog_database.data_lake_db.name }
}

# Register S3 locations ke Lake Formation
resource "aws_lakeformation_resource" "silver_location" {
  arn = aws_s3_bucket.data_lake_silver.arn
}

resource "aws_lakeformation_resource" "quarantine_location" {
  arn = aws_s3_bucket.data_lake_quarantine.arn
}

# Grant DATA_LOCATION_ACCESS
resource "aws_lakeformation_permissions" "glue_silver_location" {
  principal   = aws_iam_role.glue_service_role.arn
  permissions = ["DATA_LOCATION_ACCESS"]

  data_location { arn = aws_lakeformation_resource.silver_location.arn }
}

resource "aws_lakeformation_permissions" "glue_quarantine_location" {
  principal   = aws_iam_role.glue_service_role.arn
  permissions = ["DATA_LOCATION_ACCESS"]

  data_location { arn = aws_lakeformation_resource.quarantine_location.arn }
}