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
- Environment codes: sbx (sandbox), poc, prd (prod)
- Same composition, different variables = different environment

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
