module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> v3.14.0"
  name = join("-", [var.name,var.env, "vpc"])
  cidr = var.cidr

  azs                       = var.azs 
  public_subnets            = var.public_subnets
  public_subnet_tags        = var.public_subnet_tags
  public_route_table_tags   = var.public_subnet_tags
  private_subnets           = var.private_subnets
  private_subnet_tags       = var.private_subnet_tags
  private_route_table_tags  = var.private_subnet_tags
  database_subnets          = var.database_subnets 
  database_subnet_tags      = var.database_subnet_tags
  database_route_table_tags = var.database_subnet_tags

  enable_nat_gateway        = var.enable_nat_gateway
  single_nat_gateway        = var.single_nat_gateway

  enable_dns_hostnames = true
  
  tags = var.tags-factory
}
### VPC FLOW LOG
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn         = aws_iam_role.iam-vpc-s3-role.arn
  log_destination      = aws_s3_bucket.vpc_log.arn
  log_destination_type = var.log_destination_type 
  traffic_type         = var.traffic_type
  vpc_id               = module.vpc.vpc_id
}

resource "aws_s3_bucket" "vpc_log" {
  bucket = join("-", [var.name, var.env, var.aws_region, "vpc-flowlog"])
  tags = var.tags-factory
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.vpc_log.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.kms_vpc.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
resource "aws_iam_role" "iam-vpc-s3-role" {
  name = "iam-vpc-s3-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "iam-vpc-s3-policy" {
  name = "iam-vpc-s3-policy"
  role = "${aws_iam_role.iam-vpc-s3-role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
### END VPC FLOW LOG

### KMS KEY
resource "aws_kms_key" "kms_vpc" {
  deletion_window_in_days  = var.deletion_window_in_days
  tags                     = var.tags-factory
}
### END KMS KEY