resource "aws_lb" "loadbalancer" {
  name               = var.name
  internal           = false
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.allow_lb.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection 

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.bucket
  #   prefix  = "${var.name}-lb_logs"
  #   enabled = true
  # }

  tags = var.tags
}

# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.loadbalancer.arn
#   port              = "80" 
#   protocol          = "HTTP"
#   ssl_policy        = var.ssl_policy
#   certificate_arn   = var.certificate_arn
#   default_action {
#     type             = "redirect"
#     redirect {
#       port = "443"
#       protocol = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }
resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = "80" 
  protocol          = "HTTP" 
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group["default"].arn
  }
}
resource "aws_lb_listener_rule" "host_based_weighted_routing" {
  for_each = aws_lb_target_group.lb_target_group
  listener_arn = aws_lb_listener.test.arn

  action {
    type             = "forward"
    target_group_arn = each.value.arn
  }

  condition {
    host_header {
      values = ["${each.key}.${var.domain_name}"] 
    }
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  for_each = var.hosts
  name     = "${each.key}-lb-tg"
  port     = each.value.tgport
  protocol = each.value.tgproto
  vpc_id   = var.vpc_id
}
resource "aws_lb_target_group_attachment" "lb_target_group_attachment" {
  for_each = aws_lb_target_group.lb_target_group
  target_group_arn = each.value.arn
  target_id        = var.instance_id
  port             = each.value.port
}

resource "aws_security_group" "allow_lb" {
  name        = "${var.name}-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# resource "aws_s3_bucket" "lb_logs" {
#   bucket = join("-", [var.name,var.aws_region, "lb-logs"])
#   tags   = var.tags
# }

# resource "aws_s3_bucket_public_access_block" "lb_logs" {
#   bucket = aws_s3_bucket.lb_logs.id
#   block_public_acls   = true
#   block_public_policy = true
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
#   bucket = aws_s3_bucket.lb_logs.bucket
#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = aws_kms_key.kms.arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }
# resource "aws_s3_bucket_policy" "allow_lb_logs" {
#   bucket = aws_s3_bucket.lb_logs.id
#   policy = data.aws_iam_policy_document.allow_lb_logs_policy.json
# }
# data "aws_iam_policy_document" "allow_lb_logs_policy" {
#   statement {
#     effect    = "Allow"
#     actions   = ["s3:PutObject"]
#     resources = ["arn:aws:s3:::${aws_s3_bucket.lb_logs.id}/*"]
#     principals {
#       type        = "AWS"
#       identifiers = ["054676820928"]
#     }
#   }
# }

# ### KMS KEY
# resource "aws_kms_key" "kms" {
#   deletion_window_in_days = var.deletion_window_in_days
#   tags                    = var.tags
# }
# ### END KMS KEY