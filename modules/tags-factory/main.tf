locals {
  tags = tomap(
    {
      map-migrated = "${var.map-migrated-value}"
      Managedby   = "Terraform"
    }
  )
}