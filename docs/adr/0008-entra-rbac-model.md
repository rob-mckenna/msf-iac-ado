# ADR 0008: Entra RBAC Model

## Status
Accepted

## Date
2026-05-27

## Context
The platform requires a clear identity and authorization model for end users, operators, workloads, and automation. Access controls must support least privilege, consistent API security, and operational separation of duties across environments.

## Decision
Assign each platform component its own Entra app registration with defined API scopes. Define three access profiles: `Reader` for read-only access to models and data, `Contributor` for deploying and managing AI workloads, and `Admin` for full platform management. APIM validates Entra-issued JWTs. AI Foundry workspace access is granted through Entra groups mapped to Azure RBAC roles. Pipeline automation uses service principals with least-privilege scope limited to specific resource groups. Managed identities are preferred over service principal secrets whenever possible.

## Consequences
The platform gains clearer role boundaries and stronger alignment between Entra identities and Azure authorization. Identity design and group management require upfront planning and ongoing governance. Automation becomes safer through scoped identities, but role assignments and app registrations must be maintained as the platform grows.
