locals {
    backend_address_pool_name      = "${azurerm_virtual_network.virtualNetworkName.name}-beap"
    frontend_port_name             = "${azurerm_virtual_network.virtualNetworkName.name}-feport"
    frontend_ip_configuration_name = "${azurerm_virtual_network.virtualNetworkName.name}-feip"
    http_setting_name              = "${azurerm_virtual_network.virtualNetworkName.name}-be-htst"
    listener_name                  = "${azurerm_virtual_network.virtualNetworkName.name}-httplstn"
    request_routing_rule_name      = "${azurerm_virtual_network.virtualNetworkName.name}-rqrt"
}

resource "azurerm_public_ip" "app_gateway_public_ip" {
  name                         = var.app_gateway_public_ip_name
  location                     = var.azure_region
  resource_group_name          = var.resource_group
  allocation_method            = var.app_gateway_public_ip_address_allocation
  sku                          = var.app_gateway_public_ip_sku
}

resource "azurerm_application_gateway" "app_gateway" {
  name                = var.app_gateway_name
  resource_group_name = var.resource_group
  location            = var.azure_region

  sku {
    name = var.app_gateway_sku
    tier = var.app_gateway_tier
  }

  autoscale_configuration {
    min_capacity = var.app_gateway_min_capacity
    max_capacity = var.app_gateway_max_capacity
  }

  gateway_ip_configuration {
    name      = azurerm_subnet.subnetApplicationGateway.name
    subnet_id = azurerm_subnet.subnetApplicationGateway.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = "https_port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.app_gateway_public_ip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
