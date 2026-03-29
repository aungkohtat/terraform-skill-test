mock_provider "aws" {}

# -----------------------------------------------
# 1. Bucket name passthrough
# -----------------------------------------------
run "bucket_name_matches_input" {
  command = plan

  variables {
    bucket_name = "ms-test-bucket"
    environment = "dev"
  }

  assert {
    condition     = aws_s3_bucket.this.bucket == "ms-test-bucket"
    error_message = "Bucket name must match the input variable"
  }
}

# -----------------------------------------------
# 2. Default tags are applied
# -----------------------------------------------
run "default_tags_applied" {
  command = plan

  variables {
    bucket_name = "ms-test-bucket"
    environment = "dev"
  }

  assert {
    condition     = aws_s3_bucket.this.tags["Environment"] == "dev"
    error_message = "Environment tag must match the environment variable"
  }

  assert {
    condition     = aws_s3_bucket.this.tags["ManagedBy"] == "terraform"
    error_message = "ManagedBy tag must be set to terraform"
  }

  assert {
    condition     = aws_s3_bucket.this.tags["Purpose"] == "Application data"
    error_message = "Purpose tag must default to Application data"
  }
}

# -----------------------------------------------
# 3. Custom tags are merged
# -----------------------------------------------
run "custom_tags_merged" {
  command = plan

  variables {
    bucket_name = "ms-test-bucket"
    environment = "dev"
    tags = {
      Team = "platform"
    }
  }

  assert {
    condition     = aws_s3_bucket.this.tags["Team"] == "platform"
    error_message = "Custom tags must be merged into resource tags"
  }

  assert {
    condition     = aws_s3_bucket.this.tags["Environment"] == "dev"
    error_message = "Default tags must be preserved when custom tags are added"
  }
}

# -----------------------------------------------
# 4. Versioning enabled by default
# -----------------------------------------------
run "versioning_enabled_by_default" {
  command = plan

  variables {
    bucket_name = "ms-test-bucket"
    environment = "dev"
  }

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
    error_message = "Versioning must be enabled by default"
  }
}

# -----------------------------------------------
# 5. Versioning can be disabled
# -----------------------------------------------
run "versioning_can_be_disabled" {
  command = plan

  variables {
    bucket_name        = "ms-test-bucket"
    environment        = "dev"
    versioning_enabled = false
  }

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Disabled"
    error_message = "Versioning must be disabled when versioning_enabled is false"
  }
}

# -----------------------------------------------
# 6. Public access is always blocked
# -----------------------------------------------
run "public_access_blocked" {
  command = plan

  variables {
    bucket_name = "ms-test-bucket"
    environment = "dev"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_acls == true
    error_message = "block_public_acls must be true"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_policy == true
    error_message = "block_public_policy must be true"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.ignore_public_acls == true
    error_message = "ignore_public_acls must be true"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.restrict_public_buckets == true
    error_message = "restrict_public_buckets must be true"
  }
}

# -----------------------------------------------
# 7. Lifecycle rules enabled by default
# -----------------------------------------------
run "lifecycle_rules_enabled_by_default" {
  command = plan

  variables {
    bucket_name = "ms-test-bucket"
    environment = "dev"
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this) == 1
    error_message = "Lifecycle configuration must be created by default"
  }
}

# -----------------------------------------------
# 8. Lifecycle rules can be disabled
# -----------------------------------------------
run "lifecycle_rules_can_be_disabled" {
  command = plan

  variables {
    bucket_name            = "ms-test-bucket"
    environment            = "dev"
    enable_lifecycle_rules = false
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this) == 0
    error_message = "Lifecycle configuration must not be created when disabled"
  }
}

# -----------------------------------------------
# 9. Access logging disabled by default
# -----------------------------------------------
run "access_logging_disabled_by_default" {
  command = plan

  variables {
    bucket_name = "ms-test-bucket"
    environment = "dev"
  }

  assert {
    condition     = length(aws_s3_bucket_logging.this) == 0
    error_message = "Access logging must be disabled by default"
  }
}

# -----------------------------------------------
# 10. CORS disabled by default
# -----------------------------------------------
run "cors_disabled_by_default" {
  command = plan

  variables {
    bucket_name = "ms-test-bucket"
    environment = "dev"
  }

  assert {
    condition     = length(aws_s3_bucket_cors_configuration.this) == 0
    error_message = "CORS must be disabled by default"
  }
}

# -----------------------------------------------
# 11. Custom purpose tag
# -----------------------------------------------
run "custom_purpose_tag" {
  command = plan

  variables {
    bucket_name = "ms-test-bucket"
    environment = "prod"
    purpose     = "Static assets"
  }

  assert {
    condition     = aws_s3_bucket.this.tags["Purpose"] == "Static assets"
    error_message = "Purpose tag must match the input variable"
  }
}

# -----------------------------------------------
# 12. Encryption always configured (apply for set access)
# -----------------------------------------------
run "encryption_always_configured" {
  command = apply

  variables {
    bucket_name = "ms-test-bucket"
    environment = "dev"
  }

  assert {
    condition     = aws_s3_bucket_server_side_encryption_configuration.this != null
    error_message = "Server-side encryption must always be configured"
  }
}

# -----------------------------------------------
# 13. CORS can be enabled with config
# -----------------------------------------------
run "cors_enabled_with_config" {
  command = plan

  variables {
    bucket_name = "ms-test-cors"
    environment = "dev"
    enable_cors = true
    cors_config = {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT"]
      allowed_origins = ["https://example.com"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3600
    }
  }

  assert {
    condition     = length(aws_s3_bucket_cors_configuration.this) == 1
    error_message = "CORS must be created when enabled with config"
  }
}

# -----------------------------------------------
# 14. Access logging can be enabled
# -----------------------------------------------
run "access_logging_can_be_enabled" {
  command = plan

  variables {
    bucket_name                  = "ms-test-logging"
    environment                  = "dev"
    enable_access_logging        = true
    access_logging_target_bucket = "ms-logging-target"
    access_logging_target_prefix = "logs/"
  }

  assert {
    condition     = length(aws_s3_bucket_logging.this) == 1
    error_message = "Access logging must be created when enabled"
  }
}
