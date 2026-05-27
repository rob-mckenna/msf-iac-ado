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

  ai_gateway_openapi = {
    openapi = "3.0.3"
    info = {
      title       = "AI Gateway"
      version     = "v1"
      description = "OpenAI-compatible API surface fronted by APIM."
    }
    paths = {
      "/deployments/{deploymentId}/chat/completions" = {
        post = {
          summary     = "Chat completions"
          operationId = "ChatCompletions"
          parameters  = [{ name = "deploymentId", in = "path", required = true, schema = { type = "string" } }]
          requestBody = { required = true, content = { "application/json" = { schema = { type = "object" } } } }
          responses   = { "200" = { description = "Successful completion." } }
        }
      }
      "/deployments/{deploymentId}/responses" = {
        post = {
          summary     = "Responses API"
          operationId = "CreateResponse"
          parameters  = [{ name = "deploymentId", in = "path", required = true, schema = { type = "string" } }]
          requestBody = { required = true, content = { "application/json" = { schema = { type = "object" } } } }
          responses   = { "200" = { description = "Successful response." } }
        }
      }
      "/deployments/{deploymentId}/embeddings" = {
        post = {
          summary     = "Embeddings"
          operationId = "CreateEmbeddings"
          parameters  = [{ name = "deploymentId", in = "path", required = true, schema = { type = "string" } }]
          requestBody = { required = true, content = { "application/json" = { schema = { type = "object" } } } }
          responses   = { "200" = { description = "Embedding response." } }
        }
      }
      "/models" = {
        get = {
          summary     = "List routed models"
          operationId = "ListModels"
          responses   = { "200" = { description = "Configured model routes." } }
        }
      }
    }
  }

  mcp_openapi = {
    openapi = "3.0.3"
    info = {
      title       = "MCP Server Gateway"
      version     = "v1"
      description = "Model Context Protocol discovery and invocation facade fronted by APIM."
    }
    paths = {
      "/tools" = {
        get = {
          summary     = "List registered MCP tools"
          operationId = "ListTools"
          responses   = { "200" = { description = "Tool catalog." } }
        }
      }
      "/tools/{toolName}/invoke" = {
        post = {
          summary     = "Invoke an MCP tool"
          operationId = "InvokeTool"
          parameters  = [{ name = "toolName", in = "path", required = true, schema = { type = "string" } }]
          requestBody = { required = false, content = { "application/json" = { schema = { type = "object" } } } }
          responses   = { "200" = { description = "Tool response." } }
        }
      }
      "/sse" = {
        get = {
          summary     = "Open SSE stream for MCP events"
          operationId = "OpenSseStream"
          responses   = { "200" = { description = "Event stream established." } }
        }
      }
    }
  }

  backend_routing_config = [
    for backend_name in sort(keys(var.azure_openai_backends)) : {
      name                    = backend_name
      url                     = trim(var.azure_openai_backends[backend_name].url, "/")
      managedIdentityClientId = var.azure_openai_backends[backend_name].managed_identity_client_id
      models                  = var.azure_openai_backends[backend_name].models
      priority                = var.azure_openai_backends[backend_name].priority
      weight                  = var.azure_openai_backends[backend_name].weight
      apiVersion              = trimspace(var.azure_openai_backends[backend_name].api_version) != "" ? var.azure_openai_backends[backend_name].api_version : var.openai_api_version
      description             = var.azure_openai_backends[backend_name].description
    }
  ]

  mcp_route_catalog = [
    for tool_name in sort(keys(var.mcp_tool_catalog)) : {
      name       = tool_name
      backendUrl = trim(var.mcp_tool_catalog[tool_name].backend_url, "/")
      pathPrefix = trim(var.mcp_tool_catalog[tool_name].path_prefix, "/")
      protocols  = var.mcp_tool_catalog[tool_name].protocols
    }
  ]

  named_values = merge(
    {
      "appinsights-instrumentation-key"           = { display_name = "appinsights-instrumentation-key", value = var.app_insights_instrumentation_key, secret = true }
      "ai-gateway-mode"                           = { display_name = "ai-gateway-mode", value = "production", secret = false }
      "entraTenantId"                             = { display_name = "entraTenantId", value = var.platform_tenant_id, secret = false }
      "platformAppClientId"                       = { display_name = "platformAppClientId", value = var.platform_app_client_id, secret = false }
      "platformAppAudience"                       = { display_name = "platformAppAudience", value = format("api://%s", var.platform_app_client_id), secret = false }
      "openai-api-version"                        = { display_name = "openai-api-version", value = var.openai_api_version, secret = false }
      "semantic-cache-ttl-seconds"                = { display_name = "semantic-cache-ttl-seconds", value = tostring(var.semantic_cache_ttl_seconds), secret = false }
      "ai-gateway-routing-config"                 = { display_name = "ai-gateway-routing-config", value = jsonencode(local.backend_routing_config), secret = false }
      "content-safety-enabled"                    = { display_name = "content-safety-enabled", value = tostring(var.content_safety.enabled), secret = false }
      "content-safety-endpoint"                   = { display_name = "content-safety-endpoint", value = trim(var.content_safety.endpoint, "/"), secret = false }
      "content-safety-managed-identity-client-id" = { display_name = "content-safety-managed-identity-client-id", value = var.content_safety.managed_identity_client_id, secret = false }
      "content-safety-timeout-seconds"            = { display_name = "content-safety-timeout-seconds", value = tostring(var.content_safety.timeout_seconds), secret = false }
      "mcp-tool-route-catalog"                    = { display_name = "mcp-tool-route-catalog", value = jsonencode(local.mcp_route_catalog), secret = false }
      "mcp-tool-discovery-cache-ttl-seconds"      = { display_name = "mcp-tool-discovery-cache-ttl-seconds", value = tostring(var.mcp_tool_discovery_cache_ttl_seconds), secret = false }
    },
    { for backend_name, backend in var.azure_openai_backends : "backend-url-${backend_name}" => { display_name = "backend-url-${backend_name}", value = trim(backend.url, "/"), secret = false } },
    { for backend_name, backend in var.azure_openai_backends : "backend-mi-client-id-${backend_name}" => { display_name = "backend-mi-client-id-${backend_name}", value = backend.managed_identity_client_id, secret = false } }
  )
}

