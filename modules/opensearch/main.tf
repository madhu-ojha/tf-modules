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
    zone_awareness_enabled   = var.zone_awareness_config_enabled
    zone_awareness_config {
      availability_zone_count = var.availability_zone_count
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

  node_to_node_encryption {
    enabled = var.node_to_node_encryption_enabled
  }

  domain_endpoint_options {
    enforce_https = var.enforce_https
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }
  
  advanced_security_options {
    enabled                        = var.enable_fgac
    internal_user_database_enabled = var.enable_fgac

    # Only set master user if FGAC is enabled
    dynamic "master_user_options" {
      for_each = var.enable_fgac ? [1] : []
      content {
        master_user_name     = var.os_master_username
        master_user_password = var.os_master_password
      }
    }
  }
  encrypt_at_rest {
    enabled = true
  }
  snapshot_options {
    automated_snapshot_start_hour = var.snapshot_hour
  }

  log_publishing_options {
    log_type                  = "INDEX_SLOW_LOGS"
    cloudwatch_log_group_arn = var.logs_group_arn_index_slow_logs
    enabled                   = true
  }

  log_publishing_options {
    log_type                  = "SEARCH_SLOW_LOGS"
    cloudwatch_log_group_arn = var.logs_group_arn_search_slow_logs
    enabled                   = true
  }

  tags = var.tags
}


resource "aws_opensearch_domain_policy" "this" {
  domain_name = aws_opensearch_domain.this.domain_name

  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_iam_principals
        }
        Action   = "es:*"
        Resource = "${aws_opensearch_domain.this.arn}/*"
      }
    ]
  })
}
