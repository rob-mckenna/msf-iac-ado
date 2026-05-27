output "hub_vnet_id" {
  description = "Resource ID of the hub virtual network."
  value       = azurerm_virtual_network.hub.id
}

output "hub_subnet_ids" {
  description = "Resource IDs of the hub subnets."
  value = {
    firewall     = azurerm_subnet.firewall.id
    gateway      = azurerm_subnet.gateway.id
    dns_resolver = azurerm_subnet.dns_resolver.id
  }
}

output "spoke_vnet_ids" {
  description = "Resource IDs of the spoke virtual networks."
  value       = { for key, vnet in azurerm_virtual_network.spokes : key => vnet.id }
}

output "spoke_subnet_ids" {
  description = "Resource IDs of the spoke subnets by spoke key and subnet key."
  value = {
    for vnet_key, vnet in var.spoke_vnets : vnet_key => {
      for subnet_key, subnet in vnet.subnets : subnet_key => azurerm_subnet.spokes["${vnet_key}.${subnet_key}"].id
    }
  }
}

output "spoke_nsg_ids" {
  description = "Network security group IDs keyed by spoke and subnet."
  value       = { for key, nsg in azurerm_network_security_group.spokes : key => nsg.id }
}

output "spoke_route_table_ids" {
  description = "Route table IDs keyed by spoke and subnet."
  value       = { for key, route_table in azurerm_route_table.spokes : key => route_table.id }
}

output "firewall_id" {
  description = "Resource ID of the hub Azure Firewall."
  value       = azurerm_firewall.hub.id
}

output "firewall_private_ip_address" {
  description = "Private IP address assigned to the hub Azure Firewall."
  value       = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}

output "hub_to_spoke_peering_ids" {
  description = "Hub-to-spoke VNet peering IDs keyed by spoke name."
  value       = { for key, peering in azurerm_virtual_network_peering.hub_to_spoke : key => peering.id }
}

output "spoke_to_hub_peering_ids" {
  description = "Spoke-to-hub VNet peering IDs keyed by spoke name."
  value       = { for key, peering in azurerm_virtual_network_peering.spoke_to_hub : key => peering.id }
}

output "dns_resolver_subnet_id" {
  description = "Resource ID of the DNS resolver subnet."
  value       = azurerm_subnet.dns_resolver.id
}
