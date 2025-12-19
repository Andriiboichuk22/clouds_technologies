terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.49.0"
    }
  }
  required_version = ">= 1.8.0"
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuread" {
  tenant_id = var.tenant_id
}

# -------------------------------
# 1. Management Group
# -------------------------------
resource "azurerm_management_group" "az104_mg1" {
  name         = "az104-mg1"
  display_name = "az104-mg1"
}

# -------------------------------
# 2. Azure AD Helpdesk Group
# -------------------------------
resource "azuread_group" "helpdesk" {
  display_name     = "Helpdesk"
  security_enabled = true
  mail_enabled     = false
}

# -------------------------------
# 3. Built-in Role Assignment (VM Contributor)
# -------------------------------
resource "azurerm_role_assignment" "helpdesk_vm_contributor" {
  scope                = azurerm_management_group.az104_mg1.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azuread_group.helpdesk.object_id
}

# -------------------------------
# 4. Custom RBAC Role (Support Request)
# -------------------------------
resource "azurerm_role_definition" "custom_support_request" {
  name        = "Custom Support Request"
  scope       = azurerm_management_group.az104_mg1.id
  description = "A custom contributor role for support requests."

  permissions {
    actions     = ["Microsoft.Support/*"]
    not_actions = ["Microsoft.Support/register/action"]
  }

  assignable_scopes = [
    azurerm_management_group.az104_mg1.id
  ]
}

resource "azurerm_role_assignment" "helpdesk_custom_support" {
  scope              = azurerm_management_group.az104_mg1.id
  role_definition_id = azurerm_role_definition.custom_support_request.role_definition_resource_id
  principal_id       = azuread_group.helpdesk.object_id
}

# -------------------------------
# 5. Outputs
# -------------------------------
output "helpdesk_group_id" {
  value = azuread_group.helpdesk.object_id
}

output "management_group_id" {
  value = azurerm_management_group.az104_mg1.name
}

output "vm_contributor_role_assignment" {
  value = "VM Contributor role assigned to Helpdesk group"
}

output "custom_support_role_assignment" {
  value = "Custom Support Request role assigned to Helpdesk group"
}
