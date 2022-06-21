variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-central-1"
}
variable "sns"{
  description = "sns name for ok warning"
  default = "sns-topic"
}
