# Create an Azure Identity with Managed Identity (User Assigned)  
# This identity will be used by AGIC to perform updates on the Application Gateway and in it's Resource Group
resource "azurerm_user_assigned_identity" "app_gateway_managed_identity" {
  resource_group_name = var.resource_group
  location            = var.azure_region
  name                = var.app_gateway_managed_identity
}

# Give the new Azure Identity "Contributor" role to your Application Gateway
resource "azurerm_role_assignment" "app_gateway_managed_identity_contributor" {
  scope                = azurerm_application_gateway.app_gateway.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.app_gateway_managed_identity.principal_id
}

# Give the new Azure Identity "Reader" role to the Application Gateway resource group
resource "azurerm_role_assignment" "app_gateway_managed_identity_reader" {
  scope                = var.cluster_resource_group_id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.app_gateway_managed_identity.principal_id
}

provider "helm" {
   kubernetes {
    load_config_file  = true
    config_context  = var.cluster_name  
  } 
}

resource "helm_release" "agw_ingress" {
  name       = "application-gateway-kubernetes-ingress"
  repository = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"
  chart      = "ingress-azure"
  version    = "1.2.1"
  values = [
    templatefile("helm-agic-config.yaml",
      {
        subscriptionId = var.subscription_id
        resourceGroup = var.resource_group
        applicationGatewayName = var.app_gateway_name
        identityResourceID = azurerm_user_assigned_identity.app_gateway_managed_identity.id
        identityClientID = azurerm_user_assigned_identity.app_gateway_managed_identity.client_id
  })]
}
