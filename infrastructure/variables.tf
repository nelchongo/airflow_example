variable "app_name" {
  type        = string
  description = "Application Name"
  validation {
    condition     = length(regexall("^[a-z0-9]+$", var.app_name)) > 0
    error_message = "The application name can contain alphanumeric characters only."
  }
}

variable "tags" {
  type = object({
    env   = string
    app   = string
  })
  description = "Tags for the whole project, needed env and app"
}

variable "create_rds" {
  type        = bool
  default     = false
  description = "Boolean for RDS creation"
}

local {
    tags = var.tags
}