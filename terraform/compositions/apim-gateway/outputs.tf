output "apim_id" {
  description = "API Management instance ID."
  value       = module.apim.apim_id
}

output "apim_gateway_url" {
  description = "API Management gateway URL."
  value       = module.apim.apim_gateway_url
}

output "apim_management_url" {
  description = "API Management management API URL."
  value       = module.apim.apim_management_url
}

output "entra_client_id" {
  description = "Client ID of the Entra application."
  value       = module.entra.client_id
}

output "service_principal_id" {
  description = "Service principal object ID used by the APIM gateway integration."
  value       = module.entra.service_principal_id
}

output "ai_gateway_api_name" {
  description = "OpenAI-compatible API name created in APIM."
  value       = module.apim.ai_gateway_api_name
}

output "mcp_api_name" {
  description = "MCP gateway API name created in APIM."
  value       = module.apim.mcp_api_name
}
