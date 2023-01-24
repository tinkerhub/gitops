variable "environment" {
  description = "workspace environment"
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Allowed values for input_parameter are \"dev\", \"stage\", or \"prod\"."
  }
}

variable "create_private_dns_ns" {
  type = bool
}

variable "private_dns_namespace" {
  type    = string
  default = null
}

variable "private_dns_vpc_id" {
  type    = string
  default = null
}

variable "private_dns_hosts" {
  type    = map(object({ host : string }))
  default = {}
}
