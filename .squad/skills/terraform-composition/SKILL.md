---
name: "terraform-composition"
description: "Two-tier Terraform module composition pattern for Azure platform IaC"
domain: "infrastructure-as-code"
confidence: "high"
source: "earned"
---

## Context
When building Terraform IaC for a multi-component Azure platform, use a two-tier module hierarchy to balance reusability with deployment independence.

## Patterns

### Shared Modules (`terraform/modules/`)
- Single-concern: one module per Azure service or capability
- Never call other shared modules (flat hierarchy)
- Accept all configuration via variables — no hardcoded values
- Export outputs for composition wiring
- Each module has: main.tf, variables.tf, outputs.tf, README.md

### Compositions (`terraform/compositions/`)
- Root modules that wire shared modules together
- Each composition is a deployable unit with its own state
- Contains: main.tf, variables.tf, outputs.tf, backend.tf, providers.tf
- Uses `module` blocks to reference shared modules with relative paths
- Cross-composition references use `terraform_remote_state` data sources

### Environments (`terraform/environments/`)
- One tfvars file per environment per composition
- When a shared tfvars file is reused across multiple compositions, use composition-specific variable names for workload-scoped values (for example `ai_foundry_resource_group_name`, `fabric_workspace_name`) to avoid cross-composition collisions.
- Same composition, different variables = different environment

### Landing Zone Hardening
- Model hub-spoke foundations with explicit hub subnet prefixes for Azure Firewall, GatewaySubnet, and DNS Private Resolver.
- Push common outputs as maps (`hub_subnet_ids`, `spoke_subnet_ids`, `private_dns_zone_ids`) so downstream compositions can consume the platform without hardcoded IDs.
- Keep shared module provider constraints aligned with composition roots to avoid provider-major-version drift during validation.

## Examples
```hcl
# terraform/compositions/landing-zone/main.tf
module "networking" {
  source = "../../modules/networking"
  # ... variables from composition-level vars
}
module "dns" {
  source = "../../modules/dns"
  hub_vnet_id = module.networking.hub_vnet_id
}
```

## Anti-Patterns
- Shared modules calling other shared modules (creates hidden dependencies)
- Deploying shared modules directly (always deploy via compositions)
- Single monolithic root module for the entire platform (blast radius too large)
- Sharing state files across compositions (breaks deployment independence)
