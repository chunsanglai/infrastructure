locals {
  subject_alternative_names = concat(["*.${var.domain_name}"],["*.stage.${var.domain_name}"], var.custom_sub_domain_names)
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.domain_name}"
  validation_method = "DNS"
  subject_alternative_names = local.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }
}
