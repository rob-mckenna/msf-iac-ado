terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100.0"
    }
  }
}

locals {
  location_token = replace(lower(var.location), " ", "")

  diagnostic_settings_template = {
    primary_workspace_id        = azurerm_log_analytics_workspace.main.id
    content_safety_workspace_id = azurerm_log_analytics_workspace.content_safety.id
    defaults = {
      logs    = ["AuditEvent", "GatewayLogs"]
      metrics = ["AllMetrics"]
    }
  }

  dashboard_markdown = join("\n", [
    format("# %s %s AI Platform", upper(var.project_name), upper(var.environment)),
    "",
    format("- Primary workspace: `%s`", azurerm_log_analytics_workspace.main.name),
    format("- Content safety workspace: `%s`", azurerm_log_analytics_workspace.content_safety.name),
    format("- Application Insights: `%s`", azurerm_application_insights.main.name),
    "- Saved searches: AI Gateway latency, error rate, token consumption, content safety events",
    "- Alerts: latency, error rate, token consumption"
  ])

  dashboard_definition = jsonencode({
    lenses = {
      "0" = {
        order = 0
        parts = {
          "0" = {
            position = {
              x       = 0
              y       = 0
              rowSpan = 4
              colSpan = 8
            }
            metadata = {
              inputs = []
              type   = "Extension/HubsExtension/PartType/MarkdownPart"
              settings = {
                content = {
                  settings = {
                    title    = "AI Platform Health"
                    content  = local.dashboard_markdown
                    subtitle = ""
                  }
                }
              }
            }
          }
        }
      }
    }
    metadata = {
      model = {
        timeRange = {
          value = {
            relative = {
              duration = 24
              timeUnit = 1
            }
          }
          type = "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
        }
        filterLocale = {
          value = "en-us"
        }
      }
    }
  })

  saved_search_queries = {
    ai_gateway_latency = {
      category       = "AI Platform"
      display_name   = "AI Gateway - P95 Latency"
      function_alias = "aiGatewayLatency"
      workspace_id   = azurerm_log_analytics_workspace.main.id
      query          = <<-QUERY
        AppRequests
        | where Name contains "openai"
        | summarize p95DurationMs = percentile(DurationMs, 95) by bin(TimeGenerated, 5m), OperationName
        | order by TimeGenerated desc
      QUERY
    }
    ai_gateway_error_rate = {
      category       = "AI Platform"
      display_name   = "AI Gateway - Error Rate"
      function_alias = "aiGatewayErrorRate"
      workspace_id   = azurerm_log_analytics_workspace.main.id
      query          = <<-QUERY
        AppRequests
        | where Name contains "openai"
        | summarize totalRequests = count(), failedRequests = countif(Success == false) by bin(TimeGenerated, 5m), OperationName
        | extend errorRate = iff(totalRequests == 0, 0.0, todouble(failedRequests) * 100.0 / todouble(totalRequests))
        | order by TimeGenerated desc
      QUERY
    }
    ai_token_consumption = {
      category       = "AI Platform"
      display_name   = "AI Gateway - Token Consumption"
      function_alias = "aiGatewayTokenConsumption"
      workspace_id   = azurerm_log_analytics_workspace.main.id
      query          = <<-QUERY
        AppTraces
        | where tostring(Properties.eventType) == "token-usage" or Message has "token-usage"
        | extend totalTokens = todouble(coalesce(tostring(Properties.totalTokens), tostring(Properties.total_tokens), "0"))
        | summarize totalTokens = sum(totalTokens) by bin(TimeGenerated, 1h), tostring(Properties.subscriptionId), tostring(Properties.model)
        | order by TimeGenerated desc
      QUERY
    }
    content_safety_events = {
      category       = "AI Platform"
      display_name   = "AI Gateway - Content Safety Events"
      function_alias = "aiGatewayContentSafety"
      workspace_id   = azurerm_log_analytics_workspace.content_safety.id
      query          = <<-QUERY
        AppTraces
        | where Message has "PromptBlocked" or Message has "ResponseBlocked" or tostring(Properties.eventType) == "content-safety"
        | project TimeGenerated, Message, Properties
        | order by TimeGenerated desc
      QUERY
    }
  }

  workbook_template = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        name = "overview"
        content = {
          json = join("\n", [
            "# AI Usage Analytics",
            "Use the saved searches deployed by the observability module to power charts for token consumption, latency, error rate, and content safety events.",
            "",
            "## Included query templates",
            "- `aiGatewayTokenConsumption()`",
            "- `aiGatewayLatency()`",
            "- `aiGatewayErrorRate()`",
            "- `aiGatewayContentSafety()`"
          ])
        }
      },
      {
        type = 1
        name = "token-query"
        content = {
          json = local.saved_search_queries.ai_token_consumption.query
        }
      },
      {
        type = 1
        name = "latency-query"
        content = {
          json = local.saved_search_queries.ai_gateway_latency.query
        }
      },
      {
        type = 1
        name = "cost-guidance"
        content = {
          json = "Correlate totalTokens with APIM subscription identifiers and environment tags to derive model cost trends."
        }
      }
    ]
    isLocked            = false
    fallbackResourceIds = ["Azure Monitor"]
  })
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = format("%s-law-%s-%s-001", var.project_name, var.environment, local.location_token)
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.retention_in_days
  tags                = var.tags
}

