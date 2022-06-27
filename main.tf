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
  volume_size       = 50
  data_volume_size  = 50
  tags = {
    CostCenter   = "chun"
    map-migrated = "d-server-12345"
    Managedby    = "Terraform"
  }
  private_hosted_zone_id = module.aws_route53_zone.private_zone_id
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
module "os" {
  source             = "./modules/opensearch"
  vpc_id             = module.vpc.vpc_id
  domain             = "os-chuns12"
  opensearch_version = "OpenSearch_1.2"
  instance_type      = "t3.small.elasticsearch"
  create_iam_service_linked_role = true
  subnet_ids         = [module.vpc.subnet_private_subnet_ids[0]]
  allowed_security_groups = [] 
  instance_count     = "1"
  volume_size        = "10"
  volume_type        = "gp2" #doesnt support GP3 yet
  tags = {
    CostCenter   = "chun"
    map-migrated = "d-server-12345"
    Managedby    = "Terraform"
  }
}
module "os-1" {
  source             = "./modules/opensearch"
  vpc_id             = module.vpc.vpc_id
  domain             = "os-chuns12345676"
  opensearch_version = "OpenSearch_1.2"
  instance_type      = "t3.small.elasticsearch"
  create_iam_service_linked_role = false
  subnet_ids         = [module.vpc.subnet_private_subnet_ids[0]]
  allowed_security_groups = [] 
  instance_count     = "1"
  volume_size        = "10"
  volume_type        = "gp2" #doesnt support GP3 yet
  tags = {
    CostCenter   = "chun"
    map-migrated = "d-server-12345"
    Managedby    = "Terraform"
  }
}