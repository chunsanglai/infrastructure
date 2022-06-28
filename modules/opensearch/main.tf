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
  name = "${var.domain_name}-opensearch-password"
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
}
# OpenSearch domain
resource "aws_elasticsearch_domain" "opensearch" {
  domain_name           = var.domain_name
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
    security_group_ids = [aws_security_group.management-security-group.id,aws_security_group.elasticsearch-security-group.id]
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

resource "aws_security_group" "management-security-group" {
  name   = join("-", [var.domain_name, "management-security-group"])
  vpc_id = var.vpc_id
  dynamic "ingress" {
    for_each = var.management_ingress_rules
    content {
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = [ingress.value["cidr_block"]]
      description = ingress.value["description"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "internal-security-group" {
  name   = join("-", [var.domain_name, "internal-security-group"])
  vpc_id = var.vpc_id
  dynamic "ingress" {
    for_each = var.internal_ingress_rules
    content {
      from_port       = ingress.value["from_port"]
      to_port         = ingress.value["to_port"]
      protocol        = ingress.value["protocol"]
      security_groups = ingress.value["security_groups"]
      description     = ingress.value["description"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_service_linked_role" "es" {
  count = var.create_iam_service_linked_role == "true" ? 1 : 0
  aws_service_name = "es.amazonaws.com"
}

resource "aws_cloudwatch_log_group" "opensearch" {
  name = "${var.domain_name}-opensearch"
}

resource "aws_cloudwatch_log_resource_policy" "opensearch" {
  policy_name = "${var.domain_name}-opensearch"

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
