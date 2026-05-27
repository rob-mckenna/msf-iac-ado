variable "resource_group_name" {
  description = "Resource group that hosts API Management."
  type        = string
}

variable "location" {
  description = "Azure region for API Management."
  type        = string
}

variable "apim_name" {
  description = "Name of the API Management instance."
  type        = string
}

variable "sku_name" {
  description = "APIM SKU name."
  type        = string
  default     = "Developer_1"
}

variable "publisher_name" {
  description = "Publisher name configured in API Management."
  type        = string
}

variable "publisher_email" {
  description = "Publisher email configured in API Management."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID used for APIM internal VNet integration."
  type        = string
}

variable "app_insights_id" {
  description = "Application Insights resource ID used by the APIM logger."
  type        = string
}

variable "app_insights_instrumentation_key" {
  description = "Application Insights instrumentation key for APIM diagnostics."
  type        = string
}

variable "platform_app_client_id" {
  description = "Client ID of the Entra application APIM validates for JWT audience."
  type        = string
}

variable "platform_tenant_id" {
  description = "Tenant ID used for JWT validation in APIM policies."
  type        = string
}

variable "openai_api_version" {
  description = "Default Azure OpenAI API version enforced by the gateway."
  type        = string
  default     = "2024-10-21"
}

variable "semantic_cache_ttl_seconds" {
  description = "TTL in seconds for semantic cache entries at the gateway."
  type        = number
  default     = 300
}

variable "mcp_tool_discovery_cache_ttl_seconds" {
  description = "TTL in seconds for MCP tool discovery responses."
  type        = number
  default     = 300
}

variable "azure_openai_backends" {
  description = "Azure OpenAI backends available for routing and load balancing."
  type = map(object({
    url                        = string
    managed_identity_client_id = optional(string, "")
    models                     = optional(list(string), [])
    priority                   = optional(number, 100)
    weight                     = optional(number, 1)
    api_version                = optional(string, "")
    description                = optional(string, "")
  }))
  default = {}
}

variable "content_safety" {
  description = "Content safety integration settings used by the gateway policy fragment."
  type = object({
    enabled                    = bool
    endpoint                   = string
    managed_identity_client_id = string
    timeout_seconds            = number
  })
  default = {
    enabled                    = false
    endpoint                   = ""
    managed_identity_client_id = ""
    timeout_seconds            = 5
  }
}

variable "mcp_tool_catalog" {
  description = "MCP tools and their target backend routing details."
  type = map(object({
    backend_url = string
    path_prefix = optional(string, "")
    protocols   = optional(list(string), ["https"])
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to supported resources."
  type        = map(string)
  default     = {}
}
