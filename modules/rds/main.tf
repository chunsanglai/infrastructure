module "rds-aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 7.2.0"
  name = "test-aurora-db"
  engine         = "aurora-mysql"
  engine_mode    = "serverless"
  engine_version = var.engine_version
  # enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  storage_encrypted = true

  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false

  vpc_id                = var.vpc_id
  allowed_cidr_blocks   = var.allowed_cidr_blocks
  create_db_subnet_group = false
  create_security_group = true
  create_monitoring_role = true

  skip_final_snapshot = true
  deletion_protection = true

  db_parameter_group_name         = aws_db_parameter_group.standard_aurora_mysql_5_7.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.example.id
}

resource "aws_db_parameter_group" "example" {
  name        = "$test-aurora-db-57-parameter-group"
  family      = "aurora-mysql5.7"
  description = "test-aurora-db-57-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "example" {
  name        = "test-aurora-57-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "test-aurora-57-cluster-parameter-group"
}

