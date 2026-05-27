variable "resource_group_name" {
  description = "Resource group for the APIM gateway composition."
  type        = string
}

variable "location" {
  description = "Azure region for the APIM gateway composition."
  type        = string
}

variable "application_name" {
  description = "Display name for the Entra application registration."
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
  description = "Publisher name configured in APIM."
  type        = string
}

variable "publisher_email" {
  description = "Publisher email configured in APIM."
  type        = string
}

variable "api_scopes" {
  description = "OAuth2 scopes published by the Entra application."
  type = list(object({
    value                      = string
    admin_consent_display_name = string
    admin_consent_description  = string
    user_consent_display_name  = string
    user_consent_description   = string
    scope_type                 = string
  }))
}

variable "owners" {
  description = "Object IDs of the identities that own the Entra application."
  type        = list(string)
}

variable "redirect_uris" {
  description = "Optional explicit redirect URIs."
  type        = list(string)
  default     = []
}

variable "landing_zone_state_resource_group_name" {
  description = "Resource group name that holds the landing zone state backend."
  type        = string
}

variable "landing_zone_state_storage_account_name" {
  description = "Storage account name that holds the landing zone state backend."
  type        = string
}

variable "landing_zone_state_container_name" {
  description = "Container name that holds the landing zone state backend."
  type        = string
}

variable "landing_zone_state_key" {
  description = "State key for the landing zone composition."
  type        = string
}

variable "apim_subnet_id" {
  description = "Optional override subnet for APIM internal mode."
  type        = string
  default     = ""
}

variable "platform_tenant_id" {
  description = "Optional explicit tenant ID used for APIM JWT validation."
  type        = string
  default     = ""
}

variable "openai_api_version" {
  description = "Default Azure OpenAI API version enforced by APIM."
  type        = string
  default     = "2024-10-21"
}

variable "semantic_cache_ttl_seconds" {
  description = "Semantic cache TTL for AI Gateway responses."
  type        = number
  default     = 300
}

variable "mcp_tool_discovery_cache_ttl_seconds" {
  description = "Cache TTL for MCP tool discovery responses."
  type        = number
  default     = 300
}

variable "azure_openai_backends" {
  description = "Azure OpenAI backends exposed through the AI Gateway."
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
  description = "Content safety integration settings for APIM policies."
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
  description = "MCP tools exposed through the APIM MCP gateway."
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
