#Create password
resource "random_password" "password"{
  length           = 16
  special          = true
  numeric          = true
  upper            = true
  lower            = true
  min_lower = 2
  min_numeric = 2
  min_special = 2
  min_upper = 2
}

resource "aws_secretsmanager_secret" "password" {
  name = "${var.domain}-opensearch-password"
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id     = aws_secretsmanager_secret.password.id
  secret_string = <<EOF
   {
    "username": "root",
    "password": "${random_password.password.result}"
   }
EOF
}
#Import password
data "aws_secretsmanager_secret" "password" {
  arn = aws_secretsmanager_secret.password.arn
}
data "aws_secretsmanager_secret_version" "credentials" {
  secret_id = data.aws_secretsmanager_secret.password.arn
}
locals {
  creds = jsondecode(data.aws_secretsmanager_secret_version.credentials.secret_string)
}# OpenSearch domain
resource "aws_elasticsearch_domain" "opensearch" {
  domain_name           = var.domain
  elasticsearch_version = var.opensearch_version

  cluster_config {
    instance_type  = var.instance_type
    instance_count = var.instance_count
  }
  ebs_options {
    ebs_enabled = true
    volume_type = var.volume_type
    volume_size = var.volume_size
  }
  vpc_options {
    subnet_ids = var.subnet_ids
    security_group_ids = var.allowed_security_groups
  }
  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = local.creds.username 
      master_user_password = local.creds.password
    }
  }
  encrypt_at_rest {
    enabled = true
    kms_key_id  = aws_kms_key.this.arn
  }
  node_to_node_encryption {
    enabled = true
  }
  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }
  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }
  tags = var.tags
}

resource "aws_iam_service_linked_role" "es" {
  custom_suffix = var.domain
  aws_service_name = "es.amazonaws.com"
}

resource "aws_cloudwatch_log_group" "opensearch" {
  name = "${var.domain}-opensearch"
}

resource "aws_cloudwatch_log_resource_policy" "opensearch" {
  policy_name = "${var.domain}-opensearch"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}
resource "aws_kms_key" "this" {
}
