provider "aws" {
  region = var.aws_region
}

module "mod_opensearch_index_slow_log" {
  source = "../../modules/cloudwatch/log-groups"

  log_group_name              = var.cloudwatch.opensearch.index_slow_log_group
  log_group_retention_in_days = var.cloudwatch.log_retention_days
}

module "mod_opensearch_search_slow_log" {
  source = "../../modules/cloudwatch/log-groups"

  log_group_name              = var.cloudwatch.opensearch.search_slow_log_group
  log_group_retention_in_days = var.cloudwatch.log_retention_days
}

resource "aws_cloudwatch_log_resource_policy" "opensearch_logs" {
  policy_name = var.cloudwatch.resource_policy_name

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "es.amazonaws.com"
      }
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "*"
    }]
  })
}

module "mod_opensearch_domain" {
  source = "../../modules/opensearch"

  os_domain_name = var.opensearch.domain_name

  instance_type            = var.opensearch.cluster.instance_type
  node_count               = var.opensearch.cluster.node_count
  dedicated_master_enabled = var.opensearch.cluster.dedicated_master_enabled
  dedicated_master_count   = var.opensearch.cluster.dedicated_master_count
  dedicated_master_type    = var.opensearch.cluster.dedicated_master_type

  opensearch_subnet_ids = var.opensearch.network.subnet_ids
  opensearch_sg_ids     = var.opensearch.network.sg_ids

  opensearch_ebs_type = var.opensearch.storage.ebs_type
  opensearch_ebs_size = var.opensearch.storage.ebs_size

  # FGAC
  enable_fgac        = var.opensearch.security.enable_fgac
  node_to_node_encryption_enabled = var.opensearch.security.node_to_node_encrypted
  os_master_username = var.opensearch.security.master_user.username
  os_master_password = var.opensearch.security.master_user.password

  allowed_iam_principals = var.opensearch.security.allowed_iam_principals

  logs_group_arn_index_slow_logs  = module.mod_opensearch_index_slow_log.log_group_arn
  logs_group_arn_search_slow_logs = module.mod_opensearch_search_slow_log.log_group_arn
}
