variable "domain_name" {
    type = string
    description = "(optional) describe your variable"
}
variable "zone_id" {
    type = string
    description = "(optional) describe your variable"
}
variable "subject_alternative_names" {
    type = list(string)
    description = "(optional) describe your variable"
    default = [null]
}