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
  location_token           = replace(lower(var.location), " ", "")
  hub_vnet_name            = format("%s-hub-vnet-%s-%s-001", var.project_name, var.environment, local.location_token)
  firewall_name            = format("%s-firewall-%s-%s-001", var.project_name, var.environment, local.location_token)
  firewall_public_ip_name  = format("%s-firewall-pip-%s-%s-001", var.project_name, var.environment, local.location_token)
  dns_resolver_subnet_name = format("%s-dnsresolver-snet-%s-%s-001", var.project_name, var.environment, local.location_token)

  default_ai_nsg_rules = [
    {
      name                         = "allow-vnet-inbound"
      priority                     = 100
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "*"
      source_port_ranges           = ["*"]
      destination_port_ranges      = ["*"]
      source_address_prefixes      = ["VirtualNetwork"]
      destination_address_prefixes = ["VirtualNetwork"]
      description                  = "Allow east-west traffic inside the landing zone."
    },
    {
      name                         = "allow-load-balancer-inbound"
      priority                     = 110
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "*"
      source_port_ranges           = ["*"]
      destination_port_ranges      = ["*"]
      source_address_prefixes      = ["AzureLoadBalancer"]
      destination_address_prefixes = ["*"]
      description                  = "Allow Azure platform health probes."
    },
    {
      name                         = "deny-internet-inbound"
      priority                     = 400
      direction                    = "Inbound"
      access                       = "Deny"
      protocol                     = "*"
      source_port_ranges           = ["*"]
      destination_port_ranges      = ["*"]
      source_address_prefixes      = ["Internet"]
      destination_address_prefixes = ["*"]
      description                  = "Block direct internet ingress to AI subnets."
    },
    {
      name                         = "allow-vnet-outbound"
      priority                     = 100
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "*"
      source_port_ranges           = ["*"]
      destination_port_ranges      = ["*"]
      source_address_prefixes      = ["*"]
      destination_address_prefixes = ["VirtualNetwork"]
      description                  = "Allow east-west traffic for private endpoints and shared services."
    },
    {
      name                         = "allow-https-outbound"
      priority                     = 110
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_ranges           = ["*"]
      destination_port_ranges      = ["443"]
      source_address_prefixes      = ["*"]
      destination_address_prefixes = ["Internet"]
      description                  = "Allow HTTPS egress routed through Azure Firewall."
    },
    {
      name                         = "allow-azuremonitor-outbound"
      priority                     = 120
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_ranges           = ["*"]
      destination_port_ranges      = ["443"]
      source_address_prefixes      = ["*"]
      destination_address_prefixes = ["AzureMonitor"]
      description                  = "Allow telemetry egress to Azure Monitor."
    }
  ]

  spoke_subnets = flatten([
    for vnet_key, vnet in var.spoke_vnets : [
      for subnet_key, subnet in vnet.subnets : {
        key                                           = "${vnet_key}.${subnet_key}"
        vnet_key                                      = vnet_key
        subnet_key                                    = subnet_key
        name                                          = format("%s-%s-snet-%s-%s-001", var.project_name, subnet_key, var.environment, local.location_token)
        virtual_network_name                          = azurerm_virtual_network.spokes[vnet_key].name
        address_prefixes                              = subnet.address_prefixes
        service_endpoints                             = subnet.service_endpoints
        delegations                                   = subnet.delegations
        route_to_firewall                             = subnet.route_to_firewall
        associate_nsg                                 = subnet.associate_nsg
        disable_bgp_route_propagation                 = subnet.disable_bgp_route_propagation
        private_endpoint_network_policies_enabled     = subnet.private_endpoint_network_policies_enabled
        private_link_service_network_policies_enabled = subnet.private_link_service_network_policies_enabled
        nsg_rules                                     = concat(local.default_ai_nsg_rules, subnet.nsg_rules)
      }
    ]
  ])

  subnet_nsg_rules = {
    for rule in flatten([
      for subnet in local.spoke_subnets : [
        for rule in subnet.nsg_rules : merge(rule, {
          key        = "${subnet.key}.${rule.name}"
          subnet_key = subnet.key
        }) if subnet.associate_nsg
      ]
    ]) : rule.key => rule
  }

  route_table_subnets = {
    for subnet in local.spoke_subnets : subnet.key => subnet if subnet.route_to_firewall
  }

  nsg_subnets = {
    for subnet in local.spoke_subnets : subnet.key => subnet if subnet.associate_nsg
  }
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "hub" {
  name                = local.hub_vnet_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.hub_vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_subnet_prefixes.firewall]
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_subnet_prefixes.gateway]
}

