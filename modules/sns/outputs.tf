output "ok" {
  description = "The ID of the VPC"
  value       = aws_sns_topic.ok.arn
}
output "warning" {
  description = "The ID of the VPC"
  value       = aws_sns_topic.warning.arn
}
output "red" {
  description = "The ID of the VPC"
  value       = aws_sns_topic.red.arn
}