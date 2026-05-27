# AI Gateway Patterns

This guide documents the production-grade AI Gateway and observability patterns used in this repository.

## Request flow

```text
client -> APIM -> Azure OpenAI
```

The end-to-end flow is:

1. Client calls the OpenAI-compatible APIM API.
2. APIM validates the Entra JWT against the platform app registration audience.
3. APIM applies subscription-tier rate limiting and request telemetry.
4. Content safety runs before model invocation for prompt screening.
5. Product policy selects a backend using model-aware routing plus weighted load balancing.
6. APIM acquires a managed identity token for Azure OpenAI.
7. APIM retries transient 429 and 5xx failures.
8. Content safety runs again on the model response.
9. APIM logs prompt, completion, and total tokens to Application Insights.
10. Observability alerts and saved searches surface latency, failure, safety, and usage trends.

## MCP server catalog pattern

MCP servers are exposed as APIM APIs under the `/mcp` path. Register new MCP tools by updating the `mcp_tool_catalog` input on the APIM gateway composition with:

- the tool name
- the backend URL
- an optional path prefix
- allowed transport protocols

The MCP API policy handles:

- JWT validation
- cached tool discovery on `GET /tools`
- tool lookup and backend routing for `POST /tools/{toolName}/invoke`
- SSE passthrough for `GET /sse`

## Model routing strategy

The AI Gateway product policy uses a JSON routing catalog stored in an APIM named value. Each backend entry carries:

- backend URL
- supported models
- routing priority
- routing weight
- Azure OpenAI API version
- managed identity client ID reference

Routing behavior follows this order:

1. match backends that explicitly list the requested model
2. sort by priority
3. apply weighted selection for round-robin distribution within the eligible set
4. retry transient failures before surfacing an error
5. fall back to the broader backend pool if no model-specific route exists

Use priorities to express failover intent and weights to spread load across equivalent Azure OpenAI instances.

## Monitoring and alerting strategy

The observability module provides:

- Application Insights for APIM request and token telemetry
- a primary Log Analytics workspace for shared platform telemetry
- a dedicated content safety workspace with longer retention and tighter access
- saved searches for latency, error rate, token usage, and content safety events
- scheduled query alerts for p95 latency, error rate, and hourly token consumption
- action groups with email and webhook receivers
- reusable diagnostic settings for APIM, AI Foundry, Key Vault, and similar resources

Recommended onboarding pattern:

1. add the target resource ID to `diagnostic_targets`
2. specify resource-appropriate log and metric categories
3. route high-sensitivity streams to the content safety workspace when needed
4. connect the action group to incident management and chatops webhooks

## Cost management via token tracking

The AI Gateway policy logs prompt, completion, and total tokens as structured telemetry. Use those token dimensions to:

- break usage down by subscription and model
- identify unexpected token spikes
- estimate per-model cost trends
- drive budget notifications at the resource-group layer

Pair token saved searches with the workbook template to create usage dashboards for platform operations and FinOps review.
