resource "aws_elasticache_cluster" "redis" {
  cluster_id           = var.name
  engine               = var.engine
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes 
  parameter_group_name = var.parameter_group_name
  engine_version       = var.engine_version
  port                 = var.port 
  apply_immediately = var.apply_immediately
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
resource "aws_cloudwatch_log_group" "redis_slow" {
  name = "${var.name}-slow"
  tags = var.tags
}
resource "aws_cloudwatch_log_group" "redis_engine" {
  name = "${var.name}-engine"
  tags = var.tags
}
resource "aws_cloudwatch_metric_alarm" "elasticache-high-cpu-warning" {
  alarm_name          = "${var.name}-high-cpu-warning"
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
  alarm_name          = "${var.name}-high-db-memory-warning"
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
  alarm_name          = "${var.name}-high-connection-warning"
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