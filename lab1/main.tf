terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.49.0"
    }
  }
}

provider "azuread" {}

# -------------------------------
# 1. User
# -------------------------------
resource "azuread_user" "az104_user1" {
  user_principal_name   = "az104-user1@andriyboychuk50gmail.onmicrosoft.com"
  display_name          = "az104-user1"
  mail_nickname         = "az104-user1"
  password              = "Qwerty123!"
  force_password_change = false
  job_title             = "IT Lab Administrator"
  department            = "IT"
  usage_location        = "US"
}

# -------------------------------
# 2. Security Group
# -------------------------------
resource "azuread_group" "it_lab_admins" {
  display_name     = "IT Lab Administrators"
  security_enabled = true
  description      = "Administrators that manage the IT lab"
}

# -------------------------------
# 3. Add user to group
# -------------------------------
resource "azuread_group_member" "it_lab_admins_members" {
  group_object_id  = azuread_group.it_lab_admins.id
  member_object_id = azuread_user.az104_user1.id
}

# -------------------------------
# 4. Role assignment (User Administrator)
# -------------------------------
resource "azuread_directory_role" "user_admin" {
  display_name = "User Administrator"
}

resource "azuread_directory_role_assignment" "assign_user_admin" {
  role_id             = azuread_directory_role.user_admin.template_id
  principal_object_id = azuread_user.az104_user1.id
}

# -------------------------------
# Outputs
# -------------------------------
output "created_user" {
  value = azuread_user.az104_user1.user_principal_name
}

output "group_name" {
  value = azuread_group.it_lab_admins.display_name
}

output "role_assignment" {
  value = "User az104-user1 assigned to 'User Administrator' role"
}
