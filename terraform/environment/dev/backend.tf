terraform {
    backend "s3" {
        bucket         = "spark-porto-dev-state-lock"
        key            = "spark-porto-dev/terraform.tfstate"
        region         = "ap-southeast-1"
        encrypt        = true
        use_lockfile = true
    }
}