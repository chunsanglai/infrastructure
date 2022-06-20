###_____   ___    _   _   _____
##|__  /  / _ \  | \ | | | ____|
####/ /  | | | | |  \| | |  _|
###/ /_  | |_| | | |\  | | |___
##/____|  \___/  |_| \_| |_____|

resource "aws_route53_zone" "public" {
  name = var.public_zone_name
  comment = "${var.public_zone_name} public zone"
}
# Private zone
resource "aws_route53_zone" "private" {
  vpc {
    vpc_id = var.vpc_id // Makes it private
  }

  name = var.private_zone_name
  lifecycle {
    ignore_changes = [vpc]
  }
}
# Private zone authorization
resource "aws_route53_vpc_association_authorization" "authorization" {
  for_each = toset(var.authorized_vpcs)
  vpc_id   = each.key
  zone_id  = aws_route53_zone.private.id
}
