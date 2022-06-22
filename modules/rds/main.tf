resource "random_password" "password"{
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "password" {
  name = "${var.name}-db-password"
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

data "aws_secretsmanager_secret" "password" {
  arn = aws_secretsmanager_secret.password.arn
}
data "aws_secretsmanager_secret_version" "credentials" {
  secret_id = data.aws_secretsmanager_secret.password.arn
}
locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.credentials.secret_string)
}

module "rds-aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 7.2.0"
  name = var.name
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class 
  instances = {
    1 = {}
  }

  storage_encrypted = true

  vpc_id                = var.vpc_id
  allowed_cidr_blocks   = var.allowed_cidr_blocks
  create_db_subnet_group = false
  create_security_group = true
  create_monitoring_role = true

  skip_final_snapshot = true
  deletion_protection = true
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  db_subnet_group_name   = var.database_subnet_group_name
  db_parameter_group_name         = aws_db_parameter_group.example.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.example.id

  iam_database_authentication_enabled = true
  master_username                     = local.db_creds.username 
  master_password                     = local.db_creds.password
  create_random_password              = false
}

resource "aws_db_parameter_group" "example" {
  name        = "test-aurora-db-57-parameter-group"
  family      = "aurora-mysql5.7"
  description = "test-aurora-db-57-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "example" {
  name        = "test-aurora-57-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "test-aurora-57-cluster-parameter-group"
}