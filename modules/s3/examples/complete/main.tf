terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

module "s3" {
  source = "../../"

  bucket_name        = "ms-example-complete-bucket"
  environment        = "dev"
  purpose            = "Static website assets"
  versioning_enabled = true

  enable_lifecycle_rules                 = true
  abort_incomplete_multipart_upload_days = 14

  enable_cors = true
  cors_config = {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["https://app.messagespring.com"]
    expose_headers  = ["ETag", "x-amz-meta-custom-header"]
    max_age_seconds = 3600
  }

  enable_access_logging        = true
  access_logging_target_bucket = "ms-example-logging-bucket"
  access_logging_target_prefix = "s3-access-logs/"

  tags = {
    Team    = "platform"
    Service = "web-assets"
  }
}

output "bucket_id" {
  value = module.s3.bucket_id
}

output "bucket_arn" {
  value = module.s3.bucket_arn
}

output "bucket_domain_name" {
  value = module.s3.bucket_domain_name
}

output "bucket_regional_domain_name" {
  value = module.s3.bucket_regional_domain_name
}
