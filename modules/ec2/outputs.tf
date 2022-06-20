output "instance_ip" {
  description = "EC2 private ip"
  value       = module.ec2_instance.private_ip
}