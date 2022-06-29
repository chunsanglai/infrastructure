module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 7.0"

  name = var.name 

  load_balancer_type = var.load_balancer_type

  vpc_id             = var.vpc_id
  subnets            = var.subnet_ids

  dynamic "target_groups" {
    for_each = var.targets
    content {
      name_prefix = target_groups.value["pref-"]
      backend_protocol = target_groups.value["backend_protocol"]
      backend_port = target_groups.value["backend_port"]
      target_type = target_groups.value["target_type"]
      targets = {target_groups.value = [""]}
    }
  }
 
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "alb-sg-${var.name}-${var.aws_region}"
  description = "Security group for example usage with ALB"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}
