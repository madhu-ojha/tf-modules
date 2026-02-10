variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "cloudwatch" {
  type = object({
    log_retention_days   = number
    resource_policy_name = string
    opensearch = object({
      index_slow_log_group  = string
      search_slow_log_group = string
    })
  })
}

variable "opensearch" {
  type = object({
    domain_name = string

    cluster = object({
      instance_type            = string
      node_count               = number
      dedicated_master_enabled = bool
      dedicated_master_count   = number
      dedicated_master_type    = string
    })

    network = object({
      subnet_ids = list(string)
      sg_ids     = list(string)
    })

    storage = object({
      ebs_type = string
      ebs_size = number
    })

    security = object({
      allowed_iam_principals = list(string)

      # New fields for FGAC
      enable_fgac            = bool
      node_to_node_encrypted = bool
      enforce_https          = bool
      master_user = object({
        username = string
        password = string
      })
    })
  })
}
