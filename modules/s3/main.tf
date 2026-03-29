resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = merge(
    {
      Environment = var.environment
      Purpose     = var.purpose
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }

    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "this" {
  count         = var.enable_access_logging ? 1 : 0
  bucket        = aws_s3_bucket.this.id
  target_bucket = var.access_logging_target_bucket
  target_prefix = var.access_logging_target_prefix
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = var.enable_lifecycle_rules ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "cleanup-failed-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = var.abort_incomplete_multipart_upload_days
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "this" {
  count  = var.enable_cors && var.cors_config != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  cors_rule {
    allowed_headers = var.cors_config.allowed_headers
    allowed_methods = var.cors_config.allowed_methods
    allowed_origins = var.cors_config.allowed_origins
    expose_headers  = var.cors_config.expose_headers
    max_age_seconds = var.cors_config.max_age_seconds
  }
}
