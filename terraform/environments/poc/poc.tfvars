project_name                                   = "msf"
environment                                    = "poc"
location                                       = "eastus2"
resource_group_name                            = "msf-platform-rg-poc-eastus2-001"
ai_foundry_resource_group_name                 = "msf-aifoundry-rg-poc-eastus2-001"
fabric_resource_group_name                     = "msf-fabric-rg-poc-eastus2-001"
subscription_id                                = "/subscriptions/00000000-0000-0000-0000-000000000000"
tenant_id                                      = "00000000-0000-0000-0000-000000000000"
key_vault_name                                 = "msf-kv-poc-eastus2-001"
ai_foundry_workspace_name                      = "msf-aifoundry-ws-poc-eastus2-001"
fabric_workspace_name                          = "msf-fabric-ws-poc-eastus2-001"
capacity_name                                  = "msf-fabric-cap-poc-eastus2-001"
apim_name                                      = "msf-apim-poc-eastus2-001"
application_name                               = "msf-apim-app-poc-eastus2-001"
publisher_name                                 = "MSF Platform Engineering"
publisher_email                                = "platform@example.com"
sku_name                                       = "Premium_1"
sku                                            = "F8"
firewall_sku_tier                              = "Premium"
firewall_zones                                 = ["1", "2"]
storage_replication_type                       = "ZRS"
acr_sku                                        = "Premium"
workspace_sku_name                             = "Basic"
workspace_sku_tier                             = "Basic"
cognitive_account_kind                         = "OpenAI"
cognitive_account_sku_name                     = "S0"
workspace_key_vault_sku_name                   = "standard"
workspace_key_vault_soft_delete_retention_days = 30
key_vault_sku_name                             = "standard"
key_vault_rbac_authorization_enabled           = false
key_vault_soft_delete_retention_days           = 30
key_vault_purge_protection_enabled             = true
private_endpoint_spoke_key                     = "platform"
private_endpoint_subnet_key                    = "private-endpoints"
landing_zone_state_resource_group_name         = "msf-tfstate-rg-poc-eastus2-001"
landing_zone_state_storage_account_name        = "msftfstatepoceus201"
landing_zone_state_container_name              = "tfstate"
landing_zone_state_key                         = "landing-zone.poc.tfstate"
log_analytics_sku                              = "PerGB2018"
retention_in_days                              = 30
enable_gateway_transit                         = false

hub_vnet_address_space = ["10.20.0.0/22"]

hub_subnet_prefixes = {
  firewall     = "10.20.0.0/26"
  gateway      = "10.20.0.64/27"
  dns_resolver = "10.20.0.96/27"
}

spoke_vnets = {
  platform = {
    address_space = ["10.20.4.0/23"]
    subnets = {
      private-endpoints = {
        address_prefixes                          = ["10.20.4.0/25"]
        service_endpoints                         = ["Microsoft.Storage", "Microsoft.KeyVault"]
        private_endpoint_network_policies_enabled = false
      }
      integration = {
        address_prefixes  = ["10.20.4.128/25"]
        service_endpoints = ["Microsoft.Storage"]
        delegations = [{
          name                    = "aca-environment"
          service_delegation_name = "Microsoft.App/environments"
        }]
      }
    }
  }
  ai = {
    address_space = ["10.20.6.0/23"]
    subnets = {
      workload = {
        address_prefixes = ["10.20.6.0/24"]
        nsg_rules = [{
          name                         = "allow-platform-https-inbound"
          priority                     = 130
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_address_prefixes      = ["10.20.4.128/25"]
          destination_address_prefixes = ["*"]
          destination_port_ranges      = ["443"]
          description                  = "Allow curated platform services to reach PoC AI workloads over HTTPS."
        }]
      }
      training = {
        address_prefixes  = ["10.20.7.0/25"]
        service_endpoints = ["Microsoft.Storage"]
      }
      inferencing = {
        address_prefixes = ["10.20.7.128/25"]
      }
    }
  }
  data = {
    address_space = ["10.20.8.0/23"]
    subnets = {
      analytics = {
        address_prefixes  = ["10.20.8.0/24"]
        service_endpoints = ["Microsoft.Storage"]
      }
      governance = {
        address_prefixes  = ["10.20.9.0/24"]
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
    name          = "stakeholder-alerts"
    email_address = "poc-review@example.com"
  }
]

key_vault_access_policies = [
  {
    tenant_id               = "00000000-0000-0000-0000-000000000000"
    object_id               = "22222222-2222-2222-2222-222222222222"
    secret_permissions      = ["Get", "List", "Set", "Delete"]
    key_permissions         = ["Get", "List", "Create", "Delete"]
    certificate_permissions = ["Get", "List", "Create", "Delete"]
  }
]

key_vault_role_assignments = []

admin_members = [
  "fabric.admin@example.com",
  "data.engineer@example.com"
]

lakehouses = [
  {
    name         = "curatedlh"
    display_name = "Curated Lakehouse"
    description  = "Curated business datasets for proof-of-concept scenarios."
  },
  {
    name         = "rawlh"
    display_name = "Raw Lakehouse"
    description  = "Raw landing lakehouse for early integration patterns."
  }
]

owners = [
  "22222222-2222-2222-2222-222222222222"
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

required_tags = ["environment", "project", "owner", "cost-center", "managed-by", "created-date", "data-class"]

tags = {
  environment    = "poc"
  project        = "msf"
  owner          = "platform-engineering"
  "cost-center"  = "innovation"
  "managed-by"   = "terraform"
  "created-date" = "2026-05-27T07:18:33.309-04:00"
  "data-class"   = "internal"
  workload       = "azure-ai-platform"
}
