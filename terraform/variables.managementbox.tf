variable "networkInterfaceNameManagement" {
    type = string
    default = "dev-ne-nic-vmmgmtbox-terraform"
}

variable "virtualMachineNameManagement" {
    type = string
    default = "dev-ne-vmmgmt"
}

variable "availabilitySetName" {
    type = string
    default = "dev-ne-avs-terraform"
}

variable "diagnosticsStorageAccountNameManagement" {
    type = string
    default = "devnestavmmgmtterraform"
}
