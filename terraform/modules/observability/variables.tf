variable "resource_group_name" {
  description = "Resource group that hosts the observability stack."
  type        = string
}

variable "location" {
  description = "Azure region for observability resources."
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID used for budget alert scoping."
  type        = string
}

variable "project_name" {
  description = "Project prefix used in resource naming."
  type        = string
}

variable "environment" {
  description = "Environment token used in resource naming."
  type        = string
}

variable "action_group_email_receivers" {
  description = "Email receivers configured on the platform action group."
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "action_group_webhook_receivers" {
  description = "Webhook receivers configured on the platform action group."
  type = list(object({
    name                    = string
    service_uri             = string
    use_common_alert_schema = bool
  }))
  default = []
}

variable "log_analytics_sku" {
  description = "SKU for Log Analytics workspaces."
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Retention period for the primary Log Analytics workspace."
  type        = number
  default     = 30
}

variable "content_safety_retention_in_days" {
  description = "Retention period for the dedicated content safety workspace."
  type        = number
  default     = 180
}

variable "content_safety_workspace_access" {
  description = "RBAC assignments for the content safety workspace."
  type = list(object({
    principal_id         = string
    role_definition_name = string
  }))
  default = []
}

variable "diagnostic_targets" {
  description = "Resources that should receive diagnostic settings from the observability module."
  type = map(object({
    target_resource_id           = string
    log_categories               = list(string)
    metric_categories            = list(string)
    workspace_id                 = optional(string, "")
    use_content_safety_workspace = optional(bool, false)
  }))
  default = {}
}

variable "alert_evaluation_frequency" {
  description = "Evaluation frequency for scheduled query alerts."
  type        = string
  default     = "PT5M"
}

variable "alert_window_duration" {
  description = "Window duration for scheduled query alerts."
  type        = string
  default     = "PT15M"
}

variable "alert_thresholds" {
  description = "Thresholds for AI Gateway alerting."
  type = object({
    latency_ms               = number
    error_rate_percent       = number
    hourly_token_consumption = number
  })
  default = {
    latency_ms               = 5000
    error_rate_percent       = 5
    hourly_token_consumption = 250000
  }
}

variable "budget" {
  description = "Optional budget configuration for the observability resource group."
  type = object({
    amount           = number
    time_grain       = string
    start_date       = string
    end_date         = string
    contact_emails   = list(string)
    contact_roles    = list(string)
    contact_webhooks = list(string)
    notifications = list(object({
      threshold            = number
      threshold_type       = string
      operator             = string
      include_action_group = bool
    }))
  })
  default = {
    amount           = 0
    time_grain       = "Monthly"
    start_date       = ""
    end_date         = ""
    contact_emails   = []
    contact_roles    = []
    contact_webhooks = []
    notifications    = []
  }
}

variable "tags" {
  description = "Tags applied to supported resources."
  type        = map(string)
  default     = {}
}
