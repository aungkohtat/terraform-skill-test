# Terraform S3 Module — Skill Test

A production-grade S3 bucket Terraform module with native testing and CI/CD pipeline. Built to validate the [terraform-skill](https://github.com/antonbabenko/terraform-skill) patterns.

## Project Structure

```
.
├── .github/workflows/
│   └── terraform-s3-module.yml     # CI pipeline (5 stages)
├── .pre-commit-config.yaml         # Pre-commit hooks
└── modules/s3/
    ├── main.tf                     # S3 resources (7 resources)
    ├── variables.tf                # 12 input variables with validations
    ├── outputs.tf                  # 4 outputs
    ├── versions.tf                 # Terraform >= 1.6, AWS >= 5.0
    ├── tests/
    │   ├── unit.tftest.hcl         # 14 mocked unit tests (free)
    │   └── integration.tftest.hcl  # 3 real AWS integration tests
    └── examples/
        ├── minimal/main.tf         # Minimum viable usage
        └── complete/main.tf        # All features enabled
```

## Module Features

| Feature | Default | Description |
|---------|---------|-------------|
| AES256 Encryption | Always on | Server-side encryption with bucket key |
| Public Access Block | Always on | All 4 public access settings blocked |
| Versioning | Enabled | Toggle via `versioning_enabled` |
| Lifecycle Rules | Enabled | Aborts incomplete multipart uploads |
| Access Logging | Disabled | Enable with target bucket config |
| CORS | Disabled | Enable with full CORS config object |

## Quick Start

### Minimal Usage

```hcl
module "s3" {
  source = "./modules/s3"

  bucket_name = "my-app-bucket"
  environment = "dev"
}
```

### Full Usage

```hcl
module "s3" {
  source = "./modules/s3"

  bucket_name        = "my-app-assets"
  environment        = "prod"
  purpose            = "Static website assets"
  versioning_enabled = true

  enable_lifecycle_rules                 = true
  abort_incomplete_multipart_upload_days = 14

  enable_cors = true
  cors_config = {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["https://example.com"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }

  enable_access_logging        = true
  access_logging_target_bucket = "my-logging-bucket"
  access_logging_target_prefix = "s3-logs/"

  tags = {
    Team    = "platform"
    Service = "web-assets"
  }
}
```

## Testing

### Run Unit Tests (Mocked — Free)

```bash
cd modules/s3
terraform init -backend=false
terraform test -filter=tests/unit.tftest.hcl -verbose
```

**14 tests covering:**
- Bucket name passthrough
- Default and custom tag merging
- Versioning toggle (enabled/disabled)
- Public access block (all 4 settings)
- Lifecycle rules toggle
- Access logging toggle
- CORS toggle
- Encryption always present
- Custom purpose tag

### Run Integration Tests (Real AWS — Requires Credentials)

```bash
cd modules/s3
terraform init -backend=false
terraform test -filter=tests/integration.tftest.hcl -verbose
```

Tests create real S3 resources, verify outputs and encryption, then destroy.

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/terraform-s3-module.yml`) runs 5 stages:

| Stage | Trigger | Cost | What it does |
|-------|---------|------|--------------|
| Validate & Lint | All PRs + push | Free | `fmt`, `validate`, `tflint` |
| Security Scan | All PRs + push | Free | Trivy + Checkov |
| Unit Tests | All PRs + push | Free | 14 mocked tests |
| Integration Tests | Main branch only | Low | Real AWS resources |
| Cost Estimation | PRs only | Free | Infracost diff comment |

### Running Locally (No CI)

```bash
# Validate
terraform fmt -check -recursive
terraform validate

# Security scan
trivy config .
checkov -d . --framework terraform

# Unit tests
terraform test -filter=tests/unit.tftest.hcl

# All tests
terraform test
```

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.6.0 |
| AWS Provider | >= 5.0 |

## Attribution

This module was created following best practices from [terraform-skill](https://github.com/antonbabenko/terraform-skill) by Anton Babenko.

Additional resources:
- [terraform-best-practices.com](https://terraform-best-practices.com)
