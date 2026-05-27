variable "resource_group_name" {
  description = "Foundational resource group used by the landing zone."
  type        = string
}

variable "location" {
  description = "Azure region for the landing zone."
  type        = string
}

variable "project_name" {
  description = "Project prefix used in resource naming."
  type        = string
}

variable "environment" {
  description = "Environment token such as sandbox, poc, or prod."
  type        = string

  validation {
    condition     = contains(["sandbox", "poc", "prod"], lower(var.environment))
    error_message = "Environment must be sandbox, poc, or prod."
  }
}

variable "hub_vnet_address_space" {
  description = "Hub VNet address space."
  type        = list(string)
}

variable "hub_subnet_prefixes" {
  description = "Hub subnet CIDR blocks for Azure Firewall, GatewaySubnet, and DNS Private Resolver."
  type = object({
    firewall     = string
    gateway      = string
    dns_resolver = string
  })
}

variable "firewall_sku_name" {
  description = "Azure Firewall SKU name used by the landing zone."
  type        = string
  default     = "AZFW_VNet"
}

variable "firewall_sku_tier" {
  description = "Azure Firewall tier used by the landing zone."
  type        = string
  default     = "Standard"
}

variable "firewall_zones" {
  description = "Availability zones assigned to Azure Firewall."
  type        = list(string)
  default     = []
}

variable "enable_gateway_transit" {
  description = "Whether the hub advertises gateway transit to spokes."
  type        = bool
  default     = false
}

variable "spoke_vnets" {
  description = "Spoke VNet definitions forwarded to the networking module."
  type = map(object({
    address_space       = list(string)
    use_remote_gateways = optional(bool, false)
    subnets = map(object({
      address_prefixes                              = list(string)
      service_endpoints                             = optional(list(string), [])
      route_to_firewall                             = optional(bool, true)
      associate_nsg                                 = optional(bool, true)
      disable_bgp_route_propagation                 = optional(bool, false)
      private_endpoint_network_policies_enabled     = optional(bool, true)
      private_link_service_network_policies_enabled = optional(bool, true)
      delegations = optional(list(object({
        name                    = string
        service_delegation_name = string
        actions                 = optional(list(string), ["Microsoft.Network/virtualNetworks/subnets/join/action"])
      })), [])
      nsg_rules = optional(list(object({
        name                         = string
        priority                     = number
        direction                    = string
        access                       = string
        protocol                     = string
        source_port_ranges           = optional(list(string), ["*"])
        destination_port_ranges      = optional(list(string), ["*"])
        source_address_prefixes      = optional(list(string), ["*"])
        destination_address_prefixes = optional(list(string), ["*"])
        description                  = optional(string, null)
      })), [])
    }))
  }))
}

variable "private_endpoint_spoke_key" {
  description = "Spoke key that contains the shared private endpoint subnet."
  type        = string
}

variable "private_endpoint_subnet_key" {
  description = "Subnet key used for landing zone private endpoints."
  type        = string
}

variable "private_dns_zones" {
  description = "Optional override list of private DNS zones required by the landing zone."
  type        = list(string)
  default     = []
}

variable "key_vault_name" {
  description = "Name of the landing zone Key Vault."
  type        = string
}

variable "key_vault_sku_name" {
  description = "SKU used by the landing zone Key Vault."
  type        = string
  default     = "standard"
}

variable "key_vault_purge_protection_enabled" {
  description = "Whether purge protection is enabled on the landing zone Key Vault."
  type        = bool
  default     = true
}

variable "key_vault_soft_delete_retention_days" {
  description = "Soft-delete retention period for the landing zone Key Vault."
  type        = number
  default     = 90
}

variable "key_vault_rbac_authorization_enabled" {
  description = "Whether Azure RBAC is used instead of Key Vault access policies."
  type        = bool
  default     = false
}

variable "tenant_id" {
  description = "Azure AD tenant ID for Key Vault."
  type        = string
}

variable "key_vault_access_policies" {
  description = "Key Vault access policies for platform identities."
  type = list(object({
    tenant_id               = string
    object_id               = string
    secret_permissions      = list(string)
    key_permissions         = list(string)
    certificate_permissions = list(string)
  }))
  default = []
}

variable "key_vault_role_assignments" {
  description = "Azure RBAC role assignments granted on the landing zone Key Vault."
  type = list(object({
    principal_id         = string
    role_definition_name = string
  }))
  default = []
}

variable "action_group_email_receivers" {
  description = "Operational alert email receivers."
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "log_analytics_sku" {
  description = "SKU for the landing zone Log Analytics workspaces."
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Retention period for the landing zone Log Analytics workspaces."
  type        = number
  default     = 30
}

variable "subscription_id" {
  description = "Subscription ID that receives policy assignments."
  type        = string
}

variable "allowed_locations" {
  description = "Allowed Azure regions for platform resources. Defaults to the composition location when empty."
  type        = list(string)
  default     = []
}

variable "required_tags" {
  description = "Standard tags required by Azure Policy."
  type        = list(string)
  default     = ["environment", "project", "owner", "cost-center", "managed-by", "created-date"]
}

variable "policy_effect_overrides" {
  description = "Per-policy effect overrides for the landing zone baseline initiative."
  type        = map(string)
  default     = {}
}

variable "assignment_enforcement_enabled" {
  description = "Whether the landing zone initiative assignment is enforced."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to supported resources."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for tag_name in var.required_tags : contains(keys(var.tags), tag_name)])
    error_message = "tags must include every tag listed in required_tags."
  }
}
