terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.8.0"
}

provider "azurerm" {
  features {}
  subscription_id = "b70e0794-43ef-42d4-befc-ca6562886a25"
  tenant_id       = "d8fef6eb-0f19-471e-9eb8-baa5d7764bca"
}

resource "azurerm_resource_group" "rg" {
  name     = "az104-rg3"
  location = "East US"
}

resource "azurerm_managed_disk" "disk1" {
  name                 = "az104-disk1"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32
}