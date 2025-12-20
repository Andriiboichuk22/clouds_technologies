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
    name     = "az104-rg9b"
    location = "East US"
    }
    resource "azurerm_container_group" "aci" {
    name                = "az104-c1"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    os_type             = "Linux"
    dns_name_label      = "myuniqueaciboychuklab"
    restart_policy      = "Always"

    container {
        name   = "hello-world"
        image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
        cpu    = "0.5"
        memory = "1.0"

        ports {
        port     = 80
        protocol = "TCP"
        }
    }

    tags = {
        environment = "lab"
    }
    }