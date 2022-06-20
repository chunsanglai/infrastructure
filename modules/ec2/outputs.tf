output "instance_ip" {
  description = "EC2 private ip"
  value       = module.ec2_instance.private_ip
}
output "private_dns" {
  value = var.private_hosted_zone_id != "" ? aws_route53_record.private_record[0].fqdn : null
}
output "internal_security_group" {
  value = aws_security_group.internal_security_group.id
}