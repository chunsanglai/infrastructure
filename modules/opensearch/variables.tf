
variable "tags" {
  type = map(any)
}

variable "domain" {
  default     = "os-%s"
  description = "OpenSearch domain name"
  type        = string
}

variable "opensearch_version" {
  default     = "OpenSearch_1.2"
  description = "Opensearch version"
  type        = string
}

variable "instance_type" {
  default     = "t3.small.elasticsearch"
  description = "Opensearch instance type"
  type        = string
}

variable "instance_count" {
  default     = 1
  description = "Opensearch instance count"
  type        = number
}

variable "volume_size" {
  default     = 10
  description = "Opensearch volume size in GB"
  type        = number
}

variable "volume_type" {
  default     = "gp2"
  description = "Opensearch volume type"
  type        = string
}
variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs."
}
variable "cidr_blocks" {
  type        = list(string)  
}
variable "vpc_id" {
  description = "VPC ID"
  type        = string  
}
variable "security_group_ids" {
  type        = list(string) 
}