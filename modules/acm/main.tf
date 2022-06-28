module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0.1"

  domain_name  = var.domain_name  
  zone_id      = var.zone_id

  subject_alternative_names = [
    "*.my-domain.com",
    "app.sub.my-domain.com",
  ]

  wait_for_validation = true
}