variable "aws_region" {
  description = "The AWS region to create things in."
}

variable "name" {
  description = "Name to be business unit."
  default     = "carenity"
}
variable "target_id" {
  
}
variable "vpc_id" {
  description = "vpc id"
}
variable "load_balancer_type" {
  type = string
  description = "(optional) describe your variable"
}