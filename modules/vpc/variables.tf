variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-central-1"
}

variable "name" {
  description = "Name."
  default     = "evidentiq"
}

variable "env" {
  description = "environment name."
  default     = "carenity"
}
variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.55.0.0/16"
}
variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(any)
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(any)
  default     = ["10.55.1.0/24", "10.55.2.0/24", "10.55.3.0/24"]
}
variable "public_subnet_tags" {
  type        = map(any)
  description = "A list of public subnet tags"

  default = {
    Network = "Public"
  }
}
variable "private_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(any)
  default     = ["10.55.4.0/24", "10.55.5.0/24", "10.55.6.0/24"]
}
variable "private_subnet_tags" {
  type        = map(any)
  description = "A list of private subnet tags"

  default = {
    Network = "Private"
  }
}
variable "database_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(any)
  default     = ["10.55.7.0/24", "10.55.8.0/24", "10.55.9.0/24"]
}
variable "database_subnet_tags" {
  type        = map(any)
  description = "A list of database subnet tags"

  default = {
    Network = "Database"
  }
}
variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = true
}

variable "tags-factory" {
  type = map(any)
}
variable "deletion_window_in_days" {
  type    = number
  default = 30
}
variable "log_destination_type" {
  type    = string
  default = "s3"
}
variable "traffic_type" {
  type    = string
  default = "ALL"
}