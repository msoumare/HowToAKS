
resource "azurerm_virtual_network" "virtualNetworkName" {
  name                = var.virtualNetworkName
  resource_group_name = var.resource_group
  location            = var.azure_region
  address_space       = var.virtualNetworkAddressSpace
  depends_on          = [azurerm_network_security_group.networkSecurityGroupBastion, azurerm_network_security_group.networkSecurityGroupManagement] 
} 

resource "azurerm_subnet" "subnetAzureKubernetesService" {
  name                 = var.subnetAzureKubernetesService
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.virtualNetworkName.name
  address_prefix       = var.subnetAzureKubernetesServiceAddressRange
}

resource "azurerm_subnet" "subnetApplicationGateway" {
  name                 = var.subnetApplicationGateway
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.virtualNetworkName.name
  address_prefix       = var.subnetApplicationGatewayAddressRange
}

resource "azurerm_subnet" "subnetManagement" {
  name                 = var.subnetManagement
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.virtualNetworkName.name
  address_prefix       = var.subnetManagementAddressRange
}

resource "azurerm_subnet" "subnetBastion" {
  name                 = var.subnetBastion
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.virtualNetworkName.name
  address_prefix       = var.subnetBastionAddressRange
}

resource "azurerm_public_ip" "publicIpAddressForBastion" {
  name                = var.publicIpAddressForBastion
  resource_group_name = var.resource_group
  location            = var.azure_region
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "hostBastion" {
  name                = var.hostBastion
  resource_group_name = var.resource_group
  location            = var.azure_region
  depends_on          =  [azurerm_virtual_network.virtualNetworkName, azurerm_public_ip.publicIpAddressForBastion]
  ip_configuration {
    name                 = "IpConf"
    subnet_id            = azurerm_subnet.subnetBastion.id
    public_ip_address_id = azurerm_public_ip.publicIpAddressForBastion.id
  }
}

resource "azurerm_network_security_group" "networkSecurityGroupBastion" {
  name                = var.networkSecurityGroupBastion
  resource_group_name = var.resource_group
  location            = var.azure_region

  security_rule {
    name                       = "Allow_Inbound_GatewayManager"    
    description                = "Allow Ingress Traffic from Azure Bastion Gateway Manager"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
    access                     = "Allow"    
    priority                   = 100    
    direction                  = "Inbound"    
  }

  security_rule {
    name                       = "Allow_Inbound_AzureCloud"
    description                = "Allow Inbound from AzureCloud"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureCloud"
    destination_address_prefix = "*"
    access                     = "Allow"    
    priority                   = 110    
    direction                  = "Inbound"  
  }

  security_rule {
    name                       = "Allow_Https_Inbound"
    description                = "Allow Https through port 443 from the Internet"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    access                     = "Allow"    
    priority                   = 120    
    direction                  = "Inbound"  
  }

  security_rule {
    name                       = "Allow_SSH_Outbound"
    description                = "Egress Traffic to target VMs: Azure Bastion will reach the target VMs over private IP and SSH port"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
    access                     = "Allow"    
    priority                   = 100    
    direction                  = "Outbound"  
  }

  security_rule {
    name                       = "Allow_RDP_Outbound"
    description                = "Egress Traffic to target VMs: Azure Bastion will reach the target VMs over private IP and RDP port"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
    access                     = "Allow"    
    priority                   = 110    
    direction                  = "Outbound"  
  }

  security_rule {
    name                       = "Allow_OutBound_AzureCloud"
    description                = "Egress Traffic to other public endpoints in Azure"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
    access                     = "Allow"    
    priority                   = 120    
    direction                  = "Outbound"  
  }
}

resource "azurerm_network_security_group" "networkSecurityGroupManagement" {
  name                = var.networkSecurityGroupManagement
  resource_group_name = var.resource_group
  location            = var.azure_region

  security_rule {
    name                       = "Allow_RDP_SSH_From_AzureBastion"    
    description                = "Ingress Traffic from Azure Bastion"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     =  ["3389","22"]
    source_address_prefix      = var.subnetBastionAddressRange
    destination_address_prefix = "*"
    access                     = "Allow"    
    priority                   = 100    
    direction                  = "Inbound"    
  }
}
