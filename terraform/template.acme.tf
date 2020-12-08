resource "azurerm_storage_account" "acmeStorageAccount" {
  name                            = var.acmeStorageAccountName
  resource_group_name             = var.resource_group
  location                        = var.azure_region
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "Storage"
}

resource "azurerm_app_service_plan" "acmeAppServicePlan" {
  name                            = var.acmeAppServicePlanName
  resource_group_name             = var.resource_group
  location                        = var.azure_region
  kind                            = "FunctionApp"

  sku {
      tier = "Dynamic"
      size = "Y1"
  }
}

resource "azurerm_application_insights" "acmeApplicationInsights" {
  name                            = var.acmeApplicationInsightsName
  resource_group_name             = var.resource_group
  location                        = var.azure_region
  application_type                = "web"
}

resource "azurerm_function_app" "acmeFunctionApp" {
  name                            = var.acmeFunctionAppName
  resource_group_name             = var.resource_group
  location                        = var.azure_region
  app_service_plan_id             = azurerm_app_service_plan.acmeAppServicePlan.id
  storage_account_name            = azurerm_storage_account.acmeStorageAccount.name
  storage_account_access_key      = azurerm_storage_account.acmeStorageAccount.primary_access_key

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = "InstrumentationKey=${azurerm_application_insights.acmeApplicationInsights.instrumentation_key};EndpointSuffix=applicationinsights.azure.com"
    AzureWebJobsStorage = "${azurerm_storage_account.acmeStorageAccount.primary_connection_string}"
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = "${azurerm_storage_account.acmeStorageAccount.primary_connection_string}"
    WEBSITE_CONTENTSHARE = var.acmeFunctionAppName
    WEBSITE_RUN_FROM_PACKAGE = "https://shibayan.blob.core.windows.net/azure-keyvault-letsencrypt/v3/latest.zip"
    FUNCTIONS_EXTENSION_VERSION = "~3"
    FUNCTIONS_WORKER_RUNTIME = "dotnet"
    "Acmebot:AzureDns:SubscriptionId" = "your-subscription-id"
    "Acmebot:Contacts" = "your-email-address"
    "Acmebot:Endpoint" = "https://acme-v02.api.letsencrypt.org/"
    "Acmebot:VaultBaseUrl" = "https://dev-ne-kv-terraform.vault.azure.net/"
    "Acmebot:Environment" = "AzureCloud"                                        
  }

  identity { 
    type = "SystemAssigned" 
  }

  auth_settings {
  enabled                       = true
  issuer                        = "https://sts.windows.net/your-tenant-id"
  default_provider              = "AzureActiveDirectory"
  unauthenticated_client_action = "RedirectToLoginPage"

      active_directory {
      client_id     = azuread_application.acmeAzureAdApplication.application_id
    }
  }
}

resource "azuread_application" "acmeAzureAdApplication" {
  name                            = var.acmeAzureAdApplicationName
  identifier_uris                 = [var.acmeFunctionHostName]
  reply_urls                      = [var.acmeAzureAdAppReplyUrl]
}

resource "azurerm_key_vault_access_policy" "example" {
  key_vault_id = var.key_vault_id
  tenant_id = "your-tenant-id"
  object_id = "${azurerm_function_app.acmeFunctionApp.identity.0.principal_id}"

  certificate_permissions  = [
    "get", "list", "update", "create", "import", "delete", "recover", "backup", "restore", "managecontacts", "manageissuers", "getissuers", "listissuers", "setissuers", "deleteissuers", "purge", "get"
  ]
}
