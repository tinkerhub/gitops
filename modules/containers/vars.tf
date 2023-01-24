variable "environment" {
  description = "workspace environment"
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Allowed values for input_parameter are \"dev\", \"stage\", or \"prod\"."
  }
}

variable "name" {
  type = string
}

variable "task_definition" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "exec_iam_role_arn" {
  type = string
}

variable "task_role_iam_role_arn" {
  type    = string
  default = null
}

variable "iam_policy_attachment" {
  type = any
}

variable "sg_ids" {
  type = set(string)
}

variable "subnets" {
  type = set(string)
}

variable "assign_public_ip" {
  type    = bool
  default = true
}

variable "service_discovery_arn" {
  type    = string
  default = null
}

variable "service_count" {
  type    = number
  default = 1
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "enable_exec_command" {
  type    = bool
  default = false
}

variable "load_balancers" {
  type    = list(object({ tg_arn = string, port = number, container_name = optional(string) }))
  default = []
}
