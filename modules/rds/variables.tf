variable "name" {
  description = "Aurora database name"
  type        = string  
}
variable "engine_version" {
  description = "Aurora database engine version"
  type        = string  
}
variable "vpc_id" {
  description = "VPC ID"
  type        = string  
}

variable "allowed_cidr_blocks" {
  description = "A list of CIDR blocks which are allowed to access the database"
  type        = list(string)  
}