variable "environment" {
    type        = string
    description = "Deployment environment, must be either dev or prod"

    validation {
        condition     = contains(["dev", "prod"], var.environment)
        error_message = "environment must be either dev or prod"
    }
}