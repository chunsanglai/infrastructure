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
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = "80"
      target_type      = "instance"
      targets = {
        my_target = {
          target_id = ""
          port = ""
        }
      }
    }
  ))
}

