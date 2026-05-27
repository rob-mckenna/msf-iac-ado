terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.50.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
}

locals {
  default_app_roles = {
    Reader = {
      value                = "Reader"
      display_name         = "Reader"
      description          = "Read-only access to AI platform APIs and metadata."
      allowed_member_types = ["User", "Application"]
    }
    Contributor = {
      value                = "Contributor"
      display_name         = "Contributor"
      description          = "Read and change AI platform workloads without tenant-wide administration."
      allowed_member_types = ["User", "Application"]
    }
    Admin = {
      value                = "Admin"
      display_name         = "Admin"
      description          = "Full operational control of the AI platform security and deployment surface."
      allowed_member_types = ["User", "Application"]
    }
  }

  legacy_applications = var.application_name == null ? {} : {
    default = {
      display_name                           = var.application_name
      owners                                 = var.owners
      notes                                  = null
      tags                                   = var.tags
      identifier_uris                        = []
      sign_in_audience                       = "AzureADMyOrg"
      requested_access_token_version         = 2
      group_membership_claims                = []
      fallback_public_client_enabled         = false
      oauth2_post_response_required          = false
      redirect_uris                          = var.redirect_uris
      implicit_access_token_issuance_enabled = false
      implicit_id_token_issuance_enabled     = length(var.redirect_uris) > 0
      create_service_principal               = true
      app_role_assignment_required           = false
      known_client_applications              = []
      mapped_claims_enabled                  = false
      api_scopes                             = var.api_scopes
      app_roles                              = local.default_app_roles
      required_resource_access               = []
      optional_claims                        = null
      pre_authorized_client_applications     = []
      federated_identity_credentials         = {}
    }
  }

  configured_applications = length(var.applications) > 0 ? var.applications : local.legacy_applications

  applications = {
    for key, app in local.configured_applications : key => {
      display_name                           = app.display_name
      owners                                 = try(app.owners, [])
      notes                                  = try(app.notes, null)
      tags                                   = try(app.tags, {})
      identifier_uris                        = try(app.identifier_uris, [])
      sign_in_audience                       = try(app.sign_in_audience, "AzureADMyOrg")
      requested_access_token_version         = try(app.requested_access_token_version, 2)
      group_membership_claims                = try(app.group_membership_claims, [])
      fallback_public_client_enabled         = try(app.fallback_public_client_enabled, false)
      oauth2_post_response_required          = try(app.oauth2_post_response_required, false)
      redirect_uris                          = try(app.redirect_uris, [])
      implicit_access_token_issuance_enabled = try(app.implicit_access_token_issuance_enabled, false)
      implicit_id_token_issuance_enabled     = try(app.implicit_id_token_issuance_enabled, false)
      create_service_principal               = try(app.create_service_principal, true)
      app_role_assignment_required           = try(app.app_role_assignment_required, false)
      known_client_applications              = try(app.known_client_applications, [])
      mapped_claims_enabled                  = try(app.mapped_claims_enabled, false)
      api_scopes                             = try(app.api_scopes, [])
      app_roles                              = length(try(keys(app.app_roles), [])) > 0 ? app.app_roles : local.default_app_roles
      required_resource_access               = try(app.required_resource_access, [])
      optional_claims                        = try(app.optional_claims, null)
      pre_authorized_client_applications     = try(app.pre_authorized_client_applications, [])
      federated_identity_credentials         = try(app.federated_identity_credentials, {})
    }
  }

  api_scope_map = {
    for item in flatten([
      for app_key, app in local.applications : [
        for scope in app.api_scopes : {
          key     = format("%s::%s", app_key, scope.value)
          app_key = app_key
          scope   = scope
        }
      ]
    ]) : item.key => item
  }

  app_role_map = {
    for item in flatten([
      for app_key, app in local.applications : [
        for role_key, role in app.app_roles : {
          key      = format("%s::%s", app_key, role_key)
          app_key  = app_key
          role_key = role_key
          role     = role
        }
      ]
    ]) : item.key => item
  }

  owner_admin_assignments = {
    for item in flatten([
      for app_key, app in local.applications : [
        for owner in app.owners : {
          key     = format("%s::%s", app_key, owner)
          app_key = app_key
          owner   = owner
        } if contains(keys(app.app_roles), "Admin") && app.create_service_principal
      ]
    ]) : item.key => item
  }

  pre_authorized_client_map = {
    for item in flatten([
      for app_key, app in local.applications : [
        for client in app.pre_authorized_client_applications : {
          key                     = format("%s::%s", app_key, client.client_id)
          app_key                 = app_key
          authorized_client_id    = client.client_id
          permission_scope_values = client.permission_scope_values
        }
      ]
    ]) : item.key => item
  }

  federated_identity_credential_map = {
    for item in flatten([
      for app_key, app in local.applications : [
        for credential_key, credential in app.federated_identity_credentials : {
          key          = format("%s::%s", app_key, credential_key)
          app_key      = app_key
          display_name = credential.display_name
          description  = try(credential.description, null)
          issuer       = credential.issuer
          subject      = credential.subject
          audiences    = try(credential.audiences, ["api://AzureADTokenExchange"])
        }
      ]
    ]) : item.key => item
  }

  default_application_key = contains(keys(local.applications), "default") ? "default" : null
}

resource "random_uuid" "api_scopes" {
  for_each = local.api_scope_map
}

resource "random_uuid" "app_roles" {
  for_each = local.app_role_map
}

