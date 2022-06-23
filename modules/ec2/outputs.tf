output "instance_ip" {
  description = "EC2 private ip"
  value       = module.ec2_instance.private_ip
}
output "instance_id" {
  description = "EC2 id"
  value       = module.ec2_instance.id
}
output "private_dns" {
  value = var.private_hosted_zone_id != "" ? aws_route53_record.private_record[0].fqdn : null
}