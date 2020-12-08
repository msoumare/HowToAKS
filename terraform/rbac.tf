resource azurerm_role_assignment aks_cluster_user_role {

  for_each = data.azuread_groups.groups.object_ids
  scope                = azurerm_kubernetes_cluster.aks_cluster.id
  role_definition_name = "AKS Cluster User Role"
  principal_id         = each.value
}
