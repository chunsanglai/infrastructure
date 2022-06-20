module "aws_route53_zone" {
  source      = "./modules/route53"
  domain_name = "chunsang.lai"
}
module "tags-factory" {
  source = "./modules/tags-factory"
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
# module "ec2" {
#   source            = "./modules/ec2"
#   aws_region        = var.aws_region
#   name              = "ec2-deploy-fxzxcasd"
#   ami               = "ami-0a5b5c0ea66ec560d"
#   vpc_id            = module.vpc.vpc_id
#   instance_type     = "t2.micro"
#   key_name          = ""
#   availability_zone = element(module.vpc.azs, 0)
#   subnet_id         = element(module.vpc.subnet_private_subnet_ids, 0)
#   ports             = ["80"]
#   cidr_block        = ["10.55.2.0/24", "192.168.1.0/24"]
#   volume_size       = 50
#   data_volume_size  = 50
#   tags-factory      = module.tags-factory.tags
# }
