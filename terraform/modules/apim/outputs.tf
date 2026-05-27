output "apim_id" {
  description = "Resource ID of the API Management instance."
  value       = azurerm_api_management.this.id
}

output "apim_gateway_url" {
  description = "Gateway URL of API Management."
  value       = azurerm_api_management.this.gateway_url
}

output "apim_management_url" {
  description = "Management API URL of API Management."
  value       = azurerm_api_management.this.management_api_url
}

output "ai_gateway_api_name" {
  description = "Name of the OpenAI-compatible AI Gateway API."
  value       = azurerm_api_management_api.ai_gateway.name
}

output "mcp_api_name" {
  description = "Name of the MCP gateway API."
  value       = azurerm_api_management_api.mcp_server.name
}

output "backend_names" {
  description = "Configured Azure OpenAI backend names."
  value       = keys(azurerm_api_management_backend.azure_openai)
}

output "routing_config_named_value_name" {
  description = "Named value that stores the AI Gateway routing catalog."
  value       = azurerm_api_management_named_value.this["ai-gateway-routing-config"].name
}
