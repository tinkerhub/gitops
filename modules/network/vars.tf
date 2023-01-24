variable "environment" {
  description = "workspace environment"
  validation {
    condition     = contains(["dev", "stage", "prod", "shared"], var.environment)
    error_message = "Allowed values for input_parameter are \"dev\", \"stage\", or \"prod\"."
  }
}

variable "create_new_vpc" {
  type = bool
}

variable "vpc_id" {
  description = "if subnets using exisiting vpc id pass it here"
  type        = string
  default     = ""
}

variable "vpc_ipv4_cidr" {
  description = "vpc cidr range"
  type        = string
  default     = ""
}

variable "create_ig" {
  description = "should this create an ig for vpc"
  type        = bool
}

variable "public_subnets" {
  type    = list(object({ cidr : string, az : string }))
  default = []
}

variable "private_subnets" {
  type    = list(object({ cidr : string, az : string }))
  default = []
}


