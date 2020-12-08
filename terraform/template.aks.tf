resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = var.log_analytics_workspace_name
  location            = var.azure_region
  resource_group_name = var.resource_group
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_retention_in_days
}

resource "azurerm_log_analytics_solution" "log_analytics" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.log_analytics.location
  resource_group_name   = azurerm_log_analytics_workspace.log_analytics.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                            = var.cluster_name
  location                        = var.azure_region
  resource_group_name             = var.resource_group
  dns_prefix                      = var.cluster_name
  kubernetes_version              = var.kubernetes_version
  node_resource_group             = var.resource_group_nodes
  private_cluster_enabled         = var.private_cluster

linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = data.azurerm_key_vault_secret.ssh_public_key.value
    }
  }

  default_node_pool {
    name                  = var.default_node_pool_name
    orchestrator_version  = var.kubernetes_version
    node_count            = var.default_node_pool_node_count
    vm_size               = var.default_node_pool_vm_size
    type                  = "VirtualMachineScaleSets"
    max_pods              = 250
    os_disk_size_gb       = 128
    vnet_subnet_id        = azurerm_subnet.subnetAzureKubernetesService.id
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true

    azure_active_directory {
      managed = true
      admin_group_object_ids = [
        var.adminGroupObjectIDs
      ]
    }
  }

  addon_profile {
    oms_agent {
      enabled                    = var.oms_agent_enabled
      log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id
    }
    kube_dashboard {
      enabled = var.kubernetes_dashboard_enabled
    }
  }

  network_profile {
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
    network_plugin     = "azure"
    network_policy     = "azure"
    dns_service_ip     = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = "10.0.0.0/16"
  }
}

resource "azurerm_role_assignment" "aks_oms" {
  scope                = azurerm_kubernetes_cluster.aks_cluster.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.addon_profile[0].oms_agent[0].oms_agent_identity[0].object_id
}

resource "azurerm_role_assignment" "aks_subnet" {
  scope                = azurerm_subnet.subnetAzureKubernetesService.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id
}

resource "azurerm_role_assignment" "aks_acr" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "aks_rg_mio" {
  scope                = var.cluster_resource_group_id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "aks_rg_nodes_mio" {
  scope                = var.nodes_resource_group_id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "aks_rg_vmc" {
  scope                = var.nodes_resource_group_id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
}
