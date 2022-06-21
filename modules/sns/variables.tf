variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-central-1"
}
variable "ok"{
  description = "sns name for ok warning"
  default = "ok-topic"
}
variable "warning" {
  description = "sns name for info warning"
  default = "warning-topic"

}
variable "critical" {
  description = "sns name for critical warning" 
  default = "critical-topic"
}