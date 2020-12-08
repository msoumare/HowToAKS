resource "azurerm_public_ip" "publicIpAddressNameBuildAgent" {
  name                    = var.publicIpAddressNameBuildAgent
  resource_group_name     = var.resource_group
  location                = var.azure_region
  allocation_method       = var.publicIpAddressTypeBuildAgent
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "networkInterfaceNameBuildAgent" {
  name                = var.networkInterfaceNameBuildAgent
  resource_group_name = var.resource_group
  location            = var.azure_region

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnetManagement.id
    private_ip_address_allocation = "Dynamic"
     public_ip_address_id          = azurerm_public_ip.publicIpAddressNameBuildAgent.id
  }
}

resource "azurerm_windows_virtual_machine" "virtualMachineNameBuildAgent" {
  name                            = var.virtualMachineNameBuildAgent
  resource_group_name             = var.resource_group
  location                        = var.azure_region
  size                            = "Standard_DS2_v2"
  admin_username                  = "msoumare"
  admin_password                  = data.azurerm_key_vault_secret.adminPassword.value
  availability_set_id             = azurerm_availability_set.availabilitySetNameBuildAgent.id   
  depends_on                      =  [azurerm_network_interface.networkInterfaceNameBuildAgent, azurerm_storage_account.diagnosticsStorageAccountNameBuildAgent, azurerm_availability_set.availabilitySetName]   
  network_interface_ids = [
    azurerm_network_interface.networkInterfaceNameBuildAgent.id,
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_disk {
    
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }

    boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diagnosticsStorageAccountNameBuildAgent.primary_blob_endpoint
  }
}

resource "azurerm_storage_account" "diagnosticsStorageAccountNameBuildAgent" {
  name                            = var.diagnosticsStorageAccountNameBuildAgent
  resource_group_name             = var.resource_group
  location                        = var.azure_region
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "Storage"
}

resource "azurerm_availability_set" "availabilitySetNameBuildAgent" {
  name                            = var.availabilitySetNameBuildAgent
  resource_group_name             = var.resource_group
  location                        = var.azure_region
  platform_fault_domain_count    = 2
  platform_update_domain_count    = 5
}
