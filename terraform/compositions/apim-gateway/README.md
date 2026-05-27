# apim-gateway composition

Deploys the platform AI Gateway using Azure API Management and a companion Entra application registration.

## Dependencies

Reads landing zone remote state for:

- private networking outputs
- shared Application Insights instrumentation and resource IDs

## What it wires together

- Entra application registration used as the JWT audience for the gateway
- APIM products and APIs for OpenAI-compatible traffic and MCP tools
- Azure OpenAI backend routing catalog, semantic caching, and content safety settings
- APIM diagnostics to Application Insights
