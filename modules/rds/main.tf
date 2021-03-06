#Create RDS password
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
#Import RDS password
data "aws_secretsmanager_secret" "password" {
  arn = aws_secretsmanager_secret.password.arn
}
data "aws_secretsmanager_secret_version" "credentials" {
  secret_id = data.aws_secretsmanager_secret.password.arn
}
locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.credentials.secret_string)
}
#Create KMS for RDS
resource "aws_kms_key" "this" {
}

#Create RDS Cluster with 1 instance
module "rds-aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 7.2.0"
  name = var.name
  database_name = var.database_name
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  instances = var.instances

  kms_key_id  = aws_kms_key.this.arn
  storage_encrypted = true

  vpc_id                = var.vpc_id
  allowed_security_groups = var.allowed_security_groups 
  allowed_cidr_blocks   = var.allowed_cidr_blocks
  create_db_subnet_group = false
  create_security_group = true
  create_monitoring_role = true

  skip_final_snapshot = true
  deletion_protection = var.deletion_protection
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  db_subnet_group_name   = var.database_subnet_group_name
  db_parameter_group_name         = aws_db_parameter_group.db_group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.rds_group.id

  iam_database_authentication_enabled = true
  master_username                     = local.db_creds.username 
  master_password                     = local.db_creds.password
  create_random_password              = false

  autoscaling_enabled      = var.autoscaling_enabled
  autoscaling_min_capacity = var.autoscaling_min_capacity
  autoscaling_max_capacity = var.autoscaling_max_capacity
  preferred_backup_window = var.preferred_backup_window
  backup_retention_period = var.backup_retention_period
  copy_tags_to_snapshot = true
  tags = var.tags
}

#Create DB Parameter group
resource "aws_db_parameter_group" "db_group" {
  name        = "${var.name}-parameter-group"
  family      = var.family
  description = "${var.name}-parameter-group"
}
#Create RDS Cluster Parameter group
resource "aws_rds_cluster_parameter_group" "rds_group" {
  name        = "${var.name}-cluster-parameter-group"
  family      = var.family
  description = "${var.name}-cluster-parameter-group"
}

resource "aws_cloudwatch_metric_alarm" "cpu-alarm" {
  for_each = var.instances
  alarm_name                = "${var.name}-${each.key}-cpu-alarm"
  alarm_description         = "This metric monitors database storage dipping below threshold"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "80"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  period                    = "120"
  statistic                 = "Average"
  dimensions                = { DBInstanceIdentifier    = "${var.name}-${each.key}"}
}