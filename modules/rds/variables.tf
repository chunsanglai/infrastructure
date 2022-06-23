variable "name" {
  description = "Aurora database name"
  type        = string  
}
variable "engine" {
  description = "Aurora database engine"
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
variable "database_subnet_group_name" {
}

variable "instance_class" {
  description = "The instance type of the RDS instance."
}
variable "deletion_protection" {
  
}
variable "family" {
  
}
variable "autoscaling_enabled" {
  type        = string 
  default = false
}
variable "autoscaling_min_capacity" {
  type        = string 
}
variable "autoscaling_max_capacity" {
  type        = string 
}
variable "db_instances" {
  
}