variable "environment" {
  description = "workspace environment"
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Allowed values for input_parameter are \"dev\", \"stage\", or \"prod\"."
  }
}

variable "name" {
  type        = string
  description = "iam role name"
}

variable "attach_ecs_task_policy" {
  type    = bool
  default = false
}

variable "attach_ssm_secret_access_policy" {
  type    = bool
  default = false
}

variable "attach_s3_access_policy" {
  type    = bool
  default = false
}

variable "ssm_secret_arns" {
  type    = list(string)
  default = []
}

variable "allowed_s3_buckets_arns" {
  type    = list(string)
  default = []
}

variable "attach_ecs_debug_policy" {
  type    = bool
  default = false
}

variable "role_type" {
  description = "the role for which type of user"
  validation {
    condition     = contains(["lamda", "ecs", "prod"], var.role_type)
    error_message = "Allowed values for input_parameter are \"lamda\", \"ecs\"."
  }
}
