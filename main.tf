module "aws_route53_zone" {
  source            = "./modules/route53"
  public_zone_name  = "chunsang.lai"
  private_zone_name = "chunsang.lai.internal"
  vpc_id            = module.vpc.vpc_id
}
# module "tags-factory" {
#   source = "./modules/tags-factory"
# }
module "sns" {
  source = "./modules/sns"
}
module "vpc" {
  source                  = "./modules/vpc"
  name                    = "chun"
  env                     = "test"
  aws_region              = "eu-central-1"
  azs                     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  cidr                    = "10.55.0.0/16"
  public_subnets          = ["10.55.1.0/24", "10.55.2.0/24", "10.55.3.0/24"]
  private_subnets         = ["10.55.4.0/24", "10.55.5.0/24", "10.55.6.0/24"]
  database_subnets        = ["10.55.7.0/24", "10.55.8.0/24", "10.55.9.0/24"]
  enable_nat_gateway      = false
  single_nat_gateway      = false
  deletion_window_in_days = 30
  log_destination_type    = "s3"
  traffic_type            = "ALL"
  tags = {
    CostCenter   = "chun"
    map-migrated = "d-server-12345"
    Managedby    = "Terraform"
  }
}

module "stg-alb" {
  source                     = "./modules/loadbalancer"
  aws_region                 = var.aws_region
  name                       = "chun-alb"
  load_balancer_type         = "application"
  subnet_ids                 = [module.vpc.subnet_public_subnet_ids[0], module.vpc.subnet_public_subnet_ids[1]]
  vpc_id                     = module.vpc.vpc_id
  target_id                  = "" #currently supports 1 instance
  enable_deletion_protection = "false"
  port                       = "80"
  protocol                   = "HTTP"
  ssl_policy                 = ""
  certificate_arn            = ""
  # deletion_window_in_days    = "7"
  tags = {
    CostCenter   = "chun"
    map-migrated = "d-server-12345"
    Managedby    = "Terraform"
  }
}

# module "acm" {
#   source      = "./modules/acm"
#   zone_id     = module.aws_route53_zone.public_zone_id
#   domain_name = "jaychunlai.com1"
# }


module "ec2" {
  source            = "./modules/ec2"
  aws_region        = var.aws_region
  name              = "carenire7"
  ami               = "ami-0a5b5c0ea66ec560d"
  vpc_id            = module.vpc.vpc_id
  instance_type     = "t2.micro"
  key_name          = "infra-ec2"
  availability_zone = element(module.vpc.azs, 0)
  subnet_id         = element(module.vpc.subnet_public_subnet_ids, 0)
  public_ports      = ["80", "443"]
  eip               = true
  volume_size       = 50
  data_volume_size  = 50
  tags = {
    CostCenter   = "chun"
    map-migrated = "d-server-12345"
    Managedby    = "Terraform"
  }
  private_hosted_zone_id = module.aws_route53_zone.private_zone_id
  public_hosted_zone_id  = module.aws_route53_zone.public_zone_id
  management_ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = "10.60.0.0/16"
      description = "ssh"
    },
  ]
  internal_ingress_rules = []
}
# module "os" {
#   source                         = "./modules/opensearch"
#   vpc_id                         = module.vpc.vpc_id
#   domain_name                    = "ppd-os-chun"
#   opensearch_version             = "OpenSearch_1.2"
#   instance_type                  = "t3.small.elasticsearch"
#   create_iam_service_linked_role = true
#   subnet_ids                     = [module.vpc.subnet_private_subnet_ids[0]]
#   instance_count                 = "1"
#   volume_size                    = "10"
#   volume_type                    = "gp2" #doesnt support GP3 yet
#   management_ingress_rules = [
#     {
#       from_port   = 6379
#       to_port     = 6379
#       protocol    = "tcp"
#       cidr_block  = "10.60.0.0/16"
#       description = "redis"
#     },
#   ]
#   internal_ingress_rules = [
#     # {
#     #   from_port       = 22
#     #   to_port         = 22
#     #   protocol        = "tcp"
#     #   security_groups = [] #module.ec2-instance-1.instance_sg, module.ec2-instance-2.instance_sg
#     #   description     = "ssh"
#     # },
#   ]
#   tags = {
#     CostCenter   = "chun"
#     map-migrated = "d-server-12345"
#     Managedby    = "Terraform"
#   }
# }
# module "elasticache" {
#   source                     = "./modules/elasticache"
#   domain                = "ppd-chun-es"
#   engine                     = "redis"
#   node_type                  = "cache.m4.large"
#   num_cache_nodes            = 1
#   parameter_group_name       = "default.redis6.x"
#   engine_version             = "6.2"
#   port                       = 6379
#   apply_immediately          = "true"
#   auto_minor_version_upgrade = "true"
#   sns_alert_arn              = module.sns.sns

#   tags = {
#     CostCenter   = "chun"
#     map-migrated = "d-server-12345"
#     Managedby    = "Terraform"
#   } #module.tags-factory.tags
# }
