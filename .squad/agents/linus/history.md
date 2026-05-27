# Linus — History

## Core Context

- **Project:** An extensible Azure AI Platform reference architecture with IaC, DevOps pipelines, and operational guidance enabling rapid provisioning of AI workloads
- **Role:** Identity & Security
- **Joined:** 2026-05-27T10:23:05.180Z

## Learnings

### 2026-05-27: Danny (Lead Architect) completed platform architecture

Danny designed and created the complete Azure AI Platform reference architecture including:

**Identity & Security Foundation**
- Entra RBAC model fully documented in ADR-0008
- Per-component app registrations with three profiles: Reader, Contributor, Admin
- Managed identities preferred for all service-to-service auth
- APIM validates Entra JWTs for all model access

**For Your Work**
- Entra patterns: `terraform/modules/entra/` and ADR-0008
- Implement per-component app registrations for all new services
- Use managed identities for Azure services
- Apply Entra RBAC profiles (Reader, Contributor, Admin) consistently
- All decisions in `.squad/decisions.md`

**Key Decisions**
- Entra app registrations with profiles instead of custom roles
- APIM as enforcement point for JWT validation
- Managed identities for infrastructure components

### 2026-05-27T07:18:33.309-04:00 — production hardening applied

- Expanded `terraform/modules/entra` to support multiple app registrations, trusted first-party pre-authorization, optional claims, group claims, and federated credentials for CI/CD identities.
- Hardened `terraform/modules/policy` with a bundled initiative, environment-aware Audit versus Deny defaults, approved-location enforcement, encryption-at-rest checks, private endpoint requirements, and deny-by-default network isolation.
- Captured the repo security baseline and private endpoint DNS mapping in `docs/guides/security-baseline.md` and `docs/guides/private-endpoint-reference.md`.

### 2026-05-27T13:11:30Z: Decision accepted — Production identity and policy hardening baseline

Your decision on production identity and policy hardening has been accepted and merged into the team decisions.md. This formalizes the approach for per-component app registrations, workload identity federation for CI/CD, and environment-aware policy effects (audit in lower environments, deny in production).
