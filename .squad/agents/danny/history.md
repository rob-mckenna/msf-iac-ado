# Danny — History

## Core Context

- **Project:** An extensible Azure AI Platform reference architecture with IaC, DevOps pipelines, and operational guidance enabling rapid provisioning of AI workloads
- **Role:** Lead Architect
- **Joined:** 2026-05-27T10:23:05.170Z

## Learnings

<!-- Append learnings below -->

### 2026-05-27 — Repository Architecture Foundation

**What was done:** Designed and created the complete project structure for the Azure AI Platform reference architecture repository. This is the greenfield foundation everything else builds on.

**Key architectural decisions (all documented as ADRs in docs/adr/):**
- **ADR-0001:** Terraform state in Azure Storage, one state file per composition per environment
- **ADR-0002:** Two-tier module composition — shared modules + compositions (root modules)
- **ADR-0003:** Three-environment promotion: sandbox → poc → prod, manual gates
- **ADR-0004:** Naming convention: `{project}-{component}-{environment}-{region}-{instance}`, prefix `msf`
- **ADR-0005:** Required tags: environment, project, owner, cost-center, managed-by, created-date
- **ADR-0006:** Hub-spoke networking, private endpoints for all PaaS, no public inbound
- **ADR-0007:** APIM as AI Gateway, MCP servers as APIM APIs
- **ADR-0008:** Entra app registrations with Reader/Contributor/Admin profiles, managed identities preferred

**Directory structure created:**
- `terraform/modules/` — networking, ai-foundry, fabric, apim, entra, observability, dns, key-vault, policy
- `terraform/compositions/` — landing-zone, ai-foundry-workspace, fabric-workspace, apim-gateway, observability
- `terraform/environments/` — sandbox, poc, prod (tfvars)
- `pipelines/templates/` — terraform-init, terraform-plan, terraform-apply, terraform-destroy
- `pipelines/infra/` — landing-zone, ai-foundry, fabric-workspace, apim-gateway
- `pipelines/deploy/` — agent-deploy, flow-deploy
- `policies/azure-policy/` — require-private-endpoints, enforce-tagging, deny-public-access
- `policies/apim-policy/` — ai-gateway-global, ai-gateway-product, mcp-server
- `scripts/` — init-backend.ps1, validate-naming.ps1, new-ai-workload.ps1
- `docs/adr/` — 8 ADRs
- `docs/architecture/` — overview with mermaid diagrams
- `docs/guides/` — getting-started, onboarding-new-workload

**User preferences:**
- Rob wants Terraform (not Bicep) for all IaC
- Rob wants Azure DevOps (not GitHub Actions) for all pipelines
- Azure-native stack throughout

**Patterns established:**
- Compositions are the unit of deployment, not individual modules
- Shared modules are flat (no module-to-module calls)
- Pipeline templates are reusable across compositions
- Environment promotion requires explicit plan review at each stage
