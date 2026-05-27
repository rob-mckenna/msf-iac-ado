---
name: "entra-hardening"
description: "Production-hardened Entra and Azure Policy patterns for the AI platform"
domain: "identity-and-security"
confidence: "high"
source: "earned"
---

## Context
Use this skill when adding or reviewing identity, RBAC, or private connectivity patterns for the Azure AI Platform. It captures the hardened baseline that aligns ADR-0008 with zero-trust networking and environment-aware governance rollout.

## Patterns
- Create separate Entra app registrations per component or trust boundary instead of reusing a single principal.
- Keep the platform profile vocabulary as `Reader`, `Contributor`, and `Admin` app roles.
- Publish API scopes for delegated user flows and use app roles for service-to-service authorization.
- Prefer managed identities first, workload identity federation second, and Key Vault-backed certificates only when a confidential client still needs a credential.
- Pre-authorize only trusted first-party applications and keep the approved scope list narrow.
- Bundle Azure Policy controls into a single initiative and default effects by environment: `Audit` in sandbox or poc, `Deny` in prod.
- Enforce network isolation with three distinct checks: public ingress disabled, private endpoints required, and network ACLs set to deny by default.

## Examples
- `terraform/modules/entra/` supports multiple app registrations, optional claims, group claims, pre-authorized clients, and federated identity credentials.
- `terraform/modules/policy/` defines the AI Platform Security Baseline initiative with approved-location, encryption, public ingress, private endpoint, and network ACL controls.
- `docs/guides/security-baseline.md` explains zero-trust identity flows and least-privilege RBAC.
- `docs/guides/private-endpoint-reference.md` maps private endpoint subresources to DNS zones.

## Anti-Patterns
- One service principal shared by APIM, workloads, and pipelines.
- Secrets stored in CI/CD variables when OIDC federation is available.
- Private endpoints created without matching private DNS zone linkage.
- Rolling out deny policies to lower environments before remediating drift.
