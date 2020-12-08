variable "app_gateway_public_ip_name" {
  description = "App Gateway Public Ip Name."
  default     = "agw-public-ip"
}

variable "app_gateway_public_ip_address_allocation" {
  description = "App Gateway Public Ip Address Allocation Type."
  default     = "Static"
}

variable "app_gateway_public_ip_sku" {
  description = "App Gateway Public Ip Sku."
  default     = "Standard"
}

variable "app_gateway_name" {
  description = "App Gateway Name."
  default     = "dev-ne-agw-terraform"
}

variable "app_gateway_sku" {
  description = "Name of the Application Gateway SKU."
  default     = "Standard_v2"
}

variable "app_gateway_tier" {
  description = "Tier of the Application Gateway SKU."
  default     = "Standard_v2"
}

variable "app_gateway_min_capacity" {
  description = "Application Gateway Minimun Capacity."
  default     = 2
}

variable "app_gateway_max_capacity" {
  description = "Application Gateway Maximum Capacity."
  default     = 10
}
