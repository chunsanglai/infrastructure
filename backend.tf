terraform {
  backend "s3" {
    bucket                      = "terraform-state-chunsang"
    region                      = "eu-central-1"
    dynamodb_table              = "terraform-lock-state"
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
    key                         = "terraform/state/chun"
  }
}