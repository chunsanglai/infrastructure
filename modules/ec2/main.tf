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
  vpc_security_group_ids      = [aws_security_group.management-security-group.id]
  key_name                    = var.key_name
  monitoring                  = true
  iam_instance_profile        = aws_iam_instance_profile.this.name
  root_block_device           = [{ volume_type = var.volume_type, volume_size = var.volume_size, encrypted = true, kms_key_id  = aws_kms_key.this.arn}] # Default is gp3
  tags                        = var.tags
  private_ip                  = var.private_ip
  eip = true
  disable_api_termination     = true
}
resource "aws_eip" "ec2" {
  count = var.eip  == "true" ? 1 : 0
  instance = module.ec2_instance.id
  vpc      = true
}
# Static Security group. Must exist since managing an instance is a bare necessity
resource "aws_security_group" "management-security-group" {
  name        = join("-", [var.name, "management-security-group"])
  vpc_id = var.vpc_id
  dynamic "ingress" {
    for_each = var.management_ingress_rules
    content {
      from_port = ingress.value["from_port"]
      to_port = ingress.value["to_port"]
      protocol = ingress.value["protocol"]
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

#Optional security group for public access.
resource "aws_security_group" "public-security-group" {
  name        = join("-", [var.name, "public-security-group"])
  description = join(" ", ["Public security group for", var.name])
  tags = var.tags
  vpc_id      = var.vpc_id
  count       = var.public_ports[0] > 0 ? 1 : 0
  dynamic "ingress" {
    for_each = var.public_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface_sg_attachment" "public_sg_attachment" {
  count                = var.public_ports[0] > 0 ? 1 : 0
  security_group_id    = aws_security_group.public-security-group[0].id
  network_interface_id = module.ec2_instance.primary_network_interface_id
}

#Optional security group for internal access.
resource "aws_security_group" "internal-security-group" {
  name        = join("-", [var.name, "internal-security-group"])
  vpc_id = var.vpc_id
  dynamic "ingress" {
    for_each = var.internal_ingress_rules
    content {
      from_port = ingress.value["from_port"]
      to_port = ingress.value["to_port"]
      protocol = ingress.value["protocol"]
      security_groups = ingress.value["security_groups"]
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
  tags = var.tags
}

resource "aws_kms_key" "this" {
}

# Alarms
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
     alarm_name                = join("-", [var.name, "cpu-utilization"])
     comparison_operator       = "GreaterThanOrEqualToThreshold"
     evaluation_periods        = "2"
     metric_name               = "CPUUtilization"
     namespace                 = "AWS/EC2"
     period                    = "120" #seconds
     statistic                 = "Average"
     threshold                 = "80"
     alarm_description         = "This metric monitors ec2 cpu utilization"
     insufficient_data_actions = []
     dimensions                = { InstanceId = module.ec2_instance.id }
}

resource "aws_cloudwatch_metric_alarm" "ec2_memory" {
     alarm_name                = join("-", [var.name, "memory-utilization"])
     comparison_operator       = "GreaterThanOrEqualToThreshold"
     evaluation_periods        = "2"
     metric_name               = "mem_used_percent"
     namespace                 = "CWAgent"
     period                    = "120" #seconds
     statistic                 = "Average"
     threshold                 = "80"
     alarm_description         = "This metric monitors ec2 memory utilization"
     insufficient_data_actions = []
     dimensions                = { InstanceId = module.ec2_instance.id }
}

resource "aws_cloudwatch_metric_alarm" "ec2_swap" {
     alarm_name                = join("-", [var.name, "swap-utilization"])
     comparison_operator       = "GreaterThanOrEqualToThreshold"
     evaluation_periods        = "2"
     metric_name               = "swap_used_percent"
     namespace                 = "CWAgent"
     period                    = "120" #seconds
     statistic                 = "Average"
     threshold                 = "80"
     alarm_description         = "This metric monitors ec2 swap utilization"
     insufficient_data_actions = []
     dimensions                = { InstanceId = module.ec2_instance.id }
}

resource "aws_cloudwatch_metric_alarm" "ec2_root_disk" {
     alarm_name                = join("-", [var.name, "root-disk-utilization"])
     comparison_operator       = "GreaterThanOrEqualToThreshold"
     evaluation_periods        = "2"
     metric_name               = "disk_used_percent"
     namespace                 = "CWAgent"
     period                    = "120" #seconds
     statistic                 = "Average"
     threshold                 = "80"
     alarm_description         = "This metric monitors ec2 root disk utilization"
     insufficient_data_actions = []
     dimensions                = { InstanceId = module.ec2_instance.id,
                                  path = "/",
                                  fstype = "ext4"
                                 }
}

resource "aws_cloudwatch_metric_alarm" "ec2_data_disk" {
     alarm_name                = join("-", [var.name, "data-disk-utilization"])
     comparison_operator       = "GreaterThanOrEqualToThreshold"
     evaluation_periods        = "2"
     metric_name               = "disk_used_percent"
     namespace                 = "CWAgent"
     period                    = "120" #seconds
     statistic                 = "Average"
     threshold                 = "80"
     alarm_description         = "This metric monitors ec2 data disk utilization"
     insufficient_data_actions = []
     dimensions                = { InstanceId = module.ec2_instance.id,
                                  path = "/data",
                                  fstype = "ext4"
                                 }
}
