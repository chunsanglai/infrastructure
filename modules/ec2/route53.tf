data "aws_route53_zone" "zone_name" {
  count        = var.private_hosted_zone_id != "" ? 1 : 0
  zone_id      = var.private_hosted_zone_id
  private_zone = true
}

resource "aws_route53_record" "cname-record" {
  count   = var.dns_cname != "" && var.private_hosted_zone_id != "" ? 1 : 0
  zone_id = var.private_hosted_zone_id
  name    = join(".", [var.dns_cname, data.aws_route53_zone.zone_name[0].name])
  type    = "CNAME"
  ttl     = "60"

  records = module.ec2_instance.private_ip
}