project_name                                   = "msf"
environment                                    = "prod"
location                                       = "centralus"
resource_group_name                            = "msf-platform-rg-prod-centralus-001"
ai_foundry_resource_group_name                 = "msf-aifoundry-rg-prod-centralus-001"
fabric_resource_group_name                     = "msf-fabric-rg-prod-centralus-001"
subscription_id                                = "/subscriptions/00000000-0000-0000-0000-000000000000"
tenant_id                                      = "00000000-0000-0000-0000-000000000000"
key_vault_name                                 = "msf-kv-prod-centralus-001"
ai_foundry_workspace_name                      = "msf-aifoundry-ws-prod-centralus-001"
fabric_workspace_name                          = "msf-fabric-ws-prod-centralus-001"
capacity_name                                  = "msf-fabric-cap-prod-centralus-001"
apim_name                                      = "msf-apim-prod-centralus-001"
application_name                               = "msf-apim-app-prod-centralus-001"
publisher_name                                 = "MSF Platform Engineering"
publisher_email                                = "platform@example.com"
sku_name                                       = "Premium_2"
sku                                            = "F64"
firewall_sku_tier                              = "Premium"
firewall_zones                                 = ["1", "2", "3"]
storage_replication_type                       = "GZRS"
acr_sku                                        = "Premium"
workspace_sku_name                             = "Basic"
workspace_sku_tier                             = "Basic"
cognitive_account_kind                         = "OpenAI"
cognitive_account_sku_name                     = "S0"
workspace_key_vault_sku_name                   = "premium"
workspace_key_vault_soft_delete_retention_days = 90
key_vault_sku_name                             = "premium"
key_vault_rbac_authorization_enabled           = true
key_vault_soft_delete_retention_days           = 90
key_vault_purge_protection_enabled             = true
private_endpoint_spoke_key                     = "platform"
private_endpoint_subnet_key                    = "private-endpoints"
landing_zone_state_resource_group_name         = "msf-tfstate-rg-prod-centralus-001"
landing_zone_state_storage_account_name        = "msftfstateprodcus001"
landing_zone_state_container_name              = "tfstate"
landing_zone_state_key                         = "landing-zone.prod.tfstate"
log_analytics_sku                              = "PerGB2018"
retention_in_days                              = 90
enable_gateway_transit                         = true

hub_vnet_address_space = ["10.30.0.0/22"]

hub_subnet_prefixes = {
  firewall     = "10.30.0.0/26"
  gateway      = "10.30.0.64/27"
  dns_resolver = "10.30.0.96/27"
}

spoke_vnets = {
  platform = {
    address_space = ["10.30.4.0/23"]
    subnets = {
      private-endpoints = {
        address_prefixes                          = ["10.30.4.0/24"]
        service_endpoints                         = ["Microsoft.Storage", "Microsoft.KeyVault"]
        private_endpoint_network_policies_enabled = false
      }
      integration = {
        address_prefixes  = ["10.30.5.0/24"]
        service_endpoints = ["Microsoft.Storage"]
        delegations = [{
          name                    = "aca-environment"
          service_delegation_name = "Microsoft.App/environments"
        }]
      }
    }
  }
  ai = {
    address_space       = ["10.30.6.0/23"]
    use_remote_gateways = true
    subnets = {
      workload = {
        address_prefixes = ["10.30.6.0/24"]
        nsg_rules = [{
          name                         = "allow-platform-https-inbound"
          priority                     = 130
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_address_prefixes      = ["10.30.5.0/24"]
          destination_address_prefixes = ["*"]
          destination_port_ranges      = ["443"]
          description                  = "Allow internal platform integrations to reach production AI endpoints over HTTPS."
        }]
      }
      training = {
        address_prefixes  = ["10.30.7.0/25"]
        service_endpoints = ["Microsoft.Storage"]
      }
      inferencing = {
        address_prefixes = ["10.30.7.128/25"]
      }
    }
  }
  data = {
    address_space       = ["10.30.8.0/23"]
    use_remote_gateways = true
    subnets = {
      analytics = {
        address_prefixes  = ["10.30.8.0/24"]
        service_endpoints = ["Microsoft.Storage"]
      }
      governance = {
        address_prefixes  = ["10.30.9.0/24"]
        service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      }
    }
  }
}

private_dns_zones = [
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
]

action_group_email_receivers = [
  {
    name          = "platform-ops"
    email_address = "platform-ops@example.com"
  },
  {
    name          = "service-owner"
    email_address = "service-owner@example.com"
  },
  {
    name          = "security-operations"
    email_address = "soc@example.com"
  }
]

key_vault_access_policies = []

key_vault_role_assignments = [
  {
    principal_id         = "33333333-3333-3333-3333-333333333333"
    role_definition_name = "Key Vault Administrator"
  },
  {
    principal_id         = "44444444-4444-4444-4444-444444444444"
    role_definition_name = "Key Vault Secrets Officer"
  }
]

admin_members = [
  "fabric.admin@example.com",
  "data.engineer@example.com",
  "platform.owner@example.com"
]

lakehouses = [
  {
    name         = "operationslh"
    display_name = "Operations Lakehouse"
    description  = "Operations-facing lakehouse for monitored platform telemetry and curated datasets."
  },
  {
    name         = "analyticslh"
    display_name = "Analytics Lakehouse"
    description  = "Curated enterprise analytics lakehouse for governed business data products."
  },
  {
    name         = "sciencelh"
    display_name = "Data Science Lakehouse"
    description  = "Feature engineering and experimentation lakehouse aligned to AI workloads."
  }
]

owners = [
  "33333333-3333-3333-3333-333333333333",
  "44444444-4444-4444-4444-444444444444"
]

api_scopes = [
  {
    value                      = "Reader.Access"
    admin_consent_display_name = "Read platform APIs"
    admin_consent_description  = "Allows read-only access to platform APIs."
    user_consent_display_name  = "Read platform APIs"
    user_consent_description   = "Allows read-only access to platform APIs."
    scope_type                 = "User"
  },
  {
    value                      = "Contributor.Access"
    admin_consent_display_name = "Contribute to platform APIs"
    admin_consent_description  = "Allows read and write access to platform APIs."
    user_consent_display_name  = "Contribute to platform APIs"
    user_consent_description   = "Allows read and write access to platform APIs."
    scope_type                 = "Admin"
  },
  {
    value                      = "Admin.Access"
    admin_consent_display_name = "Administer platform APIs"
    admin_consent_description  = "Allows administrative access to platform APIs."
    user_consent_display_name  = "Administer platform APIs"
    user_consent_description   = "Allows administrative access to platform APIs."
    scope_type                 = "Admin"
  }
]

required_tags = ["environment", "project", "owner", "cost-center", "managed-by", "created-date", "data-class", "business-criticality"]

tags = {
  environment            = "prod"
  project                = "msf"
  owner                  = "platform-engineering"
  "cost-center"          = "shared-services"
  "managed-by"           = "terraform"
  "created-date"         = "2026-05-27T07:18:33.309-04:00"
  "data-class"           = "confidential"
  "business-criticality" = "high"
  workload               = "azure-ai-platform"
}
