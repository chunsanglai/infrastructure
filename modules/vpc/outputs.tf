output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
output "subnet_public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}
output "subnet_public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = module.vpc.public_subnets_cidr_blocks
}
output "subnet_private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}
output "subnet_private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.vpc.private_subnets_cidr_blocks
}
output "subnet_database_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
}
output "subnet_database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = module.vpc.database_subnets_cidr_blocks
}
output "azs" {
  value = module.vpc.azs
}
