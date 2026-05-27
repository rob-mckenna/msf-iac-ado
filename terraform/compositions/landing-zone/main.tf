module "networking" {
  source = "../../modules/networking"

  resource_group_name    = var.resource_group_name
  location               = var.location
  project_name           = var.project_name
  environment            = var.environment
  hub_vnet_address_space = var.hub_vnet_address_space
  hub_subnet_prefixes    = var.hub_subnet_prefixes
  firewall_sku_name      = var.firewall_sku_name
  firewall_sku_tier      = var.firewall_sku_tier
  firewall_zones         = var.firewall_zones
  enable_gateway_transit = var.enable_gateway_transit
  spoke_vnets            = var.spoke_vnets
  tags                   = var.tags
}

module "dns" {
  source = "../../modules/dns"

  resource_group_name = var.resource_group_name
  hub_vnet_id         = module.networking.hub_vnet_id
  spoke_vnet_ids      = module.networking.spoke_vnet_ids
  private_dns_zones   = var.private_dns_zones
  tags                = var.tags

  depends_on = [module.networking]
}

module "observability" {
  source = "../../modules/observability"

  resource_group_name          = var.resource_group_name
  location                     = var.location
  subscription_id              = var.subscription_id
  project_name                 = var.project_name
  environment                  = var.environment
  action_group_email_receivers = var.action_group_email_receivers
  log_analytics_sku            = var.log_analytics_sku
  retention_in_days            = var.retention_in_days
  tags                         = var.tags

  depends_on = [module.networking]
}

module "key_vault" {
  source = "../../modules/key-vault"

  resource_group_name        = var.resource_group_name
  location                   = var.location
  key_vault_name             = var.key_vault_name
  tenant_id                  = var.tenant_id
  sku_name                   = var.key_vault_sku_name
  subnet_id                  = module.networking.spoke_subnet_ids[var.private_endpoint_spoke_key][var.private_endpoint_subnet_key]
  private_dns_zone_id        = module.dns.private_dns_zone_ids["privatelink.vaultcore.azure.net"]
  log_analytics_workspace_id = module.observability.log_analytics_workspace_id
  purge_protection_enabled   = var.key_vault_purge_protection_enabled
  soft_delete_retention_days = var.key_vault_soft_delete_retention_days
  rbac_authorization_enabled = var.key_vault_rbac_authorization_enabled
  access_policies            = var.key_vault_access_policies
  role_assignments           = var.key_vault_role_assignments
  tags                       = var.tags

  depends_on = [module.networking, module.dns, module.observability]
}

module "policy" {
  source = "../../modules/policy"

  subscription_id                = var.subscription_id
  location                       = var.location
  policy_prefix                  = format("%s-%s", var.project_name, var.environment)
  environment_tier               = var.environment
  allowed_locations              = var.allowed_locations
  required_tags                  = var.required_tags
  policy_effect_overrides        = var.policy_effect_overrides
  assignment_enforcement_enabled = var.assignment_enforcement_enabled
}
