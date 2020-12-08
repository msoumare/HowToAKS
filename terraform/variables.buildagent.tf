 variable "publicIpAddressNameBuildAgent" {
    type = string     
    default = "dev-ne-pip-vmbuildagent-terraform"
}

variable "publicIpAddressTypeBuildAgent" {
    type = string     
    default = "Dynamic"
}

variable "publicIpAddressSkuBuildAgent" {
    type = string    
    default ="Basic"
}

variable "networkInterfaceNameBuildAgent" {
    type = string
    default = "dev-ne-nic-vmbuildagent-terraform"
}

variable "virtualMachineNameBuildAgent" {
    type = string
    default = "dev-ne-vmba"
}

variable "availabilitySetNameBuildAgent" {
    type = string
    default = "dev-ne-avs-terraform"
}

variable "diagnosticsStorageAccountNameBuildAgent" {
    type = string
    default = "devnestavmbaterraform"
}
