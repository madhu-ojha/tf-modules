/**
 * Terraform remote backend configuration
 * - Uses S3 for state storage
 * - Native state locking via S3
 * - DynamoDB NOT required
 */

terraform {
  backend "s3" {
    bucket  = "terraform-state-osm-prod"
    key     = "prod/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}
