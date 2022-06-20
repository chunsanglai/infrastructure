output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
output "subnet_public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}
output "subnet_private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}
output "subnet_database_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
}
output "azs" {
  value = module.vpc.azs
}
