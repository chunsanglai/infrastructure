variable "aws_region" {
  description = "The AWS region to create things in."
}

variable "name" {
  description = "Name to be business unit."
  default     = "carenity"
}
variable "vpc_id" {
  description = "vpc id"
}
variable "subnet_ids" {
  description = "subnet id"
}
variable "load_balancer_type" {
  type = string
  description = "(optional) describe your variable"
}
variable "enable_deletion_protection" {
  type = string
  description = "(optional) describe your variable"
}
variable "ssl_policy" {
  type = string
  description = "(optional) describe your variable"
}
variable "certificate_arn" {
  type = string
  description = "(optional) describe your variable"
}
variable "tags" {
  type = map(any)
}
# variable "deletion_window_in_days" {
#   type    = number
#   default = 30
# }
variable "instance_id" {
  type = string
  description = "(optional) describe your variable"
}

variable "domain_name" {
  type = string
  description = "(optional) describe your variable"
  default = "chunsanglai.com"
}
variable "hosts" {
  # type = "map"
  default = {
    "default" = {
      "tgport"  = "80"
      "tgproto" = "HTTP"
    }
    "nginx" = {
      "tgport"  = "443"
      "tgproto" = "HTTPS"
    },
    "rabbit" = {
      "tgport"  = "15672"
      "tgproto" = "HTTP"
    }
  }
}
