output "instance_ip" {
  description = "EC2 private ip"
  value       = module.ec2_instance.private_ip
}
output "instance_id" {
  description = "EC2 id"
  value       = module.ec2_instance.id
}