# networking module

Deploys the foundational hub-spoke network for the Azure AI Platform landing zone.

## What it creates

- a dedicated resource group
- a hub virtual network
- Azure Firewall subnet (`AzureFirewallSubnet`)
- DNS resolver delegated subnet
- spoke virtual networks and spoke subnets
- bidirectional VNet peering between hub and each spoke
- common Private DNS zones and VNet links

## Inputs

- `resource_group_name`: target resource group
- `location`: Azure region
- `hub_vnet_address_space`: CIDR ranges for the hub VNet
- `spoke_vnets`: map of spoke definitions and subnets
- `environment`: environment token used in naming
- `project_name`: project prefix used in naming
- `tags`: tags applied to resources

## Outputs

- `hub_vnet_id`
- `spoke_vnet_ids`
- `spoke_subnet_ids`
- `firewall_subnet_id`
- `dns_resolver_subnet_id`
- `private_dns_zone_ids`

This module is intended to be consumed by landing zone and workload compositions.
