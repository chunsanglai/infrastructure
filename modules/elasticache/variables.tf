variable "domain_name" {
    type = string
    description = "name of elasticache cluster"
}
variable "engine_version" {
    type = string
    description = "(optional) describe your variable"
}
variable "port" {
    type = string
    description = "(optional) describe your variable"
}
variable "apply_immediately" {
    type = string
    description = "(optional) describe your variable"
}
variable "auto_minor_version_upgrade" {
    type = string
    description = "(optional) describe your variable"
}
variable "engine" {
    type = string
    description = "(optional) describe your variable"
}
variable "node_type" {
    type = string
    description = "(optional) describe your variable"
}
variable "num_cache_nodes" {
    type = string
    description = "(optional) describe your variable"
}
variable "parameter_group_name" {
    type = string
    description = "(optional) describe your variable"
}
variable "sns_alert_arn" {
  type = string
  default = null
}
variable "tags" {
  type = map(any)
}
variable "management_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string
  }))
}
variable "internal_ingress_rules" {
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    security_groups = list(string)
    description     = string
  }))
}
variable "vpc_id" {
  description = "vpc id"
}
variable "subnet_ids" {
  type = list
  description = "(optional) describe your variable"
}