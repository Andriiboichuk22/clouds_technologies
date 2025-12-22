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
  name     = "az104-rg9c"
  location = "East US"
}

resource "azurerm_container_app_environment" "env" {
  name                = "my-environment"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_container_app" "app" {
  name                        = "my-app-boychuklab"
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.env.id
  revision_mode                = "Single"
  
  ingress {
    external_enabled = true
    target_port      = 80
    
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
  
  template {
    container {
      name   = "hello-world"
      image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
      cpu    = 0.5
      memory = "1.0Gi"
    }

    min_replicas = 1
    max_replicas = 2
  }
}