resource "azurerm_subnet" "dns_resolver" {
  name                 = local.dns_resolver_subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_subnet_prefixes.dns_resolver]

  delegation {
    name = "dns-resolver"

    service_delegation {
      name    = "Microsoft.Network/dnsResolvers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_public_ip" "firewall" {
  name                = local.firewall_public_ip_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.firewall_zones
  tags                = var.tags
}

resource "azurerm_firewall" "hub" {
  name                = local.firewall_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku_tier
  zones               = var.firewall_zones
  tags                = var.tags

  ip_configuration {
    name                 = "primary"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

resource "azurerm_virtual_network" "spokes" {
  for_each = var.spoke_vnets

  name                = format("%s-%s-vnet-%s-%s-001", var.project_name, each.key, var.environment, local.location_token)
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = each.value.address_space
  tags                = merge(var.tags, { workload = each.key })
}

resource "azurerm_subnet" "spokes" {
  for_each = {
    for subnet in local.spoke_subnets : subnet.key => subnet
  }

  name                                          = each.value.name
  resource_group_name                           = azurerm_resource_group.this.name
  virtual_network_name                          = each.value.virtual_network_name
  address_prefixes                              = each.value.address_prefixes
  service_endpoints                             = each.value.service_endpoints
  private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled

  dynamic "delegation" {
    for_each = each.value.delegations

    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation_name
        actions = delegation.value.actions
      }
    }
  }
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each = azurerm_virtual_network.spokes

  name                         = format("peer-hub-to-%s", each.key)
  resource_group_name          = azurerm_resource_group.this.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = each.value.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.enable_gateway_transit
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each = azurerm_virtual_network.spokes

  name                         = format("peer-%s-to-hub", each.key)
  resource_group_name          = azurerm_resource_group.this.name
  virtual_network_name         = each.value.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = var.enable_gateway_transit && var.spoke_vnets[each.key].use_remote_gateways
}

resource "azurerm_network_security_group" "spokes" {
  for_each = local.nsg_subnets

  name                = format("%s-%s-nsg-%s-%s-001", var.project_name, each.value.subnet_key, var.environment, local.location_token)
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = merge(var.tags, { workload = each.value.vnet_key, subnet = each.value.subnet_key })
}

resource "azurerm_network_security_rule" "spokes" {
  for_each = local.subnet_nsg_rules

  name                         = each.value.name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  resource_group_name          = azurerm_resource_group.this.name
  network_security_group_name  = azurerm_network_security_group.spokes[each.value.subnet_key].name
  source_port_ranges           = each.value.source_port_ranges
  destination_port_ranges      = each.value.destination_port_ranges
  source_address_prefixes      = each.value.source_address_prefixes
  destination_address_prefixes = each.value.destination_address_prefixes
  description                  = each.value.description
}

resource "azurerm_subnet_network_security_group_association" "spokes" {
  for_each = local.nsg_subnets

  subnet_id                 = azurerm_subnet.spokes[each.key].id
  network_security_group_id = azurerm_network_security_group.spokes[each.key].id
}

resource "azurerm_route_table" "spokes" {
  for_each = local.route_table_subnets

  name                          = format("%s-%s-rt-%s-%s-001", var.project_name, each.value.subnet_key, var.environment, local.location_token)
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  disable_bgp_route_propagation = each.value.disable_bgp_route_propagation
  tags                          = merge(var.tags, { workload = each.value.vnet_key, subnet = each.value.subnet_key })
}

resource "azurerm_route" "default_to_firewall" {
  for_each = azurerm_route_table.spokes

  name                   = "default-to-firewall"
  resource_group_name    = azurerm_resource_group.this.name
  route_table_name       = each.value.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}

resource "azurerm_subnet_route_table_association" "spokes" {
  for_each = local.route_table_subnets

  subnet_id      = azurerm_subnet.spokes[each.key].id
  route_table_id = azurerm_route_table.spokes[each.key].id
}
