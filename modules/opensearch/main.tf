#Create password
resource "random_password" "password"{
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "password" {
  name = "${var.name}-opensearch-password"
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
  }
  node_to_node_encryption {
    enabled = true
  }
  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }
  tags = var.tags
}