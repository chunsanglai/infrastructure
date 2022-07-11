resource "aws_elasticache_cluster" "redis" {
  cluster_id           = var.domain_name
  engine               = var.engine
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes 
  parameter_group_name = var.parameter_group_name
  engine_version       = var.engine_version
  port                 = var.port 
  apply_immediately = var.apply_immediately
  security_group_ids   = [aws_security_group.management-security-group.id, aws_security_group.internal-security-group.id]
  subnet_group_name = aws_elasticache_subnet_group.ec.name
  tags = var.tags
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_slow.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_engine.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }
}
resource "aws_elasticache_subnet_group" "ec" {
  name       = "${var.domain_name}-subnet"
  subnet_ids = var.subnet_ids
}
resource "aws_cloudwatch_log_group" "redis_slow" {
  name = "${var.domain_name}-slow"
  tags = var.tags
}
resource "aws_cloudwatch_log_group" "redis_engine" {
  name = "${var.domain_name}-engine"
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

resource "aws_cloudwatch_metric_alarm" "elasticache-high-cpu-warning" {
  alarm_name          = "${var.domain_name}-high-cpu-warning"
  alarm_description   = "Average CPU of ElastiCache >= 70% during 1 minute"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = "60"
  statistic           = "Average"
  threshold           = 70
  alarm_actions       = [var.sns_alert_arn]
  treat_missing_data  = "breaching"
  dimensions = {
    CacheClusterId = aws_elasticache_cluster.redis.cluster_id
  }
}

resource "aws_cloudwatch_metric_alarm" "elasticache-high-db-memory-warning" {
  alarm_name          = "${var.domain_name}-high-db-memory-warning"
  alarm_description   = "Average DB Memory on ElastiCache >= 60% during 1 minute"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = "60"
  statistic           = "Average"
  threshold           = 60
  alarm_actions       = [var.sns_alert_arn]
  dimensions = {
    CacheClusterId = aws_elasticache_cluster.redis.cluster_id  }
}

resource "aws_cloudwatch_metric_alarm" "elasticache-high-connection-warning" {
  alarm_name          = "${var.domain_name}-high-connection-warning"
  alarm_description   = "Average Number of Connections on ElastiCache >= 1000 connections during 1 minute"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CurrConnections"
  namespace           = "AWS/ElastiCache"
  period              = "60"
  statistic           = "Average"
  threshold           = 1000
  alarm_actions       = [var.sns_alert_arn]
  dimensions = {
    CacheClusterId = aws_elasticache_cluster.redis.cluster_id  }
}