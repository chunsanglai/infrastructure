resource "aws_route53_record" "private_record" {
  # count   = var.private_hosted_zone_id == "" ? 0 : 1
  zone_id = var.private_hosted_zone_id
  name    = module.ec2_instance.private_dns
  type    = "A"
  ttl     = "60"

  records = [module.ec2_instance.private_ip]
}
resource "aws_route53_record" "public_record" {
  count   = var.eip  == "true" && var.subnet_id == "*public*" ? 1 : 0 
  zone_id = var.public_hosted_zone_id
  name    = var.name
  type    = "A"
  ttl     = "60"

  records = [module.ec2_instance.public_ip]
}