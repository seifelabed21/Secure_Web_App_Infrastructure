provider "azurerm" {
  # Uses current az login context unless optional override variables are set.
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}