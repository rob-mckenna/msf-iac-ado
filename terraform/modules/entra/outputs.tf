output "application_id" {
  description = "Object ID of the legacy single Entra application registration. Null when multiple applications are declared."
  value       = try(azuread_application.this[local.default_application_key].object_id, null)
}

output "client_id" {
  description = "Client ID of the legacy single Entra application registration. Null when multiple applications are declared."
  value       = try(azuread_application.this[local.default_application_key].client_id, null)
}

output "service_principal_id" {
  description = "Object ID of the legacy single service principal. Null when multiple applications are declared or the service principal is disabled."
  value       = try(azuread_service_principal.this[local.default_application_key].object_id, null)
}

output "api_scope_ids" {
  description = "Published OAuth2 scope IDs keyed by scope value for the legacy single application input."
  value       = try(azuread_application.this[local.default_application_key].oauth2_permission_scope_ids, {})
}

output "application_ids" {
  description = "Object IDs of Entra application registrations keyed by application key."
  value       = { for key, application in azuread_application.this : key => application.object_id }
}

output "client_ids" {
  description = "Client IDs keyed by application key."
  value       = { for key, application in azuread_application.this : key => application.client_id }
}

output "service_principal_ids" {
  description = "Service principal object IDs keyed by application key."
  value       = { for key, service_principal in azuread_service_principal.this : key => service_principal.object_id }
}

output "application_api_scope_ids" {
  description = "Published OAuth2 scope IDs keyed first by application key and then by scope value."
  value       = { for key, application in azuread_application.this : key => application.oauth2_permission_scope_ids }
}

output "application_app_role_ids" {
  description = "Published app role IDs keyed first by application key and then by role value."
  value       = { for key, application in azuread_application.this : key => application.app_role_ids }
}
