# Route 53

resource "aws_route53_record" "std_record" {
  count   = (length(var.hosted_zone_ids) > 0) && (var.lb_dns_name == "") ? length(var.hosted_zone_ids) : 0
  zone_id = var.hosted_zone_ids[count.index]
  name    = var.name
  type    = "A"
  ttl     = "60"

  records = module.ec2_instance.public_ip
}

resource "aws_route53_record" "private_std_record" {
  count   = var.private_hosted_zone_id == "" ? 0 : 1
  zone_id = var.private_hosted_zone_id
  name    = var.name
  type    = "A"
  ttl     = "60"

  records = module.ec2_instance.private_ip
}
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