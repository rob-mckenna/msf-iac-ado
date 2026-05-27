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

