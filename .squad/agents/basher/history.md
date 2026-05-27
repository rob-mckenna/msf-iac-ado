# Basher — History

## Core Context

- **Project:** An extensible Azure AI Platform reference architecture with IaC, DevOps pipelines, and operational guidance enabling rapid provisioning of AI workloads
- **Role:** DevOps Engineer
- **Joined:** 2026-05-27T10:23:05.184Z

## Learnings

### 2026-05-27: Danny (Lead Architect) completed platform architecture

Danny designed and created the complete Azure AI Platform reference architecture including:

**Pipeline Foundation**
- 4 reusable Terraform stage templates in `pipelines/templates/`: terraform-init, terraform-plan, terraform-apply, terraform-destroy
- 6 composition pipelines: hub-infrastructure, ai-workload, app-workload, data-workload, security-baseline, model-deployment
- Separate `pipelines/infra` and `pipelines/deploy` directories for clarity
- Environment promotion model: sandbox → poc → prod with manual approval gates

**For Your Work**
- Use reusable YAML templates from `pipelines/templates/` for all Terraform stages
- Follow environment promotion: sandbox (auto) → poc (manual approval) → prod (manual approval)
- Separate infrastructure composition pipelines from deployment pipelines
- Reference ADO pipeline structure decision in `.squad/decisions.md`
- All templates documented in `pipelines/README.md`

**Key Decisions**
- Reusable YAML templates for consistency across compositions
- Explicit approval gates for poc and prod environments
- Clear separation of concerns: infra vs. deployment

### 2026-05-27T07:18:33.309-04:00: Productionized Azure DevOps pipeline promotion flow

- Added reusable validate, plan, apply, and destroy safeguards with provider cache, state lock checks, PR plan comments, checksummed artifacts, state backups, smoke tests, and production destroy double confirmation.
- Standardized infra pipelines on sandbox → poc → prod promotion with landing-zone prerequisite enforcement for downstream AI Foundry and APIM compositions.
- Added deployment patterns for AI Foundry agents, Prompt Flow, and Copilot Studio plus a pull-request CI pipeline for fmt, validate, Checkov, policy, and documentation checks.
- Locked Terraform provider majors for composition validation and fixed Terraform compatibility issues in landing-zone, observability, and APIM outputs so CI validation passes.

### 2026-05-27T13:11:30Z: Decision accepted — Pipeline promotion contract for Azure DevOps

Your decision on the Azure DevOps pipeline promotion contract has been accepted and merged into the team decisions.md. This standardizes infrastructure pipelines on reusable validate → plan → apply templates with environment-specific backend variables, env-suffixed service connection variables, and cross-composition blocking rules.
