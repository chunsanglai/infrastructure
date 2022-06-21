output "sns" {
  description = "The ID of the VPC"
  value       = aws_sns_topic.sns.arn
}