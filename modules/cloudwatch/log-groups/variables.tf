variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
}

variable "log_group_retention_in_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 14
}
