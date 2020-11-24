terraform {
  required_providers {
    azurerm = {
        version = "~> 2.37.0"
    }
    azuread = {
        version = "~> 1.0.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "value"

}