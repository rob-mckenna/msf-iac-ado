data "terraform_remote_state" "landing_zone" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.landing_zone_state_resource_group_name
    storage_account_name = var.landing_zone_state_storage_account_name
    container_name       = var.landing_zone_state_container_name
    key                  = var.landing_zone_state_key
  }
}

locals {
  location_token              = replace(lower(var.location), " ", "")
  subnet_id                   = var.private_endpoint_subnet_id != "" ? var.private_endpoint_subnet_id : data.terraform_remote_state.landing_zone.outputs.private_endpoint_subnet_id
  storage_account_name        = substr(replace(format("%safsa%s%s001", var.project_name, var.environment, local.location_token), "-", ""), 0, 24)
  container_registry_name     = substr(replace(format("%safacr%s%s001", var.project_name, var.environment, local.location_token), "-", ""), 0, 50)
  workspace_key_vault_name    = var.workspace_key_vault_name != "" ? var.workspace_key_vault_name : format("%s-aifoundry-kv-%s-%s-001", var.project_name, var.environment, local.location_token)
  cognitive_account_name      = substr(replace(format("%safoai%s%s001", var.project_name, var.environment, local.location_token), "-", ""), 0, 24)
  cognitive_subdomain_name    = substr(replace(format("%s-ai-%s-%s-001", var.project_name, var.environment, local.location_token), "-", ""), 0, 24)
  cognitive_private_dns_zones = lower(var.cognitive_account_kind) == "openai" ? [data.terraform_remote_state.landing_zone.outputs.private_dns_zone_ids["privatelink.openai.azure.com"]] : [data.terraform_remote_state.landing_zone.outputs.private_dns_zone_ids["privatelink.cognitiveservices.azure.com"]]
}

resource "azurerm_resource_group" "this" {
  name     = var.ai_foundry_resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "this" {
  name                              = local.storage_account_name
  resource_group_name               = azurerm_resource_group.this.name
  location                          = azurerm_resource_group.this.location
  account_tier                      = "Standard"
  account_replication_type          = var.storage_replication_type
  min_tls_version                   = "TLS1_2"
  public_network_access_enabled     = false
  allow_nested_items_to_be_public   = false
  infrastructure_encryption_enabled = lower(var.environment) == "prod"
  tags                              = merge(var.tags, { workload = "ai-foundry" })
}

resource "azurerm_container_registry" "this" {
  name                          = local.container_registry_name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  sku                           = var.acr_sku
  public_network_access_enabled = false
  admin_enabled                 = false
  zone_redundancy_enabled       = var.acr_sku == "Premium" && lower(var.environment) == "prod"
  tags                          = merge(var.tags, { workload = "ai-foundry" })
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = format("%s-aifoundry-law-%s-%s-001", var.project_name, var.environment, local.location_token)
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.retention_in_days
  tags                = merge(var.tags, { workload = "ai-foundry" })
}

resource "azurerm_application_insights" "this" {
  name                = format("%s-aifoundry-appi-%s-%s-001", var.project_name, var.environment, local.location_token)
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
  tags                = merge(var.tags, { workload = "ai-foundry" })
}

module "workspace_key_vault" {
  source = "../../modules/key-vault"

  resource_group_name        = azurerm_resource_group.this.name
  location                   = azurerm_resource_group.this.location
  key_vault_name             = local.workspace_key_vault_name
  tenant_id                  = var.tenant_id
  sku_name                   = var.workspace_key_vault_sku_name
  subnet_id                  = local.subnet_id
  private_dns_zone_id        = data.terraform_remote_state.landing_zone.outputs.private_dns_zone_ids["privatelink.vaultcore.azure.net"]
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  purge_protection_enabled   = true
  soft_delete_retention_days = var.workspace_key_vault_soft_delete_retention_days
  rbac_authorization_enabled = true
  access_policies            = []
  role_assignments           = []
  tags                       = merge(var.tags, { workload = "ai-foundry" })
}

resource "azurerm_cognitive_account" "this" {
  name                          = local.cognitive_account_name
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  kind                          = var.cognitive_account_kind
  sku_name                      = var.cognitive_account_sku_name
  custom_subdomain_name         = local.cognitive_subdomain_name
  public_network_access_enabled = false
  local_auth_enabled            = false
  tags                          = merge(var.tags, { workload = "ai-foundry" })

  identity {
    type = "SystemAssigned"
  }
}

module "ai_foundry" {
  source = "../../modules/ai-foundry"

  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  workspace_name         = var.ai_foundry_workspace_name
  workspace_display_name = var.ai_foundry_workspace_display_name
  workspace_description  = var.ai_foundry_workspace_description
  workspace_sku_name     = var.workspace_sku_name
  workspace_sku_tier     = var.workspace_sku_tier
  subnet_id              = local.subnet_id
  private_dns_zone_ids = {
    workspace    = [data.terraform_remote_state.landing_zone.outputs.private_dns_zone_ids["privatelink.api.azureml.ms"], data.terraform_remote_state.landing_zone.outputs.private_dns_zone_ids["privatelink.notebooks.azure.net"]]
    storage_blob = [data.terraform_remote_state.landing_zone.outputs.private_dns_zone_ids["privatelink.blob.core.windows.net"]]
    storage_file = [data.terraform_remote_state.landing_zone.outputs.private_dns_zone_ids["privatelink.file.core.windows.net"]]
    keyvault     = [data.terraform_remote_state.landing_zone.outputs.private_dns_zone_ids["privatelink.vaultcore.azure.net"]]
    acr          = [data.terraform_remote_state.landing_zone.outputs.private_dns_zone_ids["privatelink.azurecr.io"]]
    cognitive    = local.cognitive_private_dns_zones
  }
  key_vault_id            = module.workspace_key_vault.key_vault_id
  storage_account_id      = azurerm_storage_account.this.id
  container_registry_id   = azurerm_container_registry.this.id
  application_insights_id = azurerm_application_insights.this.id
  cognitive_account_id    = azurerm_cognitive_account.this.id
  tags                    = merge(var.tags, { workload = "ai-foundry" })

  depends_on = [module.workspace_key_vault, azurerm_cognitive_account.this]
}

resource "azurerm_role_assignment" "workspace_storage_blob_contributor" {
  scope                            = azurerm_storage_account.this.id
  role_definition_name             = "Storage Blob Data Contributor"
  principal_id                     = module.ai_foundry.workspace_principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "workspace_acr_pull" {
  scope                            = azurerm_container_registry.this.id
  role_definition_name             = "AcrPull"
  principal_id                     = module.ai_foundry.workspace_principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "workspace_key_vault_secrets_user" {
  scope                            = module.workspace_key_vault.key_vault_id
  role_definition_name             = "Key Vault Secrets User"
  principal_id                     = module.ai_foundry.workspace_principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "workspace_cognitive_user" {
  scope                            = azurerm_cognitive_account.this.id
  role_definition_name             = lower(var.cognitive_account_kind) == "openai" ? "Cognitive Services OpenAI User" : "Cognitive Services User"
  principal_id                     = module.ai_foundry.workspace_principal_id
  skip_service_principal_aad_check = true
}
