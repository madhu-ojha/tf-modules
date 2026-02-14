variable "region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  type    = string
  default = "terraform-state-bucket"

}
variable "dynamodb_table_name" {
  type    = string
  default = "terraform-state-lock"

}