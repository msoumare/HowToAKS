# Variable Service Principal clientID
variable "azure_region" {
  type = string
  description = ""
}

variable "resource_group" {
  type = string
  description = ""
}

variable "acr_name" {
  type = string
  description = ""
}

variable "keyvault_rg" {
  type    = string
}
variable "keyvault_name" {
  type    = string
}
