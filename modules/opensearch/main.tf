/**
 * OpenSearch module
 * - Dedicated master nodes
 * - Multi-AZ deployment
 * - Encrypted at rest
 */

resource "aws_opensearch_domain" "this" {
  domain_name = var.os_domain_name


  cluster_config {
    instance_type            = var.instance_type
    instance_count           = var.node_count
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_count   = var.dedicated_master_count
    dedicated_master_type    = var.dedicated_master_type
    zone_awareness_enabled   = true
    zone_awareness_config {
      availability_zone_count = 3
    }
  }

  vpc_options {
    subnet_ids         = var.opensearch_subnet_ids
    security_group_ids = var.opensearch_sg_ids
  }


  ebs_options {
    ebs_enabled = true
    volume_type = var.opensearch_ebs_type # general purpose SSD
    volume_size = var.opensearch_ebs_size # size in GB, minimum 10 GB
  }

  encrypt_at_rest {
    enabled = true
  }
  snapshot_options {
    automated_snapshot_start_hour = var.snapshot_hour
  }

  log_publishing_options {
    log_type                 = "INDEX_SLOW_LOGS"
    cloudwatch_log_group_arn = var.logs_group_arn_index_slow_logs
    enabled                  = true
  }

  log_publishing_options {
    log_type                 = "SEARCH_SLOW_LOGS"
    cloudwatch_log_group_arn = var.logs_group_arn_search_slow_logs
    enabled                  = true
  }

  tags = var.tags
}