resource "azurerm_api_management" "this" {
  name                 = var.apim_name
  location             = var.location
  resource_group_name  = var.resource_group_name
  publisher_name       = var.publisher_name
  publisher_email      = var.publisher_email
  sku_name             = var.sku_name
  virtual_network_type = "Internal"
  tags                 = var.tags

  identity {
    type = "SystemAssigned"
  }

  virtual_network_configuration {
    subnet_id = var.subnet_id
  }
}

resource "azurerm_api_management_product" "platform_apis" {
  product_id            = "platform-apis"
  api_management_name   = azurerm_api_management.this.name
  resource_group_name   = var.resource_group_name
  display_name          = "Platform APIs"
  description           = "Shared platform APIs for internal consumers."
  subscription_required = true
  approval_required     = false
  published             = true
}

resource "azurerm_api_management_product" "ai_gateway" {
  product_id            = "ai-gateway"
  api_management_name   = azurerm_api_management.this.name
  resource_group_name   = var.resource_group_name
  display_name          = "AI Gateway"
  description           = "Managed gateway product for Azure AI and model APIs."
  subscription_required = true
  approval_required     = true
  subscriptions_limit   = 50
  published             = true
}

resource "azurerm_api_management_subscription" "platform_team" {
  api_management_name = azurerm_api_management.this.name
  resource_group_name = var.resource_group_name
  display_name        = "platform-team"
  product_id          = azurerm_api_management_product.platform_apis.id
  state               = "active"
  allow_tracing       = false
}

