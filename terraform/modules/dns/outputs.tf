output "private_dns_zone_ids" {
  description = "Private DNS zone IDs keyed by zone name."
  value       = { for key, zone in azurerm_private_dns_zone.this : key => zone.id }
}

output "private_dns_zone_names" {
  description = "Names of the private DNS zones created by the module."
  value       = keys(azurerm_private_dns_zone.this)
}

output "virtual_network_link_ids" {
  description = "Virtual network link IDs keyed by zone and VNet key."
  value       = { for key, link in azurerm_private_dns_zone_virtual_network_link.this : key => link.id }
}
