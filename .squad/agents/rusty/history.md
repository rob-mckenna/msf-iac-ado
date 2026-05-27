# Rusty — History

## Core Context

- **Project:** An extensible Azure AI Platform reference architecture with IaC, DevOps pipelines, and operational guidance enabling rapid provisioning of AI workloads
- **Role:** Infra Engineer
- **Joined:** 2026-05-27T10:23:05.175Z

## Learnings

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
