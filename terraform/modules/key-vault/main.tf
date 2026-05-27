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
  access_policy_map = {
    for policy in var.access_policies : policy.object_id => policy
  }

  role_assignment_map = {
    for assignment in var.role_assignments : "${assignment.principal_id}.${assignment.role_definition_name}" => assignment
  }
}

resource "azurerm_key_vault" "this" {
  name                          = var.key_vault_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = var.tenant_id
  sku_name                      = var.sku_name
  purge_protection_enabled      = var.purge_protection_enabled
  soft_delete_retention_days    = var.soft_delete_retention_days
  public_network_access_enabled = false
  enable_rbac_authorization     = var.rbac_authorization_enabled
  tags                          = var.tags

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  dynamic "access_policy" {
    for_each = var.rbac_authorization_enabled ? {} : local.access_policy_map

    content {
      tenant_id               = access_policy.value.tenant_id
      object_id               = access_policy.value.object_id
      secret_permissions      = access_policy.value.secret_permissions
      key_permissions         = access_policy.value.key_permissions
      certificate_permissions = access_policy.value.certificate_permissions
    }
  }
}

resource "azurerm_private_endpoint" "this" {
  name                = format("%s-pe", var.key_vault_name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = format("%s-psc", var.key_vault_name)
    private_connection_resource_id = azurerm_key_vault.this.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = format("%s-dns", var.key_vault_name)
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}

resource "azurerm_role_assignment" "this" {
  for_each = local.role_assignment_map

  scope                = azurerm_key_vault.this.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = format("%s-diag", var.key_vault_name)
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
