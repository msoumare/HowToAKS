

variable "log_analytics_workspace_name" {
  description = "Resource name of the Log Analytics workspace"
  type        = string
  default     = "dev-ne-lgaws-terraform"
}

variable "log_analytics_workspace_sku" {
  description = "The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "The retention period for the logs in days"
  type        = number
  default     = 30
}

variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
  default     = "dev-ne-aks-terraform"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.16.13"
}

variable "container_registry_id" {
  description = "Resource id of the ACR"
  type        = string
}

variable "admin_username" {
  description = "Name of the Azure AD group for cluster-admin access"
  type        = string
  default = "msoumare"
}

variable "private_cluster" {
  description = "Deploy an AKS cluster without a public accessible API endpoint."
  type        = bool
  default     = false
}

variable "default_node_pool_name" {
    description = ""
    type        = string
    default     = "agentpool"
}

variable "default_node_pool_node_count" {
    description = ""  
    type        = number
    default     = 3
}

variable "default_node_pool_vm_size" {
    description = ""  
    type        = string
    default     = "Standard_DS2_v2"
}

variable "oms_agent_enabled" {
    description = ""  
    type        = bool
    default     = true
}

variable "kubernetes_dashboard_enabled" {
    description = ""  
    type        = bool
    default     = true
}

variable "adminGroupObjectIDs" {
    description = ""  
    type        = string
}

variable "cluster_resource_group_id" {
    description = ""  
    type        = string
}

variable "nodes_resource_group_id" {
    description = ""  
    type        = string
}

variable "resource_group_nodes" {
    description = ""  
    type        = string
}
