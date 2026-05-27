# entra module

Creates production-ready Microsoft Entra application registrations and service principals for platform APIs, trusted first-party clients, and automation identities.

## What it creates

- multiple Entra application registrations from a single module invocation
- published OAuth2 scopes for APIs and client credential flows
- `Reader`, `Contributor`, and `Admin` app roles by default
- service principals for runtime and automation identities
- pre-authorized client relationships for trusted first-party apps
- workload identity federation bindings for CI/CD and other external issuers
- owner-to-`Admin` app role assignments for break-glass administration

## Recommended application patterns

### 1. AI Platform API

Use a dedicated API registration with profile-aligned scopes:

- `Platform.Read`
- `Platform.Write`
- `Platform.Admin`
- `Models.Invoke`
- `Models.Deploy`

Recommended hardening:

- publish an `api://` identifier URI
- keep `requested_access_token_version = 2`
- emit `groups` and selected optional claims only when APIM or downstream APIs need them
- use pre-authorized clients for trusted first-party callers that should skip user consent prompts

### 2. APIM backend identity

Use a separate confidential client registration for APIM-to-backend calls when managed identity is not sufficient. Prefer managed identity first. When an app registration is required:

- do not configure redirect URIs unless interactive sign-in is truly needed
- request only the backend app roles or application permissions APIM needs
- use client credential flow with certificate credentials or workload federation rather than shared secrets

### 3. DevOps service principal

Use a separate automation registration for deployment pipelines. Prefer workload identity federation over secrets so Azure DevOps or GitHub Actions can exchange OIDC tokens for Entra access tokens without storing credentials in the pipeline.

## Example

```hcl
module "entra" {
  source = "../../modules/entra"

  applications = {
    ai_platform_api = {
      display_name    = "msf-ai-platform-api"
      owners          = var.identity_owners
      identifier_uris = ["api://msf-ai-platform-api"]
      group_membership_claims = ["SecurityGroup"]
      api_scopes = [
        {
          value                      = "Platform.Read"
          admin_consent_display_name = "Read AI platform metadata"
          admin_consent_description  = "Allows read-only access to AI platform metadata and health data."
          user_consent_display_name  = "Read AI platform metadata"
          user_consent_description   = "Allows the app to read AI platform metadata."
          scope_type                 = "User"
        },
        {
          value                      = "Platform.Write"
          admin_consent_display_name = "Write AI platform configuration"
          admin_consent_description  = "Allows the app to change AI platform configuration."
          user_consent_display_name  = "Write AI platform configuration"
          user_consent_description   = "Allows the app to change AI platform configuration."
          scope_type                 = "Admin"
        },
        {
          value                      = "Platform.Admin"
          admin_consent_display_name = "Administer AI platform"
          admin_consent_description  = "Allows full administrative actions across the AI platform."
          user_consent_display_name  = "Administer AI platform"
          user_consent_description   = "Allows full administrative actions across the AI platform."
          scope_type                 = "Admin"
        },
        {
          value                      = "Models.Invoke"
          admin_consent_display_name = "Invoke platform-managed models"
          admin_consent_description  = "Allows inference requests through APIM."
          user_consent_display_name  = "Invoke platform-managed models"
          user_consent_description   = "Allows inference requests through APIM."
          scope_type                 = "User"
        },
        {
          value                      = "Models.Deploy"
          admin_consent_display_name = "Deploy platform-managed models"
          admin_consent_description  = "Allows model deployment and rollout operations."
          user_consent_display_name  = "Deploy platform-managed models"
          user_consent_description   = "Allows model deployment and rollout operations."
          scope_type                 = "Admin"
        }
      ]
      optional_claims = {
        access_token = [
          {
            name                  = "acct"
            essential             = false
            additional_properties = []
          }
        ]
        id_token = [
          {
            name                  = "email"
            essential             = false
            additional_properties = []
          }
        ]
      }
      pre_authorized_client_applications = [
        {
          client_id               = var.apim_portal_client_id
          permission_scope_values = ["Platform.Read", "Models.Invoke"]
        }
      ]
    }

    apim_backend = {
      display_name             = "msf-apim-backend"
      owners                   = var.identity_owners
      create_service_principal = true
      required_resource_access = [
        {
          resource_app_id = module.entra.client_ids["ai_platform_api"]
          resource_access = [
            {
              id   = module.entra.application_app_role_ids["ai_platform_api"]["Contributor"]
              type = "Role"
            }
          ]
        }
      ]
    }

    devops_sp = {
      display_name             = "msf-devops"
      owners                   = var.identity_owners
      create_service_principal = true
      federated_identity_credentials = {
        azure_devops = {
          display_name = "azure-devops-oidc"
          issuer       = var.azure_devops_oidc_issuer
          subject      = var.azure_devops_oidc_subject
        }
      }
    }
  }
}
```

## Conditional Access recommendations

Conditional Access requires Microsoft Entra ID P1/P2, so this module does not attempt to deploy those policies. Apply these controls outside Terraform or in a tenant-security stack:

- require phishing-resistant MFA for `Admin` operators and privileged portal access
- require compliant or hybrid-joined devices for interactive admin clients
- restrict admin flows to named locations or trusted networks
- block legacy authentication and use workload identity federation for CI/CD
- monitor risky sign-ins for API admin clients separately from workload identities

## Inputs

Prefer `applications`. Legacy single-app inputs remain for backward compatibility:

- `applications`
- `application_name`
- `api_scopes`
- `redirect_uris`
- `owners`
- `tags`

## Outputs

Legacy outputs are still exposed for single-app callers:

- `application_id`
- `client_id`
- `service_principal_id`
- `api_scope_ids`

Production callers should use the keyed outputs:

- `application_ids`
- `client_ids`
- `service_principal_ids`
- `application_api_scope_ids`
- `application_app_role_ids`
