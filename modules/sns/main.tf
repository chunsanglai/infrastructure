resource "aws_sns_topic" "ok" {
  name              = var.ok
  kms_master_key_id = aws_kms_key.this.arn
}
resource "aws_kms_key" "this" {
}