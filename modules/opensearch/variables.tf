

variable "os_domain_name" {
  description = "Name of OpenSearch Domain"
  type        = string
}
variable "instance_type" {
  description = "Data Node Instance Type of OS Domain"
  type        = string
}
variable "node_count" {
  description = "Number of Data Nodes for Opensearch"
  type        = number
}
variable "dedicated_master_enabled" {
  description = "Enable dedicated master node or not"
  type        = bool
  default = true
}

variable "dedicated_master_type" {
  description = "Dedicated master instance type"
  type        = string
  default = true
}

variable "dedicated_master_count" {
  description = "Number of dedicated master nodes (must be 3 for production)"
  type        = number
  default     = 3
}

variable "opensearch_subnet_ids" {
  description = "List of subnet IDs for OpenSearch VPC deployment"
  type        = list(string)
}

variable "opensearch_sg_ids" {
  description = "Security group ID for OpenSearch domain"
  type        = list(string)
}

variable "opensearch_ebs_type" {
  description = "Volume type of EBS for opensearch"
  type        = string
  default = "gp3"
}

variable "opensearch_ebs_size" {
  description = "EBS Volume size for opensearch"
  type        = string
}

variable "snapshot_hour" {
  description = "Hour for automated daily snapshot (0-23 UTC)"
  type        = number
  default     = 3
}

variable "logs_group_arn_index_slow_logs" {
  description = "Log group arn for index slow logs"
  type        = string
}

variable "logs_group_arn_search_slow_logs" {
  description = "Log group arn for search slow logs"
  type        =  string
}

variable "tags" {
  description = "Common tags to apply to OpenSearch resources"
  type        = map(string)
  default     = {}
}
