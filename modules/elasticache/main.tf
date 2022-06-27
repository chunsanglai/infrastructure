resource "aws_elasticache_cluster" "example" {
  cluster_id           = var.name
  engine               = "redis"
  node_type            = "cache.m4.large"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
  apply_immediately = "true"
  auto_minor_version_upgrade = "true"
#   log_delivery_configuration {
#     destination      = aws_cloudwatch_log_group.example.name
#     destination_type = "cloudwatch-logs"
#     log_format       = "text"
#     log_type         = "slow-log"
#   }
  subnet_group_name = var.subnet_ids
}

