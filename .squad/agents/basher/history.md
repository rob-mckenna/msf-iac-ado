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
