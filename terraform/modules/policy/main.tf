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
  effect_value_map = {
    audit    = "Audit"
    deny     = "Deny"
    disabled = "Disabled"
  }

  default_effect = lower(var.environment_tier) == "prod" ? "Deny" : "Audit"

  resolved_allowed_locations = length(var.allowed_locations) > 0 ? var.allowed_locations : [var.location]

  effect_parameter = {
    effect = {
      type = "String"
      metadata = {
        displayName = "Effect"
        description = "Policy effect"
      }
      allowedValues = ["Deny", "Audit", "Disabled"]
      defaultValue  = "Audit"
    }
  }

  policy_definitions = {
    enforce_tags = {
      display_name = "Enforce required platform tags"
      description  = "Requires the platform tagging baseline on all deployable resources."
      category     = "Tags"
      version      = "1.1.0"
      mode         = "Indexed"
      group        = "governance"
      rule = {
        if = {
          allOf = [
            {
              field     = "type"
              notEquals = "Microsoft.Resources/subscriptions/resourceGroups"
            },
            {
              anyOf = [for tag_name in var.required_tags : {
                field  = format("tags['%s']", tag_name)
                exists = "false"
              }]
            }
          ]
        }
        then = {
          effect = "[parameters('effect')]"
        }
      }
    }
    allowed_locations = {
      display_name = "Allow only approved Azure regions"
      description  = "Restricts platform resources to approved Azure regions. Add global where needed for tenant-level services."
      category     = "Governance"
      version      = "1.0.0"
      mode         = "Indexed"
      group        = "governance"
      rule = {
        if = {
          allOf = [
            {
              field     = "type"
              notEquals = "Microsoft.Resources/subscriptions/resourceGroups"
            },
            {
              field     = "location"
              notEquals = "global"
            },
            {
              field = "location"
              notIn = local.resolved_allowed_locations
            }
          ]
        }
        then = {
          effect = "[parameters('effect')]"
        }
      }
    }
    require_encryption_at_rest = {
      display_name = "Require encryption at rest on platform storage"
      description  = "Requires infrastructure encryption on storage accounts that hold AI platform state and artifacts."
      category     = "Data Protection"
      version      = "1.0.0"
      mode         = "Indexed"
      group        = "data-protection"
      rule = {
        if = {
          allOf = [
            {
              field  = "type"
              equals = "Microsoft.Storage/storageAccounts"
            },
            {
              field     = "Microsoft.Storage/storageAccounts/encryption.requireInfrastructureEncryption"
              notEquals = "true"
            }
          ]
        }
        then = {
          effect = "[parameters('effect')]"
        }
      }
    }
    restrict_public_access = {
      display_name = "Deny public access on core platform services"
      description  = "Blocks storage, Key Vault, and Container Registry resources when public network access remains enabled."
      category     = "Network"
      version      = "1.1.0"
      mode         = "Indexed"
      group        = "network-isolation"
      rule = {
        if = {
          anyOf = [
            {
              allOf = [
                { field = "type", equals = "Microsoft.Storage/storageAccounts" },
                { field = "Microsoft.Storage/storageAccounts/publicNetworkAccess", notEquals = "Disabled" }
              ]
            },
            {
              allOf = [
                { field = "type", equals = "Microsoft.KeyVault/vaults" },
                { field = "Microsoft.KeyVault/vaults/publicNetworkAccess", notEquals = "Disabled" }
              ]
            },
            {
              allOf = [
                { field = "type", equals = "Microsoft.ContainerRegistry/registries" },
                { field = "Microsoft.ContainerRegistry/registries/publicNetworkAccess", notEquals = "Disabled" }
              ]
            }
          ]
        }
        then = {
          effect = "[parameters('effect')]"
        }
      }
    }
    deny_public_ip_ai_services = {
      display_name = "Deny public ingress on AI services"
      description  = "Blocks Azure AI Foundry and Cognitive Services resources when public ingress is exposed. For PaaS AI services this is the public IP equivalent control surface."
      category     = "Network"
      version      = "1.0.0"
      mode         = "Indexed"
      group        = "network-isolation"
      rule = {
        if = {
          anyOf = [
            {
              allOf = [
                { field = "type", equals = "Microsoft.CognitiveServices/accounts" },
                { field = "Microsoft.CognitiveServices/accounts/publicNetworkAccess", notEquals = "Disabled" }
              ]
            },
            {
              allOf = [
                { field = "type", equals = "Microsoft.MachineLearningServices/workspaces" },
                { field = "Microsoft.MachineLearningServices/workspaces/publicNetworkAccess", notEquals = "Disabled" }
              ]
            }
          ]
        }
        then = {
          effect = "[parameters('effect')]"
        }
      }
    }
    require_private_endpoints = {
      display_name = "Require private endpoints for AI platform services"
      description  = "Requires private endpoint connections for storage, Key Vault, Container Registry, Azure AI, and AI Foundry workspaces."
      category     = "Network"
      version      = "1.1.0"
      mode         = "Indexed"
      group        = "network-isolation"
      rule = {
        if = {
          anyOf = [
            {
              allOf = [
                { field = "type", equals = "Microsoft.Storage/storageAccounts" },
                { count = { field = "Microsoft.Storage/storageAccounts/privateEndpointConnections[*]" }, equals = 0 }
              ]
            },
            {
              allOf = [
                { field = "type", equals = "Microsoft.KeyVault/vaults" },
                { count = { field = "Microsoft.KeyVault/vaults/privateEndpointConnections[*]" }, equals = 0 }
              ]
            },
            {
              allOf = [
                { field = "type", equals = "Microsoft.ContainerRegistry/registries" },
                { count = { field = "Microsoft.ContainerRegistry/registries/privateEndpointConnections[*]" }, equals = 0 }
              ]
            },
            {
              allOf = [
                { field = "type", equals = "Microsoft.CognitiveServices/accounts" },
                { count = { field = "Microsoft.CognitiveServices/accounts/privateEndpointConnections[*]" }, equals = 0 }
              ]
            },
            {
              allOf = [
                { field = "type", equals = "Microsoft.MachineLearningServices/workspaces" },
                { count = { field = "Microsoft.MachineLearningServices/workspaces/privateEndpointConnections[*]" }, equals = 0 }
              ]
            }
          ]
        }
        then = {
          effect = "[parameters('effect')]"
        }
      }
    }
    enforce_network_isolation = {
      display_name = "Enforce deny-by-default network isolation"
      description  = "Requires deny-by-default network ACL posture on platform services even when private endpoints are present."
      category     = "Network"
      version      = "1.0.0"
      mode         = "Indexed"
      group        = "network-isolation"
      rule = {
        if = {
          anyOf = [
            {
              allOf = [
                { field = "type", equals = "Microsoft.Storage/storageAccounts" },
                { field = "Microsoft.Storage/storageAccounts/networkAcls.defaultAction", notEquals = "Deny" }
              ]
            },
            {
              allOf = [
                { field = "type", equals = "Microsoft.KeyVault/vaults" },
                { field = "Microsoft.KeyVault/vaults/networkAcls.defaultAction", notEquals = "Deny" }
              ]
            },
            {
              allOf = [
                { field = "type", equals = "Microsoft.CognitiveServices/accounts" },
                { field = "Microsoft.CognitiveServices/accounts/networkAcls.defaultAction", notEquals = "Deny" }
              ]
            }
          ]
        }
        then = {
          effect = "[parameters('effect')]"
        }
      }
    }
  }

  resolved_policy_effects = {
    for key, definition in local.policy_definitions : key => lookup(
      local.effect_value_map,
      lower(lookup(var.policy_effect_overrides, key, var.default_policy_effect != null ? var.default_policy_effect : local.default_effect)),
      local.default_effect
    )
  }
}

