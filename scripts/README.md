# Scripts

This directory contains operational PowerShell scripts that support the Azure AI Platform reference architecture.

## Scripts

- `init-backend.ps1` – creates Terraform state resource groups, storage accounts, and blob containers.
- `validate-naming.ps1` – validates Azure resource names against the ADR-0004 naming convention.
- `new-ai-workload.ps1` – scaffolds new AI Foundry or APIM workload configuration, including tfvars and pipeline assets.

Run scripts from the repository root so relative paths resolve consistently in local development and CI agents.
