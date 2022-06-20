variable "aws_region" {
  description = "The AWS region to create things in."
}
variable "name" {
  description = "The name of the instance."
  default     = "Instance"
  type = string

  }
variable "ami" {
  type    = string
  default = ""
  }
variable "instance_type" {
  type    = string
  default = "t3.small"
  }
variable "key_name" {
  type    = string
  default = ""
}
variable "volume_type" {
  type    = string
  default = "gp3"
}
variable "volume_size" {
  type    = string
  default = "20"
}
variable "data_volume_size" {
  type    = string
  default = "50"
}
variable "EC2_ROOT_VOLUME_DELETE_ON_TERMINATION" {
  type    = string
  default = "false"
}
variable "availability_zone" {
  description = "availability zones in the region"
  type        = string
  default     = ""
}
variable "subnet_id" {
  description = "subnet id"
  type        = string
  default     = ""
}
variable "ports" {
  description = "Port numbers to be used in the security group"
  type        = list(number)
  default     = [-1]
}

variable "cidr_block" {
  description = "CIDR range of the non-standard subnet(s)"
  type        = list(string)
  default     = [""]
}

variable "vpc_id" {
  description = "vpc id"
}
variable "tags-factory" {
  type = map(any)
}

variable "private_ip" {
  type        = string
  default     = null
  description = "Private IP address to associate with the instance in a VPC"
}
variable "private_hosted_zone_id" {
  type    = string
  default = ""
}
variable "internal_security_groups" {
  type        = list(string)
}