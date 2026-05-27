---
name: "ai-gateway-observability"
description: "Reusable APIM AI Gateway plus observability wiring pattern"
domain: "api-platform"
confidence: "high"
source: "earned"
---

## Context
When building APIM as an AI Gateway for Azure OpenAI and MCP traffic, keep policy XML reusable and move environment-specific routing, endpoints, and thresholds into Terraform composition inputs.

## Patterns

### APIM module
- Create OpenAI-compatible and MCP APIs in the APIM module.
- Publish backend routing and MCP tool catalogs as APIM named values.
- Keep JWT audience, content safety endpoint, cache TTLs, and backend URLs in named values.
- Source service, product, API, and fragment policies from `policies/apim-policy/`.

### Policy design
- Put JWT validation, CORS, request logging, and structured errors in the global policy.
- Put routing, semantic caching, retries, and token telemetry in the product policy.
- Put tool discovery, invocation routing, and SSE handling in the MCP API policy.
- Use a content safety fragment for both pre- and post-model moderation.

### Observability
- Split shared telemetry and content safety telemetry into separate Log Analytics workspaces.
- Use a `diagnostic_targets` map so compositions can onboard APIM, AI Foundry, Key Vault, and similar resources without changing the module.
- Create scheduled query alerts from workspace data for latency, error rate, and token consumption.
- Publish dashboard and workbook JSON as module outputs for downstream deployment or portal import.
