output "workspace_id" {
  description = "AI Foundry workspace ID."
  value       = module.ai_foundry.workspace_id
}

output "workspace_name" {
  description = "AI Foundry workspace name."
  value       = module.ai_foundry.workspace_name
}

output "workspace_principal_id" {
  description = "Managed identity principal ID for the AI Foundry workspace."
  value       = module.ai_foundry.workspace_principal_id
}

output "project_id" {
  description = "AI Foundry project ID."
  value       = module.ai_foundry.project_id
}

output "private_endpoint_ids" {
  description = "Private endpoint IDs created for the workspace and dependencies."
  value       = module.ai_foundry.private_endpoint_ids
}

output "storage_account_id" {
  description = "Storage account ID associated with the workspace."
  value       = azurerm_storage_account.this.id
}

output "container_registry_id" {
  description = "Container Registry ID associated with the workspace."
  value       = azurerm_container_registry.this.id
}

output "application_insights_id" {
  description = "Application Insights ID associated with the workspace."
  value       = azurerm_application_insights.this.id
}

output "key_vault_id" {
  description = "Key Vault ID associated with the workspace."
  value       = module.workspace_key_vault.key_vault_id
}

output "cognitive_account_id" {
  description = "Cognitive Services account ID used for model deployments."
  value       = azurerm_cognitive_account.this.id
}
