---
name: "ado-pipeline-promotion"
description: "Reusable Azure DevOps promotion pattern for Terraform infrastructure and AI artifact deployment"
domain: "devops"
confidence: "high"
source: "earned"
---

## Context
Use this skill when building Azure DevOps YAML for this repo's infrastructure and deployment pipelines.

## Patterns
- Promote environments explicitly: `sandbox -> poc -> prod`.
- Keep reusable Terraform behavior in `pipelines/templates/` and composition orchestration in `pipelines/infra/`.
- Require manual approval before higher environments and publish evidence artifacts for plan/apply/destroy workflows.
- Use env-suffixed variable names in Azure DevOps variable groups for service connections and backend configuration.
- Block downstream compositions like AI Foundry or APIM until landing-zone state exists for the same environment.

## Examples
- `pipelines/templates/terraform-plan.yml`
- `pipelines/templates/terraform-apply.yml`
- `pipelines/infra/landing-zone.yml`
- `pipelines/templates/variable-groups.md`

## Anti-Patterns
- Hardcoding service connection names directly into every step.
- Skipping plan artifact review on poc or prod promotions.
- Letting downstream compositions deploy before landing-zone state exists.
- Running destroy without inventory, backend soft-delete checks, and extra production confirmation.
