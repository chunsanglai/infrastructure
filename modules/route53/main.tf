###_____   ___    _   _   _____
##|__  /  / _ \  | \ | | | ____|
####/ /  | | | | |  \| | |  _|
###/ /_  | |_| | | |\  | | |___
##/____|  \___/  |_| \_| |_____|

resource "aws_route53_zone" "public" {
  name = var.domain_name
  comment = "${var.domain_name} public zone"
}