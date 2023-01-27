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

variable "main_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "main_private_namespace" {
  type    = string
  default = "platform.co"
}
