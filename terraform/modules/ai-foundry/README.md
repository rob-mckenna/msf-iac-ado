# ai-foundry module

Deploys a network-isolated Azure AI Foundry hub workspace with an attached AI project and private connectivity to all supporting services.

## What it creates

- Azure AI Foundry hub workspace implemented with `azurerm_machine_learning_workspace`
- AI Foundry project implemented with `azapi_resource`
- private endpoints for the hub workspace, storage account, Key Vault, Azure Container Registry, and Application Insights

## Required dependencies

This module expects the following supporting resources to exist before deployment:

- Storage Account
- Key Vault
- Container Registry
- Application Insights
- subnet for private endpoints
- relevant Private DNS zones

## Outputs

- `workspace_id`
- `workspace_name`
- `project_id`
- `private_endpoint_ids`
