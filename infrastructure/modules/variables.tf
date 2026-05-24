variable "aws_region" {
    type        = string
    description = "AWS region where resources will be created"
    default = "ap-southeast-1"
}

variable "project_name" {
    type        = string
    description = "Project name used as part of resource naming"
    default = "spark-pipeline"
}

variable "environment" {
    type        = string
    description = "Deployment environment, must be either dev or prod"

    validation {
        condition     = contains(["dev", "prod"], var.environment)
        error_message = "environment must be either dev or prod"
    }
}