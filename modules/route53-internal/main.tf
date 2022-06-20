# Private zone
resource "aws_route53_zone" "private_zone" {
  vpc {
    vpc_id = var.vpc_id // Makes it private
  }

  name = var.private_zone_name
  tags = var.tags
  lifecycle {
    ignore_changes = [vpc]
  }
}

# Private zone authorization
resource "aws_route53_vpc_association_authorization" "authorization" {
  for_each = toset(var.authorized_vpcs)
  vpc_id   = each.key
  zone_id  = aws_route53_zone.private_zone.id
}
