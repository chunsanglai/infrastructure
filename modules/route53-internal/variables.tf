variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-central-1"
}

variable "vpc_id" {
}

variable "private_zone_name" {
  default = "chun.internal"
}

variable "authorized_vpcs" {
  type    = list(string)
  default = []
}
