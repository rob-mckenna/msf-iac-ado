# APIM policies

These policy files provide reusable API Management controls for the AI Gateway surface.

## Files

- `ai-gateway-global.xml` – service-level controls for CORS, JWT validation, subscription-tier rate limiting, content safety inclusion, telemetry, and structured error handling.
- `ai-gateway-product.xml` – product-level controls for token estimation, semantic caching, model routing, weighted load balancing, managed identity auth, retries, and token usage logging.
- `mcp-server.xml` – controls for MCP server APIs, including JWT validation, tool discovery caching, tool invocation routing, and SSE streaming support.
- `content-safety.xml` – reusable fragment for pre- and post-model moderation with Azure Content Safety.
