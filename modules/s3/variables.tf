variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be 3-63 characters, lowercase alphanumeric, dots, and hyphens."
  }
}

variable "environment" {
  description = "Environment identifier for resource tagging"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, qa, staging, prod, test."
  }
}

variable "purpose" {
  description = "Purpose of the bucket for tagging"
  type        = string
  default     = "Application data"
}

variable "versioning_enabled" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = true
}

variable "enable_cors" {
  description = "Enable CORS configuration"
  type        = bool
  default     = false
}

variable "cors_config" {
  description = "CORS configuration for the bucket"
  type = object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  })
  default = null
}

variable "enable_lifecycle_rules" {
  description = "Enable lifecycle rules for the bucket"
  type        = bool
  default     = true
}

variable "abort_incomplete_multipart_upload_days" {
  description = "Days after which to abort incomplete multipart uploads"
  type        = number
  default     = 7

  validation {
    condition     = var.abort_incomplete_multipart_upload_days >= 1 && var.abort_incomplete_multipart_upload_days <= 365
    error_message = "Abort incomplete multipart upload days must be between 1 and 365."
  }
}

variable "enable_access_logging" {
  description = "Enable S3 server access logging"
  type        = bool
  default     = false
}

variable "access_logging_target_bucket" {
  description = "Target S3 bucket for server access logging"
  type        = string
  default     = null
}

variable "access_logging_target_prefix" {
  description = "Prefix for access log objects in the target bucket"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
