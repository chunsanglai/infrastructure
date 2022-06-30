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
variable "target_id" {
  type = string
  description = "(optional) describe your variable"
}
variable "enable_deletion_protection" {
  type = string
  description = "(optional) describe your variable"
}
variable "port" {
  type = string
  description = "(optional) describe your variable"
}
variable "protocol" {
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