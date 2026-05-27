terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100.0, < 4.0.0"
    }
  }
}

locals {
  dns_zones = distinct(length(var.private_dns_zones) > 0 ? var.private_dns_zones : [
    "privatelink.api.azureml.ms",
    "privatelink.notebooks.azure.net",
    "privatelink.cognitiveservices.azure.com",
    "privatelink.openai.azure.com",
    "privatelink.blob.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.queue.core.windows.net",
    "privatelink.table.core.windows.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.azurecr.io",
    "privatelink.monitor.azure.com",
    "privatelink.oms.opinsights.azure.com",
    "privatelink.ods.opinsights.azure.com"
  ])

  linked_vnets = merge({ hub = var.hub_vnet_id }, var.spoke_vnet_ids)
}

resource "azurerm_private_dns_zone" "this" {
  for_each = toset(local.dns_zones)

  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = {
    for pair in flatten([
      for zone_key, zone in azurerm_private_dns_zone.this : [
        for vnet_key, vnet_id in local.linked_vnets : {
          key                = "${zone_key}.${vnet_key}"
          zone_name          = zone.name
          virtual_network_id = vnet_id
        }
      ]
    ]) : pair.key => pair
  }

  name                  = format("%s-link", replace(each.key, ".", "-"))
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.zone_name
  virtual_network_id    = each.value.virtual_network_id
  registration_enabled  = false
  tags                  = var.tags
}