resource "azuread_application" "this" {
  for_each = local.applications

  display_name                   = each.value.display_name
  owners                         = each.value.owners
  notes                          = join("\n", compact([each.value.notes, length(each.value.tags) > 0 ? format("metadata=%s", jsonencode(each.value.tags)) : null]))
  identifier_uris                = each.value.identifier_uris
  sign_in_audience               = each.value.sign_in_audience
  group_membership_claims        = each.value.group_membership_claims
  fallback_public_client_enabled = each.value.fallback_public_client_enabled
  oauth2_post_response_required  = each.value.oauth2_post_response_required

  api {
    requested_access_token_version = each.value.requested_access_token_version
    known_client_applications      = each.value.known_client_applications
    mapped_claims_enabled          = each.value.mapped_claims_enabled

    dynamic "oauth2_permission_scope" {
      for_each = { for scope in each.value.api_scopes : scope.value => scope }

      content {
        admin_consent_description  = oauth2_permission_scope.value.admin_consent_description
        admin_consent_display_name = oauth2_permission_scope.value.admin_consent_display_name
        enabled                    = true
        id                         = random_uuid.api_scopes[format("%s::%s", each.key, oauth2_permission_scope.key)].result
        type                       = oauth2_permission_scope.value.scope_type
        user_consent_description   = oauth2_permission_scope.value.user_consent_description
        user_consent_display_name  = oauth2_permission_scope.value.user_consent_display_name
        value                      = oauth2_permission_scope.value.value
      }
    }
  }

  dynamic "app_role" {
    for_each = each.value.app_roles

    content {
      allowed_member_types = try(app_role.value.allowed_member_types, ["User", "Application"])
      description          = app_role.value.description
      display_name         = try(app_role.value.display_name, app_role.key)
      enabled              = true
      id                   = random_uuid.app_roles[format("%s::%s", each.key, app_role.key)].result
      value                = try(app_role.value.value, app_role.key)
    }
  }

  dynamic "required_resource_access" {
    for_each = each.value.required_resource_access

    content {
      resource_app_id = required_resource_access.value.resource_app_id

      dynamic "resource_access" {
        for_each = required_resource_access.value.resource_access

        content {
          id   = resource_access.value.id
          type = resource_access.value.type
        }
      }
    }
  }

  dynamic "optional_claims" {
    for_each = each.value.optional_claims == null ? [] : [each.value.optional_claims]

    content {
      dynamic "access_token" {
        for_each = try(optional_claims.value.access_token, [])

        content {
          name                  = access_token.value.name
          essential             = try(access_token.value.essential, false)
          source                = try(access_token.value.source, null)
          additional_properties = try(access_token.value.additional_properties, [])
        }
      }

      dynamic "id_token" {
        for_each = try(optional_claims.value.id_token, [])

        content {
          name                  = id_token.value.name
          essential             = try(id_token.value.essential, false)
          source                = try(id_token.value.source, null)
          additional_properties = try(id_token.value.additional_properties, [])
        }
      }

      dynamic "saml2_token" {
        for_each = try(optional_claims.value.saml2_token, [])

        content {
          name                  = saml2_token.value.name
          essential             = try(saml2_token.value.essential, false)
          source                = try(saml2_token.value.source, null)
          additional_properties = try(saml2_token.value.additional_properties, [])
        }
      }
    }
  }

  dynamic "web" {
    for_each = length(each.value.redirect_uris) == 0 ? [] : [each.value]

    content {
      redirect_uris = web.value.redirect_uris

      implicit_grant {
        access_token_issuance_enabled = web.value.implicit_access_token_issuance_enabled
        id_token_issuance_enabled     = web.value.implicit_id_token_issuance_enabled
      }
    }
  }
}

resource "azuread_service_principal" "this" {
  for_each = {
    for key, app in local.applications : key => app
    if app.create_service_principal
  }

  client_id                    = azuread_application.this[each.key].client_id
  app_role_assignment_required = each.value.app_role_assignment_required
  owners                       = each.value.owners
}

resource "azuread_application_pre_authorized" "this" {
  for_each = local.pre_authorized_client_map

  application_id       = azuread_application.this[each.value.app_key].id
  authorized_client_id = each.value.authorized_client_id
  permission_ids = [
    for scope_value in each.value.permission_scope_values : azuread_application.this[each.value.app_key].oauth2_permission_scope_ids[scope_value]
  ]
}

resource "azuread_application_federated_identity_credential" "this" {
  for_each = local.federated_identity_credential_map

  application_id = azuread_application.this[each.value.app_key].id
  display_name   = each.value.display_name
  description    = each.value.description
  issuer         = each.value.issuer
  subject        = each.value.subject
  audiences      = each.value.audiences
}

resource "azuread_app_role_assignment" "owners_admin" {
  for_each = local.owner_admin_assignments

  app_role_id         = azuread_application.this[each.value.app_key].app_role_ids["Admin"]
  principal_object_id = each.value.owner
  resource_object_id  = azuread_service_principal.this[each.value.app_key].object_id
}

# Conditional Access is an Entra P1/P2 control and stays outside this module.
# Recommended production baseline:
# - Require phishing-resistant MFA for Admin app role assignments.
# - Restrict portal and workload administration to compliant devices or trusted locations.
# - Block legacy authentication and require workload identity federation for CI/CD where supported.
# - Monitor risky sign-ins for API admin clients separately from runtime service principals.
