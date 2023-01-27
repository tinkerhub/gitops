variable "environment" {
  description = "workspace environment"
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Allowed values for input_parameter are \"dev\", \"stage\", or \"prod\"."
  }
}

variable "create_secrets" {
  description = "secret to be created in ssm for given env"
  sensitive   = true
  type        = map(object({ type = string, description = optional(string), value = string }))
  default     = null
}

variable "load_secrets" {
  description = "secret to be loaded to share"
  type        = set(string)
  default     = []
}
