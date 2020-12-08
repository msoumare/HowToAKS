variable "acmeStorageAccountName" {
    type = string
    default = "devnestaacmeterraform"
}

variable "acmeAppServicePlanName" {
    type = string
    default = "dev-ne-svcpl-acme-terraform"
}

variable "acmeApplicationInsightsName" {
    type = string
    default = "dev-ne-appins-acme-terraform"
}

variable "acmeAzureAdApplicationName" {
    type = string
    default = "dev-ne-aadapp-acme-terraform"
}

variable "acmeFunctionAppName" {
    type = string
    default = "dev-ne-fnapp-acme-terraform" 
}

variable "acmeFunctionHostName" {
    type = string
    default = "https://dev-ne-fnapp-acme-terraform.azurewebsites.net" 
}

variable "acmeAzureAdAppReplyUrl" {
    type = string
    default = "https://dev-ne-fnapp-acme-terraform.azurewebsites.net/.auth/login/aad/callback" 
}

variable "key_vault_id" {
    type = "string"
}
