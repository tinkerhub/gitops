variable "do_token" {
  type        = string
  description = "digital ocean personal access token"
  sensitive   = true
}

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