resource "azurerm_api_management_subscription" "ai_gateway" {
  api_management_name = azurerm_api_management.this.name
  resource_group_name = var.resource_group_name
  display_name        = "ai-gateway-shared"
  product_id          = azurerm_api_management_product.ai_gateway.id
  state               = "active"
  allow_tracing       = false
}

resource "azurerm_api_management_named_value" "this" {
  for_each = local.named_values

  name                = each.key
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.this.name
  display_name        = each.value.display_name
  value               = each.value.value
  secret              = each.value.secret
}

resource "azurerm_api_management_logger" "appinsights" {
  name                = "appinsights"
  api_management_name = azurerm_api_management.this.name
  resource_group_name = var.resource_group_name
  resource_id         = var.app_insights_id

  application_insights {
    instrumentation_key = var.app_insights_instrumentation_key
  }
}

resource "azurerm_api_management_diagnostic" "gateway" {
  identifier               = "applicationinsights"
  resource_group_name      = var.resource_group_name
  api_management_name      = azurerm_api_management.this.name
  api_management_logger_id = azurerm_api_management_logger.appinsights.id

  sampling_percentage       = 100
  always_log_errors         = true
  log_client_ip             = true
  verbosity                 = "information"
  http_correlation_protocol = "W3C"
}

resource "azurerm_api_management_backend" "azure_openai" {
  for_each = var.azure_openai_backends

  name                = each.key
  api_management_name = azurerm_api_management.this.name
  resource_group_name = var.resource_group_name
  protocol            = "http"
  url                 = trim(each.value.url, "/")
  description         = trimspace(each.value.description) != "" ? each.value.description : format("Azure OpenAI backend for %s", each.key)

  tls {
    validate_certificate_chain = true
    validate_certificate_name  = true
  }
}

resource "azurerm_api_management_api" "ai_gateway" {
  name                = "azure-openai-compatible"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.this.name
  revision            = "1"
  display_name        = "Azure OpenAI Compatible API"
  path                = "openai"
  protocols           = ["https"]

  import {
    content_format = "openapi+json"
    content_value  = jsonencode(local.ai_gateway_openapi)
  }
}

resource "azurerm_api_management_api" "mcp_server" {
  name                = "mcp-server"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.this.name
  revision            = "1"
  display_name        = "MCP Server Gateway API"
  path                = "mcp"
  protocols           = ["https"]

  import {
    content_format = "openapi+json"
    content_value  = jsonencode(local.mcp_openapi)
  }
}

resource "azurerm_api_management_product_api" "ai_gateway" {
  api_name            = azurerm_api_management_api.ai_gateway.name
  product_id          = azurerm_api_management_product.ai_gateway.product_id
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.this.name
}

resource "azurerm_api_management_product_api" "mcp_server" {
  api_name            = azurerm_api_management_api.mcp_server.name
  product_id          = azurerm_api_management_product.platform_apis.product_id
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.this.name
}

resource "azurerm_api_management_policy_fragment" "content_safety" {
  api_management_id = azurerm_api_management.this.id
  name              = "content-safety-filter"
  format            = "xml"
  value             = file("${path.module}/../../../policies/apim-policy/content-safety.xml")
  description       = "Reusable pre/post content safety moderation fragment for AI Gateway traffic."
}

resource "azurerm_api_management_policy" "global" {
  api_management_id = azurerm_api_management.this.id
  xml_content       = file("${path.module}/../../../policies/apim-policy/ai-gateway-global.xml")
}

resource "azurerm_api_management_product_policy" "ai_gateway" {
  api_management_name = azurerm_api_management.this.name
  resource_group_name = var.resource_group_name
  product_id          = azurerm_api_management_product.ai_gateway.product_id
  xml_content         = file("${path.module}/../../../policies/apim-policy/ai-gateway-product.xml")
}

resource "azurerm_api_management_api_policy" "mcp_server" {
  api_name            = azurerm_api_management_api.mcp_server.name
  api_management_name = azurerm_api_management.this.name
  resource_group_name = var.resource_group_name
  xml_content         = file("${path.module}/../../../policies/apim-policy/mcp-server.xml")
}
