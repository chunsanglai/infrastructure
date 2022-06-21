locals {
  userdata = templatefile("./modules/ec2/userdata.sh", {
    ssm_cloudwatch_config = aws_ssm_parameter.cw_agent.name
  })
}
resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent config to configure custom log"
  name        = "/cloudwatch-agent/config/${var.name}"
  type        = "String"
  value       = file("./modules/ec2/cw_agent_config.json")
}

module "ec2_instance" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "~> 4.0.0"
  name                        = var.name
  ami                         = var.ami
  instance_type               = var.instance_type
  availability_zone           = var.availability_zone
  subnet_id                   = var.subnet_id
  user_data                   = local.userdata
  vpc_security_group_ids      = [aws_security_group.public-security-group[0].id, aws_security_group.internal-security-group.id,aws_security_group.mgmt_security_groups]
  key_name                    = var.key_name
  monitoring                  = true
  iam_instance_profile        = aws_iam_instance_profile.this.name
  root_block_device           = [{ volume_type = var.volume_type, volume_size = var.volume_size, encrypted = true, kms_key_id  = aws_kms_key.this.arn}] # Default is gp3
  tags                        = var.tags-factory
  private_ip                  = var.private_ip
  disable_api_termination     = true
}

resource "aws_security_group" "public-security-group" {
  name        = join("-", [var.name, "public-security-group"])
  description = "Security group for EC2 instance"
  tags = var.tags-factory
  vpc_id      = var.vpc_id
  count       = var.public_ports[0] > 0 ? 1 : 0
  dynamic "ingress" {
    for_each = var.public_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.cidr_block
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
  name        = join("-", [var.name, "internal-security-group"])
  description = "Security group for EC2 instance"
  tags = var.tags-factory
  vpc_id      = var.vpc_id
  ingress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      security_groups  = var.internal-security-groups
    }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# resource "aws_security_group" "mgmt_security_groups" {
#   name        = join("-", [var.name, "mgmt-security-group"])
#   description = "Security group for EC2 instance"
#   tags = var.tags-factory
#   vpc_id = var.vpc_id
# }
resource "aws_security_group_rule" "mgmt_ingress_rules" {
  count = length(var.mgmt_ingress_rules)

  type              = "ingress"
  from_port         = var.mgmt_ingress_rules[count.index].from_port
  to_port           = var.mgmt_ingress_rules[count.index].to_port
  protocol          = var.mgmt_ingress_rules[count.index].protocol
  cidr_blocks       = [var.mgmt_ingress_rules[count.index].cidr_block]
  description       = var.mgmt_ingress_rules[count.index].description
  security_group_id = aws_security_group.public-security-group.id
}

#Data Volume
resource "aws_volume_attachment" "this" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.this.id
  instance_id = module.ec2_instance.id
}

resource "aws_ebs_volume" "this" {
  availability_zone = var.availability_zone
  size              = var.data_volume_size
  encrypted = true
  type = var.volume_type
  kms_key_id  = aws_kms_key.this.arn
  tags = var.tags-factory
}

resource "aws_kms_key" "this" {
}