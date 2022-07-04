variable "domain_name" {
    type = string
    description = "(optional) describe your variable"
}
variable "zone_id" {
    type = string
    description = "(optional) describe your variable"
}
variable "custom_sub_domain_names" {
  type    = list(string)
  default = []
}
