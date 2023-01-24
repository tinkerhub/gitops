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
