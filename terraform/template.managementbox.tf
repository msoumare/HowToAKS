resource "azurerm_network_interface" "networkInterfaceNameManagement" {
  name                = var.networkInterfaceNameManagement
  resource_group_name = var.resource_group
  location            = var.azure_region

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnetManagement.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "virtualMachineNameManagement" {
  name                            = var.virtualMachineNameManagement
  resource_group_name             = var.resource_group
  location                        = var.azure_region
  size                            = "Standard_DS2_v2"
  admin_username                  = "msoumare"
  admin_password                  = data.azurerm_key_vault_secret.adminPassword.value
  availability_set_id             = azurerm_availability_set.availabilitySetName.id   
  depends_on                      =  [azurerm_network_interface.networkInterfaceNameManagement, azurerm_storage_account.diagnosticsStorageAccountNameManagement, azurerm_availability_set.availabilitySetName]   
  network_interface_ids = [
    azurerm_network_interface.networkInterfaceNameManagement.id,
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
    storage_account_uri = azurerm_storage_account.diagnosticsStorageAccountNameManagement.primary_blob_endpoint
  }
}

resource "azurerm_storage_account" "diagnosticsStorageAccountNameManagement" {
  name                            = var.diagnosticsStorageAccountNameManagement
  resource_group_name             = var.resource_group
  location                        = var.azure_region
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "Storage"
}

resource "azurerm_availability_set" "availabilitySetName" {
  name                            = var.availabilitySetName
  resource_group_name             = var.resource_group
  location                        = var.azure_region
  platform_fault_domain_count    = 2
  platform_update_domain_count    = 5
}
