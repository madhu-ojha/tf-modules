/**
 * One-time bootstrap project
 * Creates Terraform backend resources
 */

locals {
  region = "ap-northeast-1"
  backend_bucket = "terraform-state-osm-prod"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = local.backend_bucket
  region =  local.region

  tags = {
    Purpose = "terraform-backend"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.terraform_state.id
  region =  local.region

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.terraform_state.id
  region =  local.region

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
