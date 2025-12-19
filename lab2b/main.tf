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

#############################
# Resource Group with Tags
#############################

resource "azurerm_resource_group" "rg2" {
  name     = "az104-rg2"
  location = "East US"

  tags = {
    "Cost Center" = "000"
  }
}

#############################
# Policy: Require Tag
#############################

data "azurerm_policy_definition" "require_tag" {
  display_name = "Require a tag and its value on resources"
}

resource "azurerm_resource_group_policy_assignment" "require_tag_assignment" {
  name                 = "Require-Cost Center"
  resource_group_id    = azurerm_resource_group.rg2.id
  policy_definition_id = data.azurerm_policy_definition.require_tag.id

  parameters = jsonencode({
    tagName  = { value = "Cost Center" }
    tagValue = { value = "000" }
  })
}

#############################
# Policy: Inherit Tag
#############################

data "azurerm_policy_definition" "inherit_tag" {
  display_name = "Inherit a tag from the resource group if missing"
}

resource "azurerm_resource_group_policy_assignment" "inherit_tag_assignment" {
  name                 = "Inherit-Cost Center"
  resource_group_id    = azurerm_resource_group.rg2.id
  policy_definition_id = data.azurerm_policy_definition.inherit_tag.id
  location             = azurerm_resource_group.rg2.location  # <- обов'язково для identity

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode({
    tagName = { value = "Cost Center" }
  })
}

#############################
# Resource Group Lock
#############################

resource "azurerm_management_lock" "rg_lock" {
  name       = "rg-lock"
  scope      = azurerm_resource_group.rg2.id
  lock_level = "CanNotDelete"
  notes      = "Prevents resource group deletion"
}

#############################
# Outputs
#############################

output "resource_group_id" {
  value = azurerm_resource_group.rg2.id
}

output "require_tag_policy" {
  value = azurerm_resource_group_policy_assignment.require_tag_assignment.id
}

output "inherit_tag_policy" {
  value = azurerm_resource_group_policy_assignment.inherit_tag_assignment.id
}

output "lock_id" {
  value = azurerm_management_lock.rg_lock.id
}
