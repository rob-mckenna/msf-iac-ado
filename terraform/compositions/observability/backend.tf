terraform {
  backend "azurerm" {
    resource_group_name  = "replace-with-tfstate-rg"
    storage_account_name = "replacewithtfstate"
    container_name       = "tfstate"
    key                  = "observability.sandbox.tfstate"
  }
}
