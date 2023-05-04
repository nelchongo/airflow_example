#Twingate Variables
variable "network" {
  type = string
  default = "futurumsoft"
  description = "Twingate network for the application"
}

variable "tg_api_token" {
  type = string
  default = ""
  description = "Twingate application token"
  validation {
    condition = var.tg_api_token != null
    error_message = "Twingate token can not be null, please insert a token" 
  }
}