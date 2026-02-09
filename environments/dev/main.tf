
provider "aws" {
  region = "ap-northeast-1"  
}


module "mod_opensearch_index_slow_log" {
  source = "../../modules/cloudwatch/log-groups"

  log_group_name              = "/aws/opensearch/dev-opensearch/index-slow"
  log_group_retention_in_days = 14
}

module "mod_opensearch_search_slow_log" {
  source = "../../modules/cloudwatch/log-groups"

  log_group_name              = "/aws/opensearch/dev-opensearch/search-slow"
  log_group_retention_in_days = 14
}

resource "aws_cloudwatch_log_resource_policy" "opensearch_logs" {
  policy_name = "AllowOpenSearchLogs"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "es.amazonaws.com"
        }
        Action   = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

module "mod_opensearch_domain" {
  source = "../../modules/opensearch"

  os_domain_name = "dev-opensearch"

  instance_type            = "r5.large.search"
  node_count               = 3
  dedicated_master_enabled = true
  dedicated_master_count   = 3
  dedicated_master_type    = "t3.small.search"

  opensearch_subnet_ids = [
    "subnet-0e5d49ba906d3edbd",
    "subnet-0f00006a31cd38197",
    "subnet-0ecb846ae194cb51a"
  ]

  opensearch_sg_ids = [
    "sg-0b684cd1e5998f4e1"
  ]

  opensearch_ebs_type = "gp3"
  opensearch_ebs_size = 10

  logs_group_arn_index_slow_logs = module.mod_opensearch_index_slow_log.log_group_arn
  logs_group_arn_search_slow_logs = module.mod_opensearch_search_slow_log.log_group_arn


}
