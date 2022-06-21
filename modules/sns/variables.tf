variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-central-1"
}
variable "green"{
  description = "sns name for ok warning"
}
variable "info" {
  description = "sns name for info warning"
}
variable "red" {
  description = "sns name for red warning" 
}