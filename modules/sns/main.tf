resource "aws_sns_topic" "user_updates" {
  name              = "user-updates-topic"
  kms_master_key_id = aws_kms_key.this.arn
}
resource "aws_kms_key" "this" {
}