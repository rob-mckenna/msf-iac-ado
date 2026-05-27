project_name                                   = "msf"
environment                                    = "sandbox"
location                                       = "eastus"
resource_group_name                            = "msf-platform-rg-sandbox-eastus-001"
ai_foundry_resource_group_name                 = "msf-aifoundry-rg-sandbox-eastus-001"
fabric_resource_group_name                     = "msf-fabric-rg-sandbox-eastus-001"
subscription_id                                = "/subscriptions/00000000-0000-0000-0000-000000000000"
tenant_id                                      = "00000000-0000-0000-0000-000000000000"
key_vault_name                                 = "msf-kv-sandbox-eastus-001"
ai_foundry_workspace_name                      = "msf-aifoundry-ws-sandbox-eastus-001"
fabric_workspace_name                          = "msf-fabric-ws-sandbox-eastus-001"
capacity_name                                  = "msf-fabric-cap-sandbox-eastus-001"
apim_name                                      = "msf-apim-sandbox-eastus-001"
application_name                               = "msf-apim-app-sandbox-eastus-001"
publisher_name                                 = "MSF Platform Engineering"
publisher_email                                = "platform@example.com"
sku_name                                       = "Developer_1"
sku                                            = "F2"
firewall_sku_tier                              = "Standard"
firewall_zones                                 = []
storage_replication_type                       = "LRS"
acr_sku                                        = "Standard"
workspace_sku_name                             = "Basic"
workspace_sku_tier                             = "Basic"
cognitive_account_kind                         = "OpenAI"
cognitive_account_sku_name                     = "S0"
workspace_key_vault_sku_name                   = "standard"
workspace_key_vault_soft_delete_retention_days = 14
key_vault_sku_name                             = "standard"
key_vault_rbac_authorization_enabled           = false
key_vault_soft_delete_retention_days           = 14
key_vault_purge_protection_enabled             = true
private_endpoint_spoke_key                     = "platform"
private_endpoint_subnet_key                    = "private-endpoints"
landing_zone_state_resource_group_name         = "msf-tfstate-rg-sandbox-eastus-001"
landing_zone_state_storage_account_name        = "msftfstatesandboxeus01"
landing_zone_state_container_name              = "tfstate"
landing_zone_state_key                         = "landing-zone.sandbox.tfstate"
log_analytics_sku                              = "PerGB2018"
retention_in_days                              = 14
enable_gateway_transit                         = false

hub_vnet_address_space = ["10.10.0.0/22"]

hub_subnet_prefixes = {
  firewall     = "10.10.0.0/26"
  gateway      = "10.10.0.64/27"
  dns_resolver = "10.10.0.96/27"
}

spoke_vnets = {
  platform = {
    address_space = ["10.10.4.0/23"]
    subnets = {
      private-endpoints = {
        address_prefixes                          = ["10.10.4.0/26"]
        service_endpoints                         = ["Microsoft.Storage", "Microsoft.KeyVault"]
        private_endpoint_network_policies_enabled = false
      }
      integration = {
        address_prefixes  = ["10.10.4.64/26"]
        service_endpoints = ["Microsoft.Storage"]
        delegations = [{
          name                    = "aca-environment"
          service_delegation_name = "Microsoft.App/environments"
        }]
      }
    }
  }
  ai = {
    address_space = ["10.10.6.0/23"]
    subnets = {
      workload = {
        address_prefixes = ["10.10.6.0/25"]
        nsg_rules = [{
          name                         = "allow-platform-https-inbound"
          priority                     = 130
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_address_prefixes      = ["10.10.4.64/26"]
          destination_address_prefixes = ["*"]
          destination_port_ranges      = ["443"]
          description                  = "Allow platform integration services to reach sandbox AI endpoints over HTTPS."
        }]
      }
      training = {
        address_prefixes  = ["10.10.6.128/25"]
        service_endpoints = ["Microsoft.Storage"]
      }
    }
  }
  data = {
    address_space = ["10.10.8.0/23"]
    subnets = {
      analytics = {
        address_prefixes  = ["10.10.8.0/25"]
        service_endpoints = ["Microsoft.Storage"]
      }
      governance = {
        address_prefixes  = ["10.10.8.128/25"]
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
  }
]

key_vault_access_policies = [
  {
    tenant_id               = "00000000-0000-0000-0000-000000000000"
    object_id               = "11111111-1111-1111-1111-111111111111"
    secret_permissions      = ["Get", "List", "Set"]
    key_permissions         = ["Get", "List", "Create"]
    certificate_permissions = ["Get", "List", "Create"]
  }
]

key_vault_role_assignments = []

admin_members = [
  "fabric.admin@example.com"
]

lakehouses = [
  {
    name         = "sandboxlh"
    display_name = "Sandbox Lakehouse"
    description  = "Lightweight lakehouse for experimentation and smoke tests."
  }
]

owners = [
  "11111111-1111-1111-1111-111111111111"
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

required_tags = ["environment", "project", "owner", "cost-center", "managed-by", "created-date"]

tags = {
  environment    = "sandbox"
  project        = "msf"
  owner          = "platform-engineering"
  "cost-center"  = "rnd"
  "managed-by"   = "terraform"
  "created-date" = "2026-05-27T07:18:33.309-04:00"
  workload       = "azure-ai-platform"
}
