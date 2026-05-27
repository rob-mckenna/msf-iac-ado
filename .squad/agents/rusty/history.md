# Rusty — History

## Core Context

- **Project:** An extensible Azure AI Platform reference architecture with IaC, DevOps pipelines, and operational guidance enabling rapid provisioning of AI workloads
- **Role:** Infra Engineer
- **Joined:** 2026-05-27T10:23:05.175Z

## Learnings

### 2026-05-27T07:18:33.309-04:00: Production hardening pass for landing zone and workload compositions

- Hardened the hub-spoke networking stack with explicit hub subnets, Azure Firewall egress routing, spoke NSGs, route tables, and delegation support.
- Split landing-zone wiring cleanly across networking, DNS, Key Vault, policy, and workload compositions while avoiding shared tfvars name collisions by using composition-specific variables for workload resource groups and Fabric workspace names.
- Validation passed for networking, DNS, Key Vault, AI Foundry, and Fabric modules plus the AI Foundry and Fabric compositions; landing-zone validation is still blocked by pre-existing syntax errors in `terraform/modules/observability/`.

### 2026-05-27: Danny (Lead Architect) completed platform architecture

Danny designed and created the complete Azure AI Platform reference architecture including:

**Terraform Foundation**
- 9 modules created: vnet, firewall, apim, entra, observability, keyvault, storage, roles, policy
- 5 compositions: hub, ai-workload, app-workload, data-workload, security-baseline
- 3 environment configs: sandbox, poc, prod
- Module composition pattern documented in ADR-0002 — shared modules are single-concern, never call each other

**For Your Work**
- Use the module/composition pattern for all infrastructure work
- Follow ADR-0004 for naming: `{project}-{component}-{environment}-{region}-{instance}` (project prefix: `msf`)
- Apply ADR-0005 tagging strategy: environment, project, owner, cost-center, managed-by, created-date
- Reference: `terraform/modules/` and `terraform/compositions/` — build on this foundation

**Key Decisions**
- Azure Storage Account for Terraform state: one tfstate per composition per environment
- Environment promotion: sandbox → poc → prod (manual with plan review gates)
- Hub-spoke network topology with Firewall + DNS Private Resolver
- All decisions in `.squad/decisions.md`

### 2026-05-27T13:11:30Z: Decision accepted — Composition-specific variable names

Your proposed decision on composition-specific variable names (e.g., `ai_foundry_resource_group_name`) has been accepted and merged into the team decisions.md. This formalizes the shared tfvars naming convention to prevent collisions between landing-zone, AI Foundry, and Fabric deployments.