resource "azurerm_policy_definition" "this" {
  for_each = local.policy_definitions

  name         = format("%s-%s", var.policy_prefix, each.key)
  policy_type  = "Custom"
  mode         = each.value.mode
  display_name = each.value.display_name
  description  = each.value.description
  policy_rule  = jsonencode(each.value.rule)
  parameters   = jsonencode(local.effect_parameter)
  metadata = jsonencode({
    category = each.value.category
    version  = each.value.version
  })
}

resource "azurerm_policy_set_definition" "ai_platform" {
  name         = format("%s-ai-platform-baseline", var.policy_prefix)
  policy_type  = "Custom"
  display_name = "AI Platform Security Baseline"
  description  = "Baseline initiative for AI platform governance, data protection, and network isolation."
  parameters   = jsonencode({})
  metadata = jsonencode({
    category = "AI Platform Governance"
    version  = "1.0.0"
  })

  policy_definition_group {
    name         = "governance"
    category     = "Governance"
    display_name = "Governance controls"
    description  = "Tagging and regional placement controls."
  }

  policy_definition_group {
    name         = "data-protection"
    category     = "Data Protection"
    display_name = "Data protection controls"
    description  = "Encryption and data protection controls."
  }

  policy_definition_group {
    name         = "network-isolation"
    category     = "Network"
    display_name = "Network isolation controls"
    description  = "Public ingress, private endpoint, and default-deny network controls."
  }

  dynamic "policy_definition_reference" {
    for_each = local.policy_definitions

    content {
      policy_definition_id = azurerm_policy_definition.this[policy_definition_reference.key].id
      reference_id         = policy_definition_reference.key
      policy_group_names   = [policy_definition_reference.value.group]
      parameter_values = jsonencode({
        effect = {
          value = local.resolved_policy_effects[policy_definition_reference.key]
        }
      })
    }
  }
}

resource "azurerm_subscription_policy_assignment" "ai_platform" {
  name                 = format("%s-ai-platform-baseline", var.policy_prefix)
  subscription_id      = var.subscription_id
  policy_definition_id = azurerm_policy_set_definition.ai_platform.id
  display_name         = "AI Platform Security Baseline"
  description          = format("Assignment for the AI platform baseline initiative in %s mode.", lower(var.environment_tier))
  location             = var.location
  enforce              = var.assignment_enforcement_enabled
  metadata = jsonencode({
    environmentTier  = lower(var.environment_tier)
    allowedLocations = local.resolved_allowed_locations
    policyEffects    = local.resolved_policy_effects
  })

  identity {
    type = "SystemAssigned"
  }
}
