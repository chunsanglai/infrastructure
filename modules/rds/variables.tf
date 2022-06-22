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
output "db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = module.db.db_instance_password
  sensitive   = true
}