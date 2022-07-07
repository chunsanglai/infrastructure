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
variable "instance_ids" {
  type = list
  description = "(optional) describe your variable"
}
variable "hosts" {
  type = list
  description = "(optional) describe your variable"
}
variable "hosts2" {
  # type = "map"
  default = {
    "nginx" = {
      "tgport"  = "8080"
      "tgproto" = "HTTP"
    },
    "rabbit" = {
      "tgport"  = "15672"
      "tgproto" = "HTTP"
    }
  }
}