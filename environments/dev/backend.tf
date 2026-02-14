/**
 * Dev environment specific backend configuration
 * Uses local state for CI/CD validation
 */

terraform {
  backend "s3" {
    bucket  = "terraform-state-osm-dev"
    key     = "dev/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}
