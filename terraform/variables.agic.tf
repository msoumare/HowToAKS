variable "subscription_id" {
  description = "Subscription Id"
  type        = string
}

variable "app_gateway_managed_identity" {
  description = "Identity used by AKS to create rules on App Gateway"
  default     = "dev-ne-mid-aadagw-terraform"
}
