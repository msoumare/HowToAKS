terraform {
  backend "azurerm" {
    key                  = "dev.ne.terraform.tfstate"
  }
}
