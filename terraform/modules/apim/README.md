# apim module

Deploys an internal Azure API Management instance for platform and AI gateway scenarios.

## What it creates

- API Management instance in internal VNet mode
- platform and AI gateway products
- OpenAI-compatible AI Gateway API and MCP gateway API definitions
- backend entities for Azure OpenAI endpoints
- named values for Entra audience, backend URLs, managed identity client IDs, routing catalogs, and content safety settings
- reusable content safety policy fragment
- Application Insights logger and gateway diagnostic configuration
- global, product, and MCP API policies sourced from `policies\apim-policy\`

## Key inputs

- `platform_app_client_id` and `platform_tenant_id` for JWT validation
- `azure_openai_backends` for model routing, failover, and load balancing
- `content_safety` for pre/post moderation
- `mcp_tool_catalog` for MCP tool discovery and invocation routing
