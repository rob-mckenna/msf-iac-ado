output "log_analytics_workspace_id" {
  description = "Primary Log Analytics workspace ID."
  value       = azurerm_log_analytics_workspace.main.id
}

output "application_insights_id" {
  description = "Application Insights resource ID."
  value       = azurerm_application_insights.main.id
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights."
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "content_safety_workspace_id" {
  description = "Content safety logging workspace ID."
  value       = azurerm_log_analytics_workspace.content_safety.id
}

output "action_group_id" {
  description = "Platform operations action group ID."
  value       = azurerm_monitor_action_group.platform_ops.id
}

output "diagnostic_settings_template" {
  description = "Reusable diagnostic settings template values for downstream compositions."
  value       = local.diagnostic_settings_template
}

output "dashboard_definition" {
  description = "Azure dashboard JSON definition for AI platform health."
  value       = local.dashboard_definition
}

output "workbook_template" {
  description = "Workbook JSON template for AI usage analytics."
  value       = local.workbook_template
}

output "saved_search_ids" {
  description = "Saved search IDs keyed by query name."
  value       = { for name, search in azurerm_log_analytics_saved_search.this : name => search.id }
}

output "alert_rule_ids" {
  description = "Scheduled query alert IDs."
  value = {
    latency           = azurerm_monitor_scheduled_query_rules_alert_v2.latency.id
    error_rate        = azurerm_monitor_scheduled_query_rules_alert_v2.error_rate.id
    token_consumption = azurerm_monitor_scheduled_query_rules_alert_v2.token_consumption.id
  }
}

output "budget_id" {
  description = "Resource group budget ID when configured."
  value       = length(azurerm_consumption_budget_resource_group.this) > 0 ? azurerm_consumption_budget_resource_group.this[0].id : null
}
