# -----------------------------------------------
# Integration tests — deploy real AWS resources
# Run only on main branch or manually
# Requires AWS credentials
# -----------------------------------------------

variables {
  bucket_name = "ms-integration-test-s3-module"
  environment = "test"
  purpose     = "Integration testing"
  tags = {
    TTL       = "2h"
    ManagedBy = "terraform-test"
  }
}

# -----------------------------------------------
# 1. Create bucket and verify outputs
# -----------------------------------------------
run "create_bucket" {
  command = apply

  assert {
    condition     = output.bucket_id == "ms-integration-test-s3-module"
    error_message = "Bucket ID must match the input name"
  }

  assert {
    condition     = length(output.bucket_arn) > 0
    error_message = "Bucket ARN must not be empty"
  }

  assert {
    condition     = can(regex("^arn:aws:s3:::", output.bucket_arn))
    error_message = "Bucket ARN must be a valid S3 ARN"
  }

  assert {
    condition     = length(output.bucket_domain_name) > 0
    error_message = "Bucket domain name must not be empty"
  }

  assert {
    condition     = length(output.bucket_regional_domain_name) > 0
    error_message = "Bucket regional domain name must not be empty"
  }
}

# -----------------------------------------------
# 2. Verify encryption algorithm
# -----------------------------------------------
run "verify_encryption" {
  command = apply

  assert {
    condition = alltrue([
      for rule in aws_s3_bucket_server_side_encryption_configuration.this.rule :
      alltrue([
        for config in rule.apply_server_side_encryption_by_default :
        config.sse_algorithm == "AES256"
      ])
    ])
    error_message = "Encryption must use AES256"
  }
}

# -----------------------------------------------
# 3. Verify all public access blocked
# -----------------------------------------------
run "verify_public_access_blocked" {
  command = apply

  assert {
    condition = alltrue([
      aws_s3_bucket_public_access_block.this.block_public_acls,
      aws_s3_bucket_public_access_block.this.block_public_policy,
      aws_s3_bucket_public_access_block.this.ignore_public_acls,
      aws_s3_bucket_public_access_block.this.restrict_public_buckets,
    ])
    error_message = "All public access block settings must be true"
  }
}
