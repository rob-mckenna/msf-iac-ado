# observability module

Deploys the shared monitoring foundation for the platform.

## What it creates

- primary Log Analytics workspace
- dedicated content safety logging workspace with separate retention and access controls
- workspace-based Application Insights instance
- Azure Monitor action group with email and webhook receivers
- reusable diagnostic settings application for APIM, AI Foundry, Key Vault, and other resources
- scheduled query alerts for AI latency, error rate, and token consumption
- saved KQL searches for latency, errors, token usage, and content safety events
- dashboard and workbook JSON definitions for portal and analytics experiences
- optional resource-group budget alerting
