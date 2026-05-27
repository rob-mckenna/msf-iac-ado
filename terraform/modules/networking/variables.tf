variable "resource_group_name" {
  description = "Resource group name for the hub-spoke networking deployment."
  type        = string
}

variable "location" {
  description = "Azure region for all networking resources."
  type        = string
}

variable "project_name" {
  description = "Project prefix used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name such as sandbox, poc, or prod."
  type        = string

  validation {
    condition     = contains(["sandbox", "poc", "prod"], lower(var.environment))
    error_message = "Environment must be sandbox, poc, or prod."
  }
}

variable "hub_vnet_address_space" {
  description = "Address space for the hub virtual network."
  type        = list(string)

  validation {
    condition     = length(var.hub_vnet_address_space) > 0 && alltrue([for cidr in var.hub_vnet_address_space : can(cidrhost(cidr, 0))])
    error_message = "Provide at least one valid CIDR block for the hub virtual network."
  }
}

variable "hub_subnet_prefixes" {
  description = "CIDR ranges reserved inside the hub virtual network for Azure Firewall, GatewaySubnet, and DNS Private Resolver."
  type = object({
    firewall     = string
    gateway      = string
    dns_resolver = string
  })

  validation {
    condition = alltrue([
      can(cidrhost(var.hub_subnet_prefixes.firewall, 0)),
      can(cidrhost(var.hub_subnet_prefixes.gateway, 0)),
      can(cidrhost(var.hub_subnet_prefixes.dns_resolver, 0))
    ])
    error_message = "Hub subnet prefixes must be valid CIDR blocks."
  }
}

variable "firewall_sku_name" {
  description = "Azure Firewall SKU name for the hub firewall."
  type        = string
  default     = "AZFW_VNet"

  validation {
    condition     = contains(["AZFW_VNet"], var.firewall_sku_name)
    error_message = "firewall_sku_name must be AZFW_VNet."
  }
}

variable "firewall_sku_tier" {
  description = "Azure Firewall tier for the hub firewall."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.firewall_sku_tier)
    error_message = "firewall_sku_tier must be Standard or Premium."
  }
}

variable "firewall_zones" {
  description = "Availability zones assigned to the Azure Firewall public IP and firewall resources."
  type        = list(string)
  default     = []
}

variable "enable_gateway_transit" {
  description = "Whether the hub peering advertises gateway transit to spokes."
  type        = bool
  default     = false
}

variable "spoke_vnets" {
  description = "Map of spoke VNets and their subnet definitions."
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

  validation {
    condition = length(var.spoke_vnets) > 0 && alltrue([
      for vnet in values(var.spoke_vnets) : length(vnet.address_space) > 0 && alltrue([for cidr in vnet.address_space : can(cidrhost(cidr, 0))]) && length(vnet.subnets) > 0
    ])
    error_message = "Each spoke VNet must declare valid address space CIDRs and at least one subnet."
  }
}

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
