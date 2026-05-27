resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "observability" {
  source = "../../modules/observability"

  resource_group_name              = azurerm_resource_group.this.name
  location                         = azurerm_resource_group.this.location
  subscription_id                  = var.subscription_id
  project_name                     = var.project_name
  environment                      = var.environment
  action_group_email_receivers     = var.action_group_email_receivers
  action_group_webhook_receivers   = var.action_group_webhook_receivers
  log_analytics_sku                = var.log_analytics_sku
  retention_in_days                = var.retention_in_days
  content_safety_retention_in_days = var.content_safety_retention_in_days
  content_safety_workspace_access  = var.content_safety_workspace_access
  diagnostic_targets               = var.diagnostic_targets
  alert_evaluation_frequency       = var.alert_evaluation_frequency
  alert_window_duration            = var.alert_window_duration
  alert_thresholds                 = var.alert_thresholds
  budget                           = var.budget
  tags                             = var.tags
}
