data "terraform_remote_state" "landing_zone" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.landing_zone_state_resource_group_name
    storage_account_name = var.landing_zone_state_storage_account_name
    container_name       = var.landing_zone_state_container_name
    key                  = var.landing_zone_state_key
  }
}

data "azurerm_client_config" "current" {}

locals {
  subnet_id     = var.apim_subnet_id != "" ? var.apim_subnet_id : data.terraform_remote_state.landing_zone.outputs.private_endpoint_subnet_id
  tenant_id     = var.platform_tenant_id != "" ? var.platform_tenant_id : data.azurerm_client_config.current.tenant_id
  redirect_uris = length(var.redirect_uris) > 0 ? var.redirect_uris : [format("%s/signin-aad/callback", module.apim.apim_gateway_url)]
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "entra" {
  source = "../../modules/entra"

  application_name = var.application_name
  api_scopes       = var.api_scopes
  redirect_uris    = local.redirect_uris
  owners           = var.owners
  tags             = var.tags
}

module "apim" {
  source = "../../modules/apim"

  resource_group_name                  = azurerm_resource_group.this.name
  location                             = azurerm_resource_group.this.location
  apim_name                            = var.apim_name
  sku_name                             = var.sku_name
  publisher_name                       = var.publisher_name
  publisher_email                      = var.publisher_email
  subnet_id                            = local.subnet_id
  app_insights_id                      = data.terraform_remote_state.landing_zone.outputs.app_insights_id
  app_insights_instrumentation_key     = data.terraform_remote_state.landing_zone.outputs.app_insights_instrumentation_key
  platform_app_client_id               = module.entra.client_id
  platform_tenant_id                   = local.tenant_id
  openai_api_version                   = var.openai_api_version
  semantic_cache_ttl_seconds           = var.semantic_cache_ttl_seconds
  mcp_tool_discovery_cache_ttl_seconds = var.mcp_tool_discovery_cache_ttl_seconds
  azure_openai_backends                = var.azure_openai_backends
  content_safety                       = var.content_safety
  mcp_tool_catalog                     = var.mcp_tool_catalog
  tags                                 = var.tags
}
