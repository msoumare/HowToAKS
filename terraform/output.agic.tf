
output "app_gateway_managed_identity_resource_id" {
    value = azurerm_user_assigned_identity.app_gateway_managed_identity.id
}

output "app_gateway_managed_identity_client_id" {
    value = azurerm_user_assigned_identity.app_gateway_managed_identity.client_id
}
