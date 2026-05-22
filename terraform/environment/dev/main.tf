locals {
  resource_prefix = "${var.project_name}-${var.environment}"
}

module "base" {
    source = "../../modules/base"

    environment = var.environment
    project_name = var.project_name
    aws_region = var.aws_region
}

