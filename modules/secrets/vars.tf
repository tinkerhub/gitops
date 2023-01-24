variable "environment" {
  description = "workspace environment"
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Allowed values for input_parameter are \"dev\", \"stage\", or \"prod\"."
  }
}

variable "supertokens_api_key" {
  description = "api key for supertoken container"
  sensitive   = true
  type        = string
  default     = ""
}

variable "supertokens_pg_uri" {
  description = "supertoken postgres uri"
  sensitive   = true
  type        = string
  default     = ""
}
