variable "applications" {
  description = "Map of Entra application registrations to create. Use this for production patterns with separate API, gateway, and automation identities."
  type = map(object({
    display_name                           = string
    owners                                 = optional(list(string), [])
    notes                                  = optional(string)
    tags                                   = optional(map(string), {})
    identifier_uris                        = optional(list(string), [])
    sign_in_audience                       = optional(string, "AzureADMyOrg")
    requested_access_token_version         = optional(number, 2)
    group_membership_claims                = optional(list(string), [])
    fallback_public_client_enabled         = optional(bool, false)
    oauth2_post_response_required          = optional(bool, false)
    redirect_uris                          = optional(list(string), [])
    implicit_access_token_issuance_enabled = optional(bool, false)
    implicit_id_token_issuance_enabled     = optional(bool, false)
    create_service_principal               = optional(bool, true)
    app_role_assignment_required           = optional(bool, false)
    known_client_applications              = optional(list(string), [])
    mapped_claims_enabled                  = optional(bool, false)
    api_scopes = optional(list(object({
      value                      = string
      admin_consent_display_name = string
      admin_consent_description  = string
      user_consent_display_name  = string
      user_consent_description   = string
      scope_type                 = string
    })), [])
    app_roles = optional(map(object({
      description          = string
      display_name         = optional(string)
      value                = optional(string)
      allowed_member_types = optional(list(string), ["User", "Application"])
    })), {})
    required_resource_access = optional(list(object({
      resource_app_id = string
      resource_access = list(object({
        id   = string
        type = string
      }))
    })), [])
    optional_claims = optional(object({
      access_token = optional(list(object({
        name                  = string
        essential             = optional(bool, false)
        source                = optional(string)
        additional_properties = optional(list(string), [])
      })), [])
      id_token = optional(list(object({
        name                  = string
        essential             = optional(bool, false)
        source                = optional(string)
        additional_properties = optional(list(string), [])
      })), [])
      saml2_token = optional(list(object({
        name                  = string
        essential             = optional(bool, false)
        source                = optional(string)
        additional_properties = optional(list(string), [])
      })), [])
    }))
    pre_authorized_client_applications = optional(list(object({
      client_id               = string
      permission_scope_values = list(string)
    })), [])
    federated_identity_credentials = optional(map(object({
      display_name = string
      issuer       = string
      subject      = string
      audiences    = optional(list(string), ["api://AzureADTokenExchange"])
      description  = optional(string)
    })), {})
  }))
  default = {}
}

variable "application_name" {
  description = "Legacy single-app input. Prefer applications for new deployments."
  type        = string
  default     = null
}

variable "api_scopes" {
  description = "Legacy single-app scopes. Prefer applications for new deployments."
  type = list(object({
    value                      = string
    admin_consent_display_name = string
    admin_consent_description  = string
    user_consent_display_name  = string
    user_consent_description   = string
    scope_type                 = string
  }))
  default = []
}

variable "redirect_uris" {
  description = "Legacy single-app redirect URIs. Prefer applications for new deployments."
  type        = list(string)
  default     = []
}

variable "owners" {
  description = "Legacy single-app owners. Prefer applications for new deployments."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Legacy single-app metadata tags serialized into the application notes field. Prefer applications for new deployments."
  type        = map(string)
  default     = {}
}
