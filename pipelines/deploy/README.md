# Deployment pipelines

This folder contains Azure DevOps pipelines for deploying AI artifacts that live above the infrastructure layer.

## Supported deployment types

- **Agents** – Azure AI Foundry agent or project deployments driven by configuration files.
- **Flows** – Prompt Flow deployments exposed through managed online endpoints.
- **Models** – model package or deployment YAML artifacts that can be promoted through the same environment sequence.

## Operating model

Deployment pipelines should run after the target infrastructure composition has already been provisioned. Promote artifacts from sandbox to poc to prod by reusing the same pipeline definition with environment-specific service connections, variable groups, and approval checks.
