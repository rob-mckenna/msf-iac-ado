output "log_analytics_workspace_id" {
  description = "Primary Log Analytics workspace ID."
  value       = module.observability.log_analytics_workspace_id
}

output "application_insights_id" {
  description = "Application Insights resource ID."
  value       = module.observability.application_insights_id
}

output "content_safety_workspace_id" {
  description = "Content safety workspace ID."
  value       = module.observability.content_safety_workspace_id
}

output "action_group_id" {
  description = "Azure Monitor action group ID."
  value       = module.observability.action_group_id
}

output "dashboard_definition" {
  description = "Azure dashboard JSON definition for AI platform health."
  value       = module.observability.dashboard_definition
}

output "workbook_template" {
  description = "Workbook JSON template for AI usage analytics."
  value       = module.observability.workbook_template
}

output "saved_search_ids" {
  description = "Saved Log Analytics searches keyed by logical name."
  value       = module.observability.saved_search_ids
}

output "alert_rule_ids" {
  description = "Alert rule IDs created for AI platform monitoring."
  value       = module.observability.alert_rule_ids
}

output "budget_id" {
  description = "Budget resource ID when configured."
  value       = module.observability.budget_id
}
