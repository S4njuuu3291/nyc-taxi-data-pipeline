variable "aws_region" {
    type = string
    description = "Region Infrastruktur AWS yang dideploy"
    default = "ap-southeast-1" # singapore
}

variable "environment" {
    type = string
    description = "Environment terraform (hanya menerima dev, staging, prod)"

    # Validation production grade
    validation {
        condition = contains(["dev","staging","prod"],var.environment)
        error_message = "Variabel environment harus bernilai 'dev', 'staging', atau 'prod'"
    }
}

variable "project_name" {
    type = string
    description = "Nama project yang akan digunakan"
    default = "spark_porto"
}

variable "glue_version" {
  description = "Glue runtime version"
  type        = string
  default     = "5.0"
}

variable "worker_type" {
  description = "Worker type: G.1X, G.2X, Standard"
  type        = string
  default     = "G.1X"
}

variable "number_of_workers" {
  description = "Number of workers"
  type        = number
  default     = 2
}

variable "timeout_minutes" {
  description = "Job timeout in minutes"
  type        = number
  default     = 10
}

variable "max_retries" {
  description = "Maximum number of retries"
  type        = number
  default     = 0
}

variable "enable_auto_scaling" {
  description = "Enable Glue auto-scaling"
  type        = bool
  default     = true
}

variable "enable_continuous_logging" {
  description = "Enable CloudWatch continuous logging"
  type        = bool
  default     = true
}

variable "enable_metrics" {
  description = "Enable CloudWatch metrics"
  type        = bool
  default     = false
}

variable "enable_job_insights" {
  description = "Enable job insights for debugging"
  type        = bool
  default     = true
}