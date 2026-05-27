terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100.0, < 4.0.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.13.0, < 2.0.0"
    }
  }
}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

locals {
  location_token         = replace(lower(var.location), " ", "")
  workspace_display_name = var.workspace_display_name != "" ? var.workspace_display_name : var.workspace_name
  workspace_description  = var.workspace_description != "" ? var.workspace_description : "Network isolated Azure AI Foundry hub workspace."
  project_display_name   = format("%s Project", local.workspace_display_name)

  private_endpoint_targets = {
    workspace = {
      name               = format("%s-ws", var.workspace_name)
      target_resource_id = azapi_resource.workspace.id
      subresource_names  = ["amlworkspace"]
      dns_zone_ids       = lookup(var.private_dns_zone_ids, "workspace", [])
    }
    storage_blob = {
      name               = format("%s-stg-blob", var.workspace_name)
      target_resource_id = var.storage_account_id
      subresource_names  = ["blob"]
      dns_zone_ids       = lookup(var.private_dns_zone_ids, "storage_blob", [])
    }
    storage_file = {
      name               = format("%s-stg-file", var.workspace_name)
      target_resource_id = var.storage_account_id
      subresource_names  = ["file"]
      dns_zone_ids       = lookup(var.private_dns_zone_ids, "storage_file", [])
    }
    keyvault = {
      name               = format("%s-kv", var.workspace_name)
      target_resource_id = var.key_vault_id
      subresource_names  = ["vault"]
      dns_zone_ids       = lookup(var.private_dns_zone_ids, "keyvault", [])
    }
    acr = {
      name               = format("%s-acr", var.workspace_name)
      target_resource_id = var.container_registry_id
      subresource_names  = ["registry"]
      dns_zone_ids       = lookup(var.private_dns_zone_ids, "acr", [])
    }
    cognitive = {
      name               = format("%s-cog", var.workspace_name)
      target_resource_id = var.cognitive_account_id
      subresource_names  = ["account"]
      dns_zone_ids       = lookup(var.private_dns_zone_ids, "cognitive", [])
    }
  }
}

resource "azapi_resource" "workspace" {
  type                      = "Microsoft.MachineLearningServices/workspaces@2024-04-01-preview"
  name                      = var.workspace_name
  parent_id                 = data.azurerm_resource_group.this.id
  location                  = var.location
  schema_validation_enabled = false
  tags                      = var.tags

  identity {
    type = "SystemAssigned"
  }

  body = {
    kind = "Hub"
    sku = {
      name = var.workspace_sku_name
      tier = var.workspace_sku_tier
    }
    properties = {
      friendlyName        = local.workspace_display_name
      description         = local.workspace_description
      storageAccount      = var.storage_account_id
      keyVault            = var.key_vault_id
      containerRegistry   = var.container_registry_id
      applicationInsights = var.application_insights_id
      publicNetworkAccess = "Disabled"
    }
  }

  response_export_values = ["identity.principalId"]
}

resource "azapi_resource" "project" {
  type                      = "Microsoft.MachineLearningServices/workspaces/projects@2024-04-01-preview"
  name                      = format("%s-project", var.workspace_name)
  parent_id                 = azapi_resource.workspace.id
  schema_validation_enabled = false
  tags                      = var.tags

  body = {
    properties = {
      description = "AI Foundry project for solution workloads."
      displayName = local.project_display_name
    }
  }
}

resource "azurerm_private_endpoint" "this" {
  for_each = local.private_endpoint_targets

  name                = format("%s-%s-%s-001", substr(replace(var.workspace_name, "_", "-"), 0, 40), each.key, local.location_token)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = format("%s-%s-psc", substr(var.workspace_name, 0, 40), each.key)
    private_connection_resource_id = each.value.target_resource_id
    is_manual_connection           = false
    subresource_names              = each.value.subresource_names
  }

  dynamic "private_dns_zone_group" {
    for_each = length(each.value.dns_zone_ids) == 0 ? [] : [each.value]

    content {
      name                 = format("%s-%s-dns", substr(var.workspace_name, 0, 40), each.key)
      private_dns_zone_ids = each.value.dns_zone_ids
    }
  }
}
