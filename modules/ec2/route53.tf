resource "aws_route53_record" "private_record" {
  # count   = var.private_hosted_zone_id == "" ? 0 : 1
  zone_id = var.private_hosted_zone_id
  name    = var.name
  type    = "A"
  ttl     = "60"

  records = [module.ec2_instance.private_ip]
}
resource "aws_route53_record" "public_record" {
  count   = var.eip  == "true" ? 1 : 0 
  zone_id = var.public_hosted_zone_id
  name    = var.name
  type    = "A"
  ttl     = "60"

  records = [aws_eip.pub_ip[0].public_ip]
}