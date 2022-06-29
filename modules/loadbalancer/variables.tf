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
variable "subnet_ids" {
  description = "subnet id"
}
variable "load_balancer_type" {
  type = string
  description = "(optional) describe your variable"
}
variable "targets" {
  type = list(object(
    {
      name_prefix      = string
      backend_protocol = string
      backend_port     = number
      target_type      = string
      targets = list(string)
    }
  ))
}