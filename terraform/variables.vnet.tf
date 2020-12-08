variable "virtualNetworkName" {
    type = string
    default = "dev-ne-vnt-terraform"
}

variable "virtualNetworkAddressSpace" {
    type = list(string)
}

variable "subnetAzureKubernetesService" {
    type = string
    default = "dev-ne-snt-aks-terraform"
}

variable "subnetAzureKubernetesServiceAddressRange" {
    type = string
}

variable "subnetApplicationGateway" {
    type = string
    default = "dev-ne-snt-agw-terraform"
}

variable "subnetApplicationGatewayAddressRange" {
    type = string
}

variable "subnetManagement" {
    type = string
    default = "dev-ne-snt-management-terraform"
}

variable "subnetManagementAddressRange" {
    type = string
}

variable "networkSecurityGroupManagement" {
    type = string
    default = "dev-ne-nsg-management-terraform"
}

variable "subnetBastion" {
    type = string
    default = "AzureBastionSubnet"
}

variable "subnetBastionAddressRange" {
    type = string
}

variable "publicIpAddressForBastion" {
    type = string
    default = "dev-ne-pip-bastion-terraform"
}

variable "networkSecurityGroupBastion" {
    type = string
    default= "dev-ne-nsg-bastion-terraform"
}

variable "hostBastion" {
    type = string
    default = "dev-ne-bastion-terraform"
}
