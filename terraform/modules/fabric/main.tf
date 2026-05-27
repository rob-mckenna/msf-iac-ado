terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100.0, < 4.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.50.0, < 3.0.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.13.0, < 2.0.0"
    }
  }
}

locals {
  workspace_display_name = var.workspace_display_name != "" ? var.workspace_display_name : var.workspace_name
  lakehouse_map = {
    for lakehouse in var.lakehouses : lakehouse.name => lakehouse
  }
  capacity_admin_object_ids = [for admin in data.azuread_user.admins : admin.object_id]
}

data "azuread_user" "admins" {
  for_each            = toset(var.admin_members)
  user_principal_name = each.value
}

resource "azapi_resource" "capacity" {
  type                      = "Microsoft.Fabric/capacities@2024-01-01-preview"
  name                      = var.capacity_name
  parent_id                 = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  location                  = var.location
  schema_validation_enabled = false
  tags                      = var.tags

  body = {
    sku = {
      name = var.sku
      tier = "Fabric"
    }
    properties = {
      administration = {
        members = local.capacity_admin_object_ids
      }
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azapi_resource" "workspace" {
  type                      = "Microsoft.Fabric/workspaces@2023-11-01-preview"
  name                      = var.workspace_name
  parent_id                 = azapi_resource.capacity.id
  location                  = var.location
  schema_validation_enabled = false
  tags                      = var.tags

  body = {
    properties = {
      displayName = local.workspace_display_name
      description = var.workspace_description
      capacityId  = azapi_resource.capacity.id
    }
  }
}

resource "azapi_resource" "lakehouse" {
  for_each = local.lakehouse_map

  type                      = "Microsoft.Fabric/workspaces/lakehouses@2023-11-01-preview"
  name                      = each.value.name
  parent_id                 = azapi_resource.workspace.id
  location                  = var.location
  schema_validation_enabled = false
  tags                      = var.tags

  body = {
    properties = {
      displayName = each.value.display_name != "" ? each.value.display_name : each.value.name
      description = each.value.description
    }
  }
}

resource "azurerm_role_assignment" "capacity_contributor" {
  for_each             = data.azuread_user.admins
  scope                = azapi_resource.capacity.id
  role_definition_name = "Contributor"
  principal_id         = each.value.object_id
}
