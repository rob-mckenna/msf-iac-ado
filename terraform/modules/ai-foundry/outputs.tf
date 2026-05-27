output "workspace_id" {
  description = "Resource ID of the Azure AI Foundry hub workspace."
  value       = azapi_resource.workspace.id
}

output "workspace_name" {
  description = "Name of the Azure AI Foundry hub workspace."
  value       = var.workspace_name
}

output "workspace_principal_id" {
  description = "System-assigned managed identity principal ID for the workspace."
  value       = try(azapi_resource.workspace.output["identity.principalId"], null)
}

output "private_endpoint_ids" {
  description = "Private endpoint IDs created for the hub and dependent services."
  value       = { for key, pe in azurerm_private_endpoint.this : key => pe.id }
}

output "project_id" {
  description = "Resource ID of the Azure AI Foundry project."
  value       = azapi_resource.project.id
}
