# Decisions

## Decision: Azure AI Platform Repository Architecture

**Author:** Danny (Lead Architect)
**Date:** 2026-05-27
**Status:** Accepted

### Context

Greenfield repo for an Azure AI Platform reference architecture. Needed a foundation that enables the team to build out IaC, pipelines, and operational tooling for AI workloads on Azure.

### Key Decisions

1. **Terraform Module Composition Pattern** — Two-tier hierarchy: shared modules (`terraform/modules/`) and compositions (`terraform/compositions/`). Compositions are the unit of deployment. Shared modules are single-concern and never call each other. See ADR-0002.

2. **Environment Promotion Model** — Three environments: sandbox → poc → prod. Each has its own tfvars, state file, and pipeline stages. Promotion is manual with plan review gates. See ADR-0003.

3. **Terraform State Management** — Azure Storage Account backend. One state file per composition per environment, keyed as `{composition}-{environment}.tfstate`. Soft-delete and versioning enabled. See ADR-0001.

4. **Naming Convention** — Pattern: `{project}-{component}-{environment}-{region}-{instance}`. Project prefix: `msf`. See ADR-0004.

5. **Tagging Strategy** — Required tags: environment, project, owner, cost-center, managed-by, created-date. Enforced by Azure Policy. See ADR-0005.

6. **Network Topology** — Hub-spoke model. Hub VNet has Firewall + DNS Private Resolver. Each workload type gets a spoke. All PaaS services use private endpoints. No public inbound to AI services. See ADR-0006.

7. **AI Gateway Pattern** — APIM serves as the AI Gateway. All model access goes through APIM. MCP servers registered as APIM APIs with tool discovery. See ADR-0007.

8. **Entra RBAC Model** — Per-component app registrations. Three profiles: Reader, Contributor, Admin. Managed identities preferred. APIM validates Entra JWTs. See ADR-0008.

9. **Pipeline Structure** — Azure DevOps YAML pipelines with reusable templates. Separate infra and deploy pipeline directories. Multi-stage with approval gates for poc and prod. See `pipelines/README.md`.

10. **ADO Pipeline Structure** — Standardize on reusable Terraform stage templates in `pipelines\templates`. Keep environment promotion explicit in composition pipelines as sandbox -> poc -> prod with manual approval before higher environments. Separate infra composition pipelines from AI artifact deployment pipelines under `pipelines\infra` and `pipelines\deploy`. This keeps environment promotion consistent across platform teams and makes approvals predictable for shared services.

11. **.gitignore** — Updated for Terraform + Azure DevOps + secrets exclusion.

### Impact

All team members should use these patterns when building out their domains:
- **Rusty** — Follow the module/composition pattern for all Terraform work
- **Basher** — Use the pipeline templates for all new pipelines
- **Linus** — Entra patterns are in ADR-0008 and `terraform/modules/entra/`
- **Livingston** — Observability baseline is in `terraform/modules/observability/` and APIM patterns in ADR-0007

---

## Decision: Composition-specific variable names

**Author:** Rusty  
**Date:** 2026-05-27  
**Status:** Accepted

### Context
Shared tfvars are consumed by multiple Terraform compositions in this repo. Generic names like `resource_group_name` or `workspace_name` cause collisions between landing-zone, AI Foundry, and Fabric deployments.

### Decision
Use composition-specific variable names for workload-scoped settings in shared environment tfvars.

### Examples
- `ai_foundry_resource_group_name`
- `ai_foundry_workspace_name`
- `fabric_resource_group_name`
- `fabric_workspace_name`

### Impact
Composition-scoped settings stay in shared tfvars while maintaining deployable composition boundaries.

---

## Decision: Production identity and policy hardening baseline

**Author:** Linus  
**Date:** 2026-05-27  
**Status:** Accepted

### Context
The platform already standardized on per-component Entra applications, managed identities, and APIM JWT validation. Production hardening required a repeatable baseline for trusted first-party clients, CI/CD identities, and policy enforcement that can start in audit mode outside production and move to deny mode in production.

### Decision
- Keep per-component app registrations and add a module pattern for multiple registrations in one deployment.
- Use workload identity federation for DevOps-style automation instead of stored client secrets whenever the external system supports OIDC.
- Bundle platform governance into a single policy initiative and resolve effects by environment: audit-first in sandbox and poc, deny-first in prod.
- Treat public ingress denial, private endpoint requirements, and deny-by-default network ACLs as separate controls so exemptions can stay narrow.

### Impact
- Platform teams can wire API, APIM backend, and automation identities without reusing a single service principal.
- Security rollout is safer because lower environments can measure drift before production denial is enforced.
- Future workloads should align to the documented private endpoint and DNS patterns rather than inventing new ones ad hoc.

---

## Decision: Pipeline promotion contract for Azure DevOps

**Author:** Basher  
**Date:** 2026-05-27  
**Status:** Accepted

### Context
Multiple compositions require coordinated promotion through sandbox → poc → prod with environment-specific variable groups, service connections, and approval gates.

### Decision
Standardize Azure DevOps infrastructure pipelines on reusable validate → plan → apply templates with environment-specific backend variables, env-suffixed service connection variables, PR plan comments, and apply evidence artifacts. Downstream AI Foundry and APIM infrastructure must block until landing-zone remote state exists for the target environment.

### Impact
- Every platform team has the same promotion guardrails.
- Cross-composition ordering is explicit without relying on pipeline naming conventions.
- Variable group setup is predictable for new compositions.
- poc/prod approvals align with the existing sandbox → poc → prod operating model.

---

## Decision: Reusable AI Gateway routing and observability wiring

**Author:** Livingston  
**Date:** 2026-05-27  
**Status:** Accepted

### Context
APIM policies must move across environments without per-environment edits. Observability setup must be composition-owned and support independent retention and RBAC for sensitive telemetry.

### Decision
Standardize AI Gateway routing through APIM named-value catalogs so the same policy XML can move across environments without per-environment edits. Standardize observability onboarding through a composition-owned `diagnostic_targets` map and a dedicated content safety workspace with independent retention and RBAC.

### Impact
- APIM policy files are reusable across environments.
- Compositions supply environment-specific backend and MCP catalogs.
- Platform teams have a single pattern for attaching APIM, AI Foundry, and Key Vault telemetry to shared monitoring.

