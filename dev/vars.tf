
variable "aws_access_key" {
  type        = string
  description = "AWS access key of IAM account for deployments"
  sensitive   = true
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key of IAM account for deployments"
  sensitive   = true
}

variable "aws_region" {
  type        = string
  description = "AWS region for deployment"
  sensitive   = true
}

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare token"
  sensitive   = true
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare zoneid copied from dashboard"
  sensitive   = true
}

variable "supertokens_secrets" {
  sensitive = true
  type = object({
    api_key = optional(string, "")
  })
  default = null
}

variable "platform_secrets" {
  sensitive = true
  type = object({
    pg_uri         = optional(string, "")
    msg91_auth_key = optional(string, "")
  })
  default = null
}

variable "platform_container" {
  type = object({
    registry_uri        = optional(string, "akhilmhdh/tinkerhub-platform:v1")
    container_port      = optional(number, 8000)
    host_port           = optional(number, 8000)
    cpu                 = optional(number, 256)
    memory              = optional(number, 512)
    enable_exec_command = optional(bool, true)
  })
  default = null
}

variable "platform_env" {
  type      = list(object({ name = string, value = string }))
  sensitive = true
  default   = []
}

variable "platform_domain" {
  type    = string
  default = "alpha.tinkerhub.org"
}

variable "platform_website_domain" {
  type    = string
  default = "dev.tinkerhub.org"
}
