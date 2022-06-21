resource "aws_sns_topic" "ok" {
  name              = var.ok
  kms_master_key_id = aws_kms_key.this.arn
}
resource "aws_sns_topic" "warning" {
  name              = var.warning
  kms_master_key_id = aws_kms_key.this.arn
}
resource "aws_sns_topic" "red" {
  name              = var.red
  kms_master_key_id = aws_kms_key.this.arn
}
resource "aws_kms_key" "this" {
}