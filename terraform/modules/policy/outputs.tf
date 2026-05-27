output "policy_definition_ids" {
  description = "Policy definition IDs keyed by policy name."
  value       = { for key, definition in azurerm_policy_definition.this : key => definition.id }
}

output "policy_assignment_ids" {
  description = "Policy assignment IDs keyed by assignment scope."
  value       = { ai_platform = azurerm_subscription_policy_assignment.ai_platform.id }
}

output "initiative_definition_id" {
  description = "ID of the AI Platform policy initiative."
  value       = azurerm_policy_set_definition.ai_platform.id
}

output "initiative_assignment_id" {
  description = "ID of the AI Platform policy initiative assignment."
  value       = azurerm_subscription_policy_assignment.ai_platform.id
}

output "policy_effects" {
  description = "Resolved effect applied to each policy reference."
  value       = local.resolved_policy_effects
}