resource "azurerm_log_analytics_workspace" "content_safety" {
  name                          = format("%s-cs-law-%s-%s-001", var.project_name, var.environment, local.location_token)
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.log_analytics_sku
  retention_in_days             = var.content_safety_retention_in_days
  local_authentication_disabled = true
  internet_query_enabled        = false
  tags                          = merge(var.tags, { workload = "content-safety" })
}

resource "azurerm_application_insights" "main" {
  name                = format("%s-appi-%s-%s-001", var.project_name, var.environment, local.location_token)
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_monitor_action_group" "platform_ops" {
  name                = format("%s-ag-%s-%s-001", var.project_name, var.environment, local.location_token)
  resource_group_name = var.resource_group_name
  short_name          = substr(replace(format("%s%sops", var.project_name, var.environment), "-", ""), 0, 12)
  enabled             = true
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = { for receiver in var.action_group_email_receivers : receiver.name => receiver }

    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = true
    }
  }

  dynamic "webhook_receiver" {
    for_each = { for receiver in var.action_group_webhook_receivers : receiver.name => receiver }

    content {
      name                    = webhook_receiver.value.name
      service_uri             = webhook_receiver.value.service_uri
      use_common_alert_schema = webhook_receiver.value.use_common_alert_schema
    }
  }
}

resource "azurerm_role_assignment" "content_safety_workspace" {
  for_each = {
    for assignment in var.content_safety_workspace_access : format("%s-%s", assignment.principal_id, assignment.role_definition_name) => assignment
  }

  scope                = azurerm_log_analytics_workspace.content_safety.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_targets

  name                       = format("diag-%s", substr(each.key, 0, 42))
  target_resource_id         = each.value.target_resource_id
  log_analytics_workspace_id = each.value.use_content_safety_workspace ? azurerm_log_analytics_workspace.content_safety.id : (trimspace(each.value.workspace_id) != "" ? each.value.workspace_id : azurerm_log_analytics_workspace.main.id)

  dynamic "enabled_log" {
    for_each = each.value.log_categories

    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = each.value.metric_categories

    content {
      category = metric.value
      enabled  = true
    }
  }
}

