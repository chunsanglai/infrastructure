module "aws_route53_zone" {
  source            = "./modules/route53"
  public_zone_name  = "chunsang.lai"
  private_zone_name = "chunsang.lai.internal"
  vpc_id            = module.vpc.vpc_id
}
module "tags-factory" {
  source = "./modules/tags-factory"
}
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
  tags-factory            = module.tags-factory.tags
}
module "ec2" {
  source                 = "./modules/ec2"
  aws_region             = var.aws_region
  name                   = "ec2-deploy-asdawds"
  ami                    = "ami-0a5b5c0ea66ec560d"
  vpc_id                 = module.vpc.vpc_id
  instance_type          = "t2.micro"
  key_name               = "infra-ec2"
  availability_zone      = element(module.vpc.azs, 0)
  subnet_id              = element(module.vpc.subnet_public_subnet_ids, 0)
  public_ports           = ["80", "443"]
  cidr_block             = ["178.84.133.29/32"]
  volume_size            = 50
  data_volume_size       = 50
  tags-factory           = module.tags-factory.tags
  private_hosted_zone_id = module.aws_route53_zone.private_zone_id
  # mgmt_ingress_rules = [
  #   {
  #     from_port   = 22
  #     to_port     = 22
  #     protocol    = "tcp"
  #     cidr_block  = "1.2.3.4/32"
  #     description = "test"
  #   },
  #   {
  #     from_port   = 23
  #     to_port     = 23
  #     protocol    = "tcp"
  #     cidr_block  = "1.2.3.4/32"
  #     description = "test"
  #   },
  # ]
}
module "ec2-2e" {
  source                 = "./modules/ec2"
  aws_region             = var.aws_region
  name                   = "ec2-deploy-tweede"
  ami                    = "ami-0a5b5c0ea66ec560d"
  vpc_id                 = module.vpc.vpc_id
  instance_type          = "t2.micro"
  key_name               = "infra-ec2"
  availability_zone      = element(module.vpc.azs, 0)
  subnet_id              = element(module.vpc.subnet_public_subnet_ids, 0)
  public_ports           = ["80", "443"]
  cidr_block             = ["178.84.133.29/32", "192.168.1.0/32"]
  volume_size            = 50
  data_volume_size       = 50
  tags-factory           = module.tags-factory.tags
  private_hosted_zone_id = module.aws_route53_zone.private_zone_id
  # mgmt_ingress_rules = [
  #   {
  #     from_port   = 22
  #     to_port     = 22
  #     protocol    = "tcp"
  #     cidr_block  = "1.2.3.4/32"
  #     description = "test"
  #   },
  #   {
  #     from_port   = 23
  #     to_port     = 23
  #     protocol    = "tcp"
  #     cidr_block  = "1.2.3.4/32"
  #     description = "test"
  #   },
  # ]
}
module "ec2-3e" {
  source                 = "./modules/ec2"
  aws_region             = var.aws_region
  name                   = "ec2-deploy-derde"
  ami                    = "ami-0a5b5c0ea66ec560d"
  vpc_id                 = module.vpc.vpc_id
  instance_type          = "t2.micro"
  key_name               = "infra-ec2"
  availability_zone      = element(module.vpc.azs, 0)
  subnet_id              = element(module.vpc.subnet_public_subnet_ids, 0)
  public_ports           = ["80", "443"]
  cidr_block             = ["178.84.133.29/32"]
  volume_size            = 50
  data_volume_size       = 50
  tags-factory           = module.tags-factory.tags
  private_hosted_zone_id = module.aws_route53_zone.private_zone_id
  # mgmt_ingress_rules = [
  #   {
  #     from_port   = 22
  #     to_port     = 22
  #     protocol    = "tcp"
  #     cidr_block  = "1.2.3.4/32"
  #     description = "test"
  #   },
  #   {
  #     from_port   = 23
  #     to_port     = 23
  #     protocol    = "tcp"
  #     cidr_block  = "1.2.3.4/32"
  #     description = "test"
  #   },
  # ]
}
