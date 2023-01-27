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

variable "public_dns_records" {
  type = list(object({
    name    = string,
    value   = string,
    type    = optional(string, "CNAME"),
    proxied = optional(bool, true)
  }))
  default = []
}

variable "cloudflare_zone_id" {
  type = string
}

variable "enable_ssl" {
  type    = bool
  default = false
}

variable "ssl_validation_method" {
  type    = string
  default = "DNS"
}