resource "azurerm_log_analytics_saved_search" "this" {
  for_each = local.saved_search_queries

  name                       = replace(lower(each.key), "_", "-")
  display_name               = each.value.display_name
  category                   = each.value.category
  log_analytics_workspace_id = each.value.workspace_id
  query                      = trimspace(each.value.query)
  function_alias             = each.value.function_alias
  tags                       = var.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "latency" {
  name                             = format("%s-ai-latency-%s", var.project_name, var.environment)
  resource_group_name              = var.resource_group_name
  location                         = var.location
  evaluation_frequency             = var.alert_evaluation_frequency
  window_duration                  = var.alert_window_duration
  scopes                           = [azurerm_log_analytics_workspace.main.id]
  severity                         = 2
  enabled                          = true
  description                      = "Alert when AI Gateway latency exceeds the threshold."
  display_name                     = "AI Gateway latency"
  auto_mitigation_enabled          = true
  skip_query_validation            = true
  workspace_alerts_storage_enabled = false

  criteria {
    query                   = <<-QUERY
      AppRequests
      | where Name contains "openai"
      | summarize p95DurationMs = percentile(DurationMs, 95) by bin(TimeGenerated, 5m)
    QUERY
    time_aggregation_method = "Maximum"
    threshold               = var.alert_thresholds.latency_ms
    operator                = "GreaterThan"
    metric_measure_column   = "p95DurationMs"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.platform_ops.id]
    custom_properties = {
      signal        = "latency"
      email_subject = format("[%s] AI Gateway latency alert", upper(var.environment))
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "error_rate" {
  name                             = format("%s-ai-errors-%s", var.project_name, var.environment)
  resource_group_name              = var.resource_group_name
  location                         = var.location
  evaluation_frequency             = var.alert_evaluation_frequency
  window_duration                  = var.alert_window_duration
  scopes                           = [azurerm_log_analytics_workspace.main.id]
  severity                         = 2
  enabled                          = true
  description                      = "Alert when AI Gateway error rate exceeds the threshold."
  display_name                     = "AI Gateway error rate"
  auto_mitigation_enabled          = true
  skip_query_validation            = true
  workspace_alerts_storage_enabled = false

  criteria {
    query                   = <<-QUERY
      AppRequests
      | where Name contains "openai"
      | summarize totalRequests = count(), failedRequests = countif(Success == false) by bin(TimeGenerated, 5m)
      | extend errorRate = iff(totalRequests == 0, 0.0, todouble(failedRequests) * 100.0 / todouble(totalRequests))
    QUERY
    time_aggregation_method = "Maximum"
    threshold               = var.alert_thresholds.error_rate_percent
    operator                = "GreaterThan"
    metric_measure_column   = "errorRate"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.platform_ops.id]
    custom_properties = {
      signal        = "error-rate"
      email_subject = format("[%s] AI Gateway error rate alert", upper(var.environment))
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "token_consumption" {
  name                             = format("%s-ai-tokens-%s", var.project_name, var.environment)
  resource_group_name              = var.resource_group_name
  location                         = var.location
  evaluation_frequency             = var.alert_evaluation_frequency
  window_duration                  = "PT1H"
  scopes                           = [azurerm_log_analytics_workspace.main.id]
  severity                         = 3
  enabled                          = true
  description                      = "Alert when hourly AI token consumption exceeds the threshold."
  display_name                     = "AI token consumption"
  auto_mitigation_enabled          = true
  skip_query_validation            = true
  workspace_alerts_storage_enabled = false

  criteria {
    query                   = <<-QUERY
      AppTraces
      | where tostring(Properties.eventType) == "token-usage" or Message has "token-usage"
      | extend totalTokens = todouble(coalesce(tostring(Properties.totalTokens), tostring(Properties.total_tokens), "0"))
      | summarize consumedTokens = sum(totalTokens) by bin(TimeGenerated, 1h)
    QUERY
    time_aggregation_method = "Maximum"
    threshold               = var.alert_thresholds.hourly_token_consumption
    operator                = "GreaterThan"
    metric_measure_column   = "consumedTokens"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.platform_ops.id]
    custom_properties = {
      signal        = "token-consumption"
      email_subject = format("[%s] AI token consumption alert", upper(var.environment))
    }
  }

  tags = var.tags
}

resource "azurerm_consumption_budget_resource_group" "this" {
  count = var.budget.amount > 0 && trimspace(var.budget.start_date) != "" ? 1 : 0

  name              = format("%s-budget-%s", var.project_name, var.environment)
  resource_group_id = format("/subscriptions/%s/resourceGroups/%s", var.subscription_id, var.resource_group_name)
  amount            = var.budget.amount
  time_grain        = var.budget.time_grain

  time_period {
    start_date = var.budget.start_date
    end_date   = trimspace(var.budget.end_date) != "" ? var.budget.end_date : null
  }

  dynamic "notification" {
    for_each = var.budget.notifications

    content {
      enabled        = true
      threshold      = notification.value.threshold
      operator       = notification.value.operator
      threshold_type = notification.value.threshold_type
      contact_emails = var.budget.contact_emails
      contact_groups = notification.value.include_action_group ? [azurerm_monitor_action_group.platform_ops.id] : []
      contact_roles  = var.budget.contact_roles
    }
  }
}

