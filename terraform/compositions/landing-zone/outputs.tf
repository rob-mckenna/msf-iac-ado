output "resource_group_name" {
  description = "Landing zone resource group name."
  value       = var.resource_group_name
}

output "hub_vnet_id" {
  description = "Hub VNet ID from the networking module."
  value       = module.networking.hub_vnet_id
}

output "hub_subnet_ids" {
  description = "Hub subnet IDs from the networking module."
  value       = module.networking.hub_subnet_ids
}

output "spoke_vnet_ids" {
  description = "Spoke VNet IDs from the networking module."
  value       = module.networking.spoke_vnet_ids
}

output "spoke_subnet_ids" {
  description = "Spoke subnet IDs from the networking module."
  value       = module.networking.spoke_subnet_ids
}

output "spoke_nsg_ids" {
  description = "Spoke subnet network security group IDs."
  value       = module.networking.spoke_nsg_ids
}

output "spoke_route_table_ids" {
  description = "Spoke subnet route table IDs."
  value       = module.networking.spoke_route_table_ids
}

output "firewall_id" {
  description = "Hub Azure Firewall resource ID."
  value       = module.networking.firewall_id
}

output "firewall_private_ip_address" {
  description = "Hub Azure Firewall private IP address."
  value       = module.networking.firewall_private_ip_address
}

output "private_endpoint_subnet_id" {
  description = "Shared subnet ID used for private endpoints."
  value       = module.networking.spoke_subnet_ids[var.private_endpoint_spoke_key][var.private_endpoint_subnet_key]
}

output "dns_resolver_subnet_id" {
  description = "DNS resolver subnet ID."
  value       = module.networking.dns_resolver_subnet_id
}

output "private_dns_zone_ids" {
  description = "Private DNS zone IDs created for the platform."
  value       = module.dns.private_dns_zone_ids
}

output "private_dns_zone_names" {
  description = "Private DNS zone names created for the platform."
  value       = module.dns.private_dns_zone_names
}

output "log_analytics_workspace_id" {
  description = "Primary Log Analytics workspace ID."
  value       = module.observability.log_analytics_workspace_id
}

output "app_insights_id" {
  description = "Application Insights ID from the observability module."
  value       = module.observability.application_insights_id
}

output "app_insights_instrumentation_key" {
  description = "Application Insights instrumentation key."
  value       = module.observability.application_insights_instrumentation_key
  sensitive   = true
}

output "key_vault_id" {
  description = "Landing zone Key Vault ID."
  value       = module.key_vault.key_vault_id
}

output "key_vault_name" {
  description = "Landing zone Key Vault name."
  value       = module.key_vault.key_vault_name
}

output "key_vault_uri" {
  description = "Landing zone Key Vault URI."
  value       = module.key_vault.vault_uri
}

output "policy_assignment_ids" {
  description = "Policy assignment IDs created by the landing zone."
  value       = module.policy.policy_assignment_ids
}
