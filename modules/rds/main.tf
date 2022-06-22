module "rds-aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 7.2.0"
  name = var.name
  engine         = var.engine
  engine_version = var.engine_version

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
  master_password                     = random_password.master.result
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

resource "random_password" "master" {
  length = 10
}