# Livingston — History

## Core Context

- **Project:** An extensible Azure AI Platform reference architecture with IaC, DevOps pipelines, and operational guidance enabling rapid provisioning of AI workloads
- **Role:** API & Observability
- **Joined:** 2026-05-27T10:23:05.187Z

## Learnings

### 2026-05-27: Danny (Lead Architect) completed platform architecture

Danny designed and created the complete Azure AI Platform reference architecture including:

**API Gateway & Observability Foundation**
- APIM as the AI Gateway — all model access routed through APIM
- MCP servers registered as APIM APIs with tool discovery enabled
- APIM validates Entra JWTs for authentication
- Observability module baseline in `terraform/modules/observability/`
- ADR-0007 documents AI Gateway pattern in detail

**For Your Work**
- APIM as centralized AI Gateway: all model requests flow through it
- MCP servers registered as APIM APIs with tool discovery
- Implement observability patterns from `terraform/modules/observability/`
- Reference ADR-0007 for AI Gateway architectural decisions
- APIM endpoints documented in `docs/ARCHITECTURE.md`
- All decisions in `.squad/decisions.md`

**Key Decisions**
- APIM as single control point for all AI model access
- MCP tool discovery integrated into APIM API registration
- Hub-spoke topology with Firewall: centralized security and routing
- Entra JWT validation enforced at APIM layer

### 2026-05-27T07:18:33.309-04:00: Production AI Gateway and observability hardening

- Upgraded the APIM module to publish OpenAI-compatible and MCP APIs, reusable named-value routing catalogs, JWT-aware gateway policies, and a content safety fragment.
- Extended observability with AI latency, error-rate, and token alerts; saved KQL searches; diagnostic settings onboarding; budget wiring; and separate content safety logging controls.
- Documented AI Gateway request flow, MCP onboarding, model routing, monitoring, and token-based cost management in `docs/guides/ai-gateway-patterns.md`.

### 2026-05-27T13:11:30Z: Decision accepted — Reusable AI Gateway routing and observability wiring

Your decision on reusable AI Gateway routing and observability wiring has been accepted and merged into the team decisions.md. This standardizes APIM named-value catalogs for environment portability and composition-owned diagnostic_targets maps for independent observability and RBAC control.
