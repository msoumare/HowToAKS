# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=2.29.0"
  features {}
}

provider "azuread" {
  version = ">= 0.6"
}
