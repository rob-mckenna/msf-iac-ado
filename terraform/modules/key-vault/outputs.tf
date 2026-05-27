output "key_vault_id" {
  description = "Resource ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

output "key_vault_name" {
  description = "Name of the Key Vault."
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "Vault URI of the Key Vault."
  value       = azurerm_key_vault.this.vault_uri
}

output "private_endpoint_id" {
  description = "Resource ID of the Key Vault private endpoint."
  value       = azurerm_private_endpoint.this.id
}

output "role_assignment_ids" {
  description = "Role assignment IDs created for the Key Vault."
  value       = { for key, assignment in azurerm_role_assignment.this : key => assignment.id }
}
