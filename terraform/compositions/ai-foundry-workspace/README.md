# ai-foundry-workspace composition

Deploys a private Azure AI Foundry workload on top of landing zone outputs.

## Dependencies

This composition reads remote state from `landing-zone` to consume:

- shared private endpoint subnet
- private DNS zones
- shared Key Vault
- shared Application Insights

## What it adds

- workload resource group
- workload storage account
- premium container registry
- AI Foundry hub workspace and AI project
- private endpoints for the workspace and its dependencies
