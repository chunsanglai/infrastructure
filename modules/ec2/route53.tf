# resource "aws_route53_record" "public-record" {
#   zone_id = aws_route53_zone.public.zone_id
#   name    = module.ec2_instance.id
#   type    = "A"
#   ttl     = "300"
#   records = [aws_instance.ec2_instance.public_ip]
# }
