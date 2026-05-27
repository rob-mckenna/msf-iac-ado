# ADR 0007: AI Gateway Pattern

## Status
Accepted

## Date
2026-05-27

## Context
The platform needs centralized governance for AI model consumption, policy enforcement, monitoring, and controlled exposure of model capabilities and tools. A direct-to-endpoint model would fragment access control and operational visibility.

## Decision
Use Azure API Management (APIM) as the AI Gateway fronting all AI model endpoints. APIM provides rate limiting per subscription, JWT-based authentication through Entra, content safety policy enforcement, usage metering and logging, and backend load balancing across model deployments. Model Context Protocol (MCP) servers are registered in a catalog managed through APIM products. Each MCP server is exposed as an APIM API with tool discovery endpoints.

## Consequences
All AI model consumption flows through APIM, and direct endpoint access is not allowed. This improves governance, observability, and control, but it adds APIM configuration and runtime dependency to every AI integration. MCP onboarding must align with APIM product and API lifecycle management.